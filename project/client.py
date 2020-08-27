import asyncio
import sys
import time
from utils import *

async def send_message(message, loop, port):
	reader, writer = await asyncio.open_connection(ADDR, port,
                                                   loop=loop)
	# send the message to server
	print("-------sending: ")
	print(message)
	writer.write(message.encode())
	writer.write_eof()
	await writer.drain()

	# wait for response
	response = ''
	while not reader.at_eof():
		curr = await reader.readline()
		response += curr.decode()

	# print that then close
	print("-------received: ")
	print(response)
	writer.close()
	await writer.wait_closed()



def main(port):
	loop = asyncio.get_event_loop()
	loop.run_until_complete(send_message(f'IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 {time.time()}', loop, port))
	#loop.run_until_complete(send_message(f'tfIAMAT kiwi.cs.ucla.edu +34.068930-118.445127 {time.time()}', loop, port))
	#loop.run_until_complete(send_message(f'IAMAT tfrt kiwi.cs.ucla.edu +34.068930-118.445127 {time.time()}', loop, port))
	#loop.run_until_complete(send_message(f'IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 hey!', loop, port))
	#loop.run_until_complete(send_message(f'IAMAT kiwi.cs.ucla.edu +34.068930-118._445127 {time.time()}', loop, port))
	
	loop.run_until_complete(send_message('WHATSAT kiwi.cs.ucla.edu 10 1', loop, port))
	#loop.run_until_complete(send_message('WHATSAT kiwi.cs.ucla.edu tfr 5', loop, port))
	#loop.run_until_complete(send_message('WHATSAT kiwi.cs.ucla.edu 10 500', loop, port))
	
	loop.close()


if __name__ == "__main__":
	# do error checking before starting
	if len(sys.argv) != 2:
		print('USAGE: python client.py [server-name]')
	else:
		if sys.argv[1] in SERVER_PORTS:
			main(SERVER_PORTS[sys.argv[1]])
		else:
			print('ERROR: invalid server name')

