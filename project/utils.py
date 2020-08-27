ADDR = '127.0.0.1'
SERVER_PORTS = { 
  'Goloman': 11805, 
  'Hands': 11806, 
  'Holiday': 11807, 
  'Welsh': 11808, 
  'Wilkes': 11809
}

RELATIONS = {
  'Goloman': ['Hands', 'Holiday', 'Wilkes'],
  'Hands': ['Goloman','Wilkes'],
  'Holiday': ['Goloman', 'Welsh', 'Wilkes'],
  'Welsh': ['Holiday'],
  'Wilkes': ['Goloman', 'Hands', 'Holiday'],
}

API_KEY = 'AIzaSyCquQHXiyo7NjMVIOmcfgmHKfS0mlS_3xY'
API_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'

LOG = None
SERVER_NAME = ""
CLIENTS = {}
CONNECTIONS = {
	'Goloman': False, 
	'Hands': False, 
	'Holiday': False, 
	'Welsh': False, 
	'Wilkes': False
}

