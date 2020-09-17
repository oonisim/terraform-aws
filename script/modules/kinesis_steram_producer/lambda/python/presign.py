#--------------------------------------------------------------------------------
# A bucket with CORS may need path style for pre-signed POSTs/URLs as DNS takes time.
# For path style, you HAVE to set the correct region.
#--------------------------------------------------------------------------------
from __future__ import print_function
import boto3
import botocore.exceptions
import boto3.session
import sys

#--------------------------------------------------------------------------------
# Boto3 session
#--------------------------------------------------------------------------------
def client(region):
    session = boto3.session.Session(region_name=region)
    client = session.client('s3')
    return client

#--------------------------------------------------------------------------------
# Get presigned URL
# - bucket: Bucket name (NOT URL)
# - key   : S3 object key for put_object method.
# - expiry: Expiry in seconds
#--------------------------------------------------------------------------------
def url(region, bucket, key, expiry):
    url = client(region).generate_presigned_url(
        'put_object',
        Params = {
            'Bucket': bucket,
            'Key': key          # Mandatory
        },
        ExpiresIn = expiry
    )
    print (url)
    return url

#--------------------------------------------------------------------------------
# Test Main
#--------------------------------------------------------------------------------
# S3 upload
# curl --request PUT --upload-file <file to upload> "<generated S3 URL>"
#--------------------------------------------------------------------------------
if __name__ == '__main__':
    print("region?\n")
    region = sys.stdin.readline().rstrip('\n')
    print("S3 bucket to presign?\n")
    bucket = sys.stdin.readline().rstrip('\n')
    print("S3 key?\n")
    key    = sys.stdin.readline().rstrip('\n')

    print("url is [")
    print(url(region, bucket, key, "3600"))
    print("]")