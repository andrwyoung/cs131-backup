import sys
import asyncio
import time
import aiohttp
import functools
import json
import re
from datetime import datetime
from utils import *

known_clients = {}
SERVER_ID = None
LOG = None
received_msgs = []
server_statuses = {
  'Goloman': False, 
  'Hands': False, 
  'Holiday': False, 
  'Welsh': False, 
  'Wilkes': False
}

class Client:
  def __init__(self, server_time_diff, client_id, latlng, client_time):
    self.server_time_diff = server_time_diff
    self.client_id = client_id
    self.latlng = latlng
    self.client_time = client_time

  def __str__(self):
    return f'AT {SERVER_ID} {self.server_time_diff} {self.client_id} {self.latlng} {self.client_time}'

async def writeErrMsg(writer, encodedErrMsg):
  writer.write(encodedErrMsg)
  writer.write_eof()
  await writer.drain()

async def parse_iamat(writer, query, qTokens):
  global received_msgs
  encodedErrMsg = (f'? {query}').encode()
  if len(qTokens) != 4:
    await writeErrMsg(writer, encodedErrMsg)
    return

  latlng = qTokens[2]
  latlngregex = '^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$'
  if re.match(latlngregex, latlng) is None:
    await writeErrMsg(writer, encodedErrMsg)
    return

  try:
    clientTime = float(qTokens[3])
    diffTime = time.time() - clientTime
    diffTime = f'+{diffTime}' if diffTime > 0 else str(diffTime)
    qTokens[0] = 'AT'
    qTokens.insert(1, diffTime) # insert difftime at second position of message
    known_clients[qTokens[2]] = Client(*qTokens[1:]) # create client object to keep track of client info
    ATMsg = " ".join(qTokens)
    writer.write(ATMsg.encode())
    writer.write_eof()
    await writer.drain()
    
    # flood servers
    received_msgs.append(ATMsg)
    for peer in server_statuses:
      if peer != SERVER_ID and talksWith(SERVER_ID, peer):
        asyncio.ensure_future(message_server(ATMsg, NAMES[peer]))
  except ValueError:
    await writeErrMsg(writer, encodedErrMsg)

async def places_api(latlng, radius, maxInfo):
  def formattedLatLng():
      latSign = '-' if latlng[0] == '-' else ''
      lngSign = ''
      lngIndex = latlng[1:].find('+')
      if lngIndex < 0:
        lngSign = '-'
        lngIndex = latlng[1:].find('-')
      return f'{latSign}{latlng[1:lngIndex+1]},{lngSign}{latlng[lngIndex+2:]}'

  API_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  params = {
    'key': API_KEY,
    'radius': radius*1000, # km to m
    'location': formattedLatLng()
  }

  async def fetch(session, url):
    async with session.get(url, params=params) as response:
      return await response.json()

  async with aiohttp.ClientSession() as session:
    json = await fetch(session, API_URL)
    json['results'] = json['results'][:maxInfo]
    return json

async def parse_whatsat(writer, query, qTokens):
  encodedErrMsg = (f'? {query}').encode()
  if len(qTokens) != 4 or qTokens[1] not in known_clients:
    await writeErrMsg(writer, encodedErrMsg)
    return
  client_id = qTokens[1]
  # test that the numbers are valid
  try:
    qTokens[2], qTokens[3] = int(qTokens[2]), int(qTokens[3])
    if qTokens[2] <= 0 or qTokens[2] > 50:
      raise ValueError("Radius must be between 1-50 km")
    if qTokens[3] <= 0 or qTokens[3] > 20:
      raise ValueError("Number of results must be between 1-20")
  except ValueError:
    await writeErrMsg(writer, encodedErrMsg)
    return

  resJSON = await places_api(known_clients[client_id].latlng, *qTokens[2:4])
  resJSON = json.dumps(resJSON, indent=3).strip()
  writer.write((f'{known_clients[client_id]}\r\n{resJSON}').encode())
  writer.write_eof()
  await writer.drain()

async def message_server(message, port):
  peer_server = PORTS[port]
  try:
    _, writer = await asyncio.open_connection('127.0.0.1', port, loop=loop)
    writer.write(message.encode())
    writer.write_eof()
    await writer.drain()
    writer.close()
    if not server_statuses[peer_server]:
      LOG.write(f'Connection established with server: {peer_server}\r\n')
      server_statuses[peer_server] = True
    return True
  except:
    #print(server_statuses, peer_server)
    if server_statuses[peer_server]:
      LOG.write(f'Connection dropped with server: {peer_server}\r\n')
      server_statuses[peer_server] = False
    return False

# Server->server message:
# AT diff_time client_id latlng client_time
async def parse_at(writer, query, qTokens):
  global received_msgs
  encodedErrMsg = (f'? {query}').encode()
  if len(qTokens) != 5:
    await writeErrMsg(writer, encodedErrMsg)
    return

  if query not in received_msgs:
    known_clients[qTokens[2]] = Client(*qTokens[1:])

    def task_callback(server, task):
      task.done()
      dest = NAMES[server]
      success = task.result()

    received_msgs.append(query)
    for peer in server_statuses:
      if peer != SERVER_ID and talksWith(SERVER_ID, peer):
        t = asyncio.ensure_future(message_server(query, NAMES[peer]))
        t.add_done_callback(functools.partial(task_callback, peer))
    
    client = writer.get_extra_info('peername')
    LOG.write(f'Received from {client}: {query}\r\n')

async def handle_queries(reader, writer):
  query = ''
  while not reader.at_eof():
    data = await reader.read(100)
    query += data.decode()
  qTokens = query.strip().split(" ")
  
  if qTokens[0] == "IAMAT":
    await parse_iamat(writer, query, qTokens)
    client = writer.get_extra_info('peername')
    LOG.write(f'Received from {client}: {query}\r\n')
  elif qTokens[0] == "WHATSAT":
    await parse_whatsat(writer, query, qTokens)
    client = writer.get_extra_info('peername')
    LOG.write(f'Received from {client}: {query}\r\n')
  elif qTokens[0] == "AT":
    await parse_at(writer, query, qTokens)
  else:
    await writeErrMsg(writer, (f'? {query}').encode())

  await writer.drain()
  writer.close()

def main(server_name):
  global loop
  port = int(NAMES[server_name])
  loop = asyncio.get_event_loop()
  coro = asyncio.start_server(handle_queries, ADDR, port, loop=loop)
  server = loop.run_until_complete(coro)

  host = server.sockets[0].getsockname()
  LOG.write(f'{SERVER_ID} serving on {host}.\r\n')
  print('Open!')

  try:
    loop.run_forever()
  except KeyboardInterrupt: # C-c
    LOG.write('Closing server...\r\n')

  server.close()
  loop.run_until_complete(server.wait_closed())
  loop.close()

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print('USAGE: python server.py [server-name]')
  else:
    if sys.argv[1] in NAMES:
      SERVER_ID = sys.argv[1]
      LOG = open(f'{SERVER_ID.lower()}.txt', "w+")
      main(sys.argv[1])
    else:
      print('Error: Server name not valid')
