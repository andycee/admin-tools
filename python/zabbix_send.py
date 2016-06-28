import socket
import struct
import json


HOST = '10.0.14.253'
PORT = 10051


HEADER = '''ZBXD\1%s%s'''
# just some data
DATA = '''{
"request":"sender data",
"data":[
{
"host":"Zabbix server",
"key":"kolichestvo",
"value":"89"}
]
}
'''


data_length = len(DATA)
data_header = struct.pack('i', data_length) + '\0\0\0\0'

data_to_send = HEADER % (data_header, DATA)

# here really should come some exception handling
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((HOST, PORT))


# send the data to the server
sock.send(data_to_send)

# read its response, the first five bytes are the header again
response_header = sock.recv(5)
if not response_header == 'ZBXD\1':
    raise ValueError('Got invalid response')

# read the data header to get the length of the response
response_data_header = sock.recv(8)
response_data_header = response_data_header[:4] # we are only interested in the first four bytes
response_len = struct.unpack('i', response_data_header)[0]

# read the whole rest of the response now that we know the length
response_raw = sock.recv(response_len)

sock.close()

response = json.loads(response_raw)

print response
