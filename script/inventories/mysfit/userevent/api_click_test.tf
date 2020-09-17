# The lambda expects the input format below.
# "records": [
# {
#   "recordId": ...,
#   "data" : ...
# }
# ...
# ]

/*
curl -i -v -XPUT -H "Content-Type: application/json" \
--data '{"userId": "2","mysfitId": "2b473002-36f8-4b87-954e-9a377e0ccbec"}' \
https://ni0tqd82ab.execute-api.us-east-2.amazonaws.com/dev/click
*/

resource "null_resource" "test_api_click_and_lambda_transform" {
  provisioner "local-exec" {
    command     = <<EOF
sleep 3

curl -i -v -XPUT -H "Content-Type: application/json" \
  "${aws_api_gateway_deployment.this.invoke_url}/${aws_api_gateway_resource.click.path_part}" \
  --data '{"userId": "2","mysfitId": "2b473002-36f8-4b87-954e-9a377e0ccbec"}'
EOF
  }
  triggers = {
    aws_api_gateway_deployment = aws_api_gateway_deployment.this.variables["deployed_at"]
  }
}

