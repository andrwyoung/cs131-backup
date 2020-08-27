import asyncio
import aiohttp
import sys
import time
import re
import json
from utils import *

### helper functions
async def reply_error(writer, message):
	writer.write((f'? {message}').encode())
	writer.write_eof()
	await writer.drain()

async def difftime(first_time):
	diff_time = time.time() - first_time
	diff_time = f'+{diff_time}' if diff_time > 0 else str(diff_time)
	return diff_time

def format_latlng(location):
	latSign= '-' if location[0] == '-' else ''
	lngSign = ''
	lngIndex = location[1:].find('+')
	if lngIndex < 0:
		lngSign = '-'
		lngIndex = location[1:].find('-')
	return f'{latSign}{location[1:lngIndex+1]},{lngSign}{location[lngIndex+2:]}'







async def reply_iamat(writer, message):
	tokens = message.strip().split(" ")

	if len(tokens) != 4:
		print("\twrong length")
		await reply_error(writer, message)
		return
	
	regex = '[+-]\d*\.?\d+[+-]\d*\.?\d+'
	if re.match(regex, tokens[2]) is None:
		print("\tinvalid ISO 6709")
		await reply_error(writer, message)
		return

	try:
		client_time = float(tokens[3])
	except:
		print("\tfourth item isn't a float")
		await reply_error(writer, message)
		return

	# build the message
	tokens[0] = 'AT'
	tokens.insert(1, await difftime(client_time))
	tokens.insert(1, SERVER_NAME)
	response = " ".join(tokens)

	# keep track of this client 
	# clients[name] = [location, time last message recieved]
	CLIENTS[tokens[3]] = [tokens[4], tokens[5], tokens[1], tokens[2]]
	print("\tlogged message")
	LOG.write(f'Data recieved: {message}\n')

	# return response
	writer.write(response.encode())
	writer.write_eof()
	await writer.drain()
	print(response)

	await message_servers(response)




async def reply_at(message):
	tokens = message.strip().split(" ")
	client_name = tokens[3]

	# if client already logged, and time matches up
	# that means this message has already been logged
	if client_name in CLIENTS and tokens[5] == CLIENTS[client_name][1]:
		print("\tserver already got this message")
		return
	else:
		CLIENTS[client_name] = [tokens[4], tokens[5], tokens[1], tokens[2]]
		print("\tlogged message")
		LOG.write(f'Message received: {message}\n')
	
	LOG.write(f'Message from {tokens[1]}: {message}\n')
	await message_servers(message)




# message all servers it has connection with
# logging all created/dropped connections
async def message_servers(message):
	loop = asyncio.get_event_loop()

	for peer_name in RELATIONS[SERVER_NAME]:
		print("trying to send message to: " + peer_name)
		port = SERVER_PORTS[peer_name]

		try:
			reader, writer = await asyncio.open_connection('127.0.0.1', port, loop=loop)

			writer.write(message.encode())
			writer.write_eof()
			await writer.drain()
			writer.close()

			if not CONNECTIONS[peer_name]:
				LOG.write(f'Connection created with: {peer_name}\n')
				CONNECTIONS[peer_name] = True

			print("\tmessage success!")
		except:
			if CONNECTIONS[peer_name]:
				LOG.write(f'Connection dropped with: {peer_name}\n')
				CONNECTIONS[peer_name] = False

			print("\tconnection failed...")







async def reply_whatsat(writer, message):
	tokens = message.strip().split(" ")
	client_name = tokens[1]

	if len(tokens) != 4:
		print("\twrong length")
		await reply_error(writer, message)
		return

	if client_name not in CLIENTS:
		print("\tunknown clients")
		await reply_error(writer, message)
		return

	try:
		radius = int(tokens[2])
		results = int(tokens[3])
	except:
		print("\tradius and number of results must be a number")
		await reply_error(writer, message)
		return
	
	if radius <= 0 or radius > 50 or results <= 0 or results > 20:
		print("\tradius range: 1-50\n\tnumber of results range: 1-20")
		await reply_error(writer, message)
		return

	# start processing the message
	print("processed")
	LOG.write(f'Message received: {message}\n')

	resJSON = await places_json(CLIENTS[client_name][0], radius, results)
	resJSON = json.dumps(resJSON, indent=3).strip()
	print(resJSON)

	client = CLIENTS[client_name]
	# reconstructing message
	response = ["AT", client[2], client[3], client_name, client[0], client[1]]
	response = message = " ".join(response)

	writer.write((f'{response}\n{resJSON}').encode())
	writer.write_eof()
	await writer.drain()



async def places_json(latlng, radius, maxInfo):
	params = {
		'key': API_KEY,
		'radius': radius*1000, # km to m
		'location': format_latlng(latlng)
	}

	async def fetch(session, url):
		async with session.get(url, params=params) as response:
			return await response.json()

	async with aiohttp.ClientSession() as session:
		json = await fetch(session, API_URL)
		json['results'] = json['results'][:maxInfo]
		return json


 




async def handle_requests(reader, writer):
	# waiting for response from client
	message = ''
	while not reader.at_eof():
		curr = await reader.read(100)
		message += curr.decode()
	addr = writer.get_extra_info('peername')
	print("received %r from %r" % (message, addr))

	# split up the cases depending on the message
	tokens = message.strip().split(" ")
	if tokens[0] == "IAMAT":
		print("->iamat")
		await reply_iamat(writer, message)
	elif tokens[0] == "WHATSAT":
		print("->whatsat")
		await reply_whatsat(writer, message)
	elif tokens[0] == "AT":
		print("->at")
		await reply_at(message)
	else:
		print("\tinvalid first item")
		await reply_error(writer, message)

	# closing socket
	print()
	await writer.drain()
	writer.close()
	await writer.wait_closed()




def main(port):
	loop = asyncio.get_event_loop()
	coro = asyncio.start_server(handle_requests, ADDR, port, loop=loop)
	server = loop.run_until_complete(coro)
	host = server.sockets[0].getsockname()

	# log it first
	LOG.write(f'{SERVER_NAME} serving on {host}\n')
	print('serving on {}'.format(host))

	# listen until ctrl+c
	try:
	    loop.run_forever()
	except KeyboardInterrupt:
	    LOG.write("Closing...\n")

	# close the server once done
	server.close()
	loop.run_until_complete(server.wait_closed())
	loop.close()

if __name__ == "__main__":
	# do all error checking first
	if len(sys.argv) != 2:
		print('USAGE: python client.py [server-name]')
	else:
		if sys.argv[1] in SERVER_PORTS:
			SERVER_NAME = sys.argv[1]
			LOG = open(f'{SERVER_NAME.lower()}.txt', "w+")
			main(SERVER_PORTS[sys.argv[1]])
		else:
			print('Error: Server name not valid')
