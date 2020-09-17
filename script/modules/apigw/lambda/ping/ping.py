import json
def lambda_handler(event, context):
    # API Gateway expects specific response format.
    # https://stackoverflow.com/questions/47907641/malformed-lambda-proxy-response-from-aws-api-gateway-calling-a-lambda
    response = {
        "Status" : "OK",
    }
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(response),
        "isBase64Encoded": False
    }
