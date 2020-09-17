#!/usr/bin/python

import hmac
import hashlib
import base64
import json
import uuid
import sys

def get_secret_hash(username, client_id, client_secret):
	msg = username + client_id
	dig = hmac.new(str(client_secret).encode('utf-8'),
				   msg = str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
	d2 = base64.b64encode(dig).decode()
	return d2

if __name__ == '__main__':
	#name   = raw_input("What is username?")
	#id     = raw_input("What is client_id?")
	#secret = raw_input("What is client_secret?")
	name   = sys.argv[1]
	id     = sys.argv[2]
	secret = sys.argv[3]
	print(get_secret_hash(name, id, secret))
