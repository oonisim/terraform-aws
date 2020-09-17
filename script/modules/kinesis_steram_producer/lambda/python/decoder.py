# --------------------------------------------------------------------------------
# Token decoder proxy
# The token provider can be AWS Cognito User Pool or Active Directory FS (SAML).
# --------------------------------------------------------------------------------
from __future__ import print_function
import sys

# --------------------------------------------------------------------------------
# Token tool
# [Note]
# identity.py is generated from <token_type>_token.py.tpl by Terraform.
# --------------------------------------------------------------------------------
import identity


# --------------------------------------------------------------------------------
# Decode the token and transform into a common format.
# claims
#   "uid"      : "<user identity>"
#   "email"    : "<user email>"     # Required to notify the user.
#   "authenticated_time": "<epoch time>"     # Time the token is created (user is authenticated)
#   "expiry"   : "<ephch time>"     # Time when the token expires.
# }
# --------------------------------------------------------------------------------
def decode(token):
	result = identity.decode(token)
	return {
		"uid": result['sub'],
		"email": result['email'],
		"authenticated_time": result['auth_time'],
		"expiry": result['exp']
	}


# --------------------------------------------------------------------------------
# Test Main
# --------------------------------------------------------------------------------
# S3 upload
# curl --request PUT --upload-file <file to upload> "<generated S3 URL>"
# --------------------------------------------------------------------------------
if __name__ == '__main__':
	print("Token?\n")
	print(decode(sys.stdin.readline().rstrip('\n')))

