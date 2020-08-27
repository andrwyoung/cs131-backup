import asyncio
import sys
import time
from utils import *

async def tcp_echo_client(server_name, message, loop):
  reader, writer = await asyncio.open_connection(ADDR, int(NAMES[server_name]), loop=loop)
  print(f'Send {message}')
  writer.write(message.encode())
  writer.write_eof()
  await writer.drain()
  print("Read ", end='')
  while not reader.at_eof():
    data = await reader.readline()
    print(data.decode(), end='')
  writer.close()
  await writer.wait_closed()
  print()



def main(server_name):
  loop = asyncio.get_event_loop()
  loop.run_until_complete(tcp_echo_client(server_name, f'IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 {time.time()}', loop))
  loop.run_until_complete(tcp_echo_client(server_name, 'WHATSAT kiwi.cs.ucla.edu 10 3', loop))
  loop.close()

if __name__ == "__main__":
  if len(sys.argv) > 3:
    print('USAGE: python client.py server-name [message]')
  else:
    main(*sys.argv[1:])