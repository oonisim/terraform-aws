module "mysfits" {
  source = "../../../modules/dynamodb"

  PROJECT = var.PROJECT
  ENV     = var.ENV
  REGION  = var.REGION

  #--------------------------------------------------------------------------------
  # TODO: Make the table name configurable.
  #--------------------------------------------------------------------------------
  #name = "${var.PROJECT}_${var.ENV}_${var.name}"
  name = var.name
  #--------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------
  # The DynamoDB table fields must match with those used in the Lambda function.
  #--------------------------------------------------------------------------------
  hash_key = var.hash_key
  dynamodb_attributes = var.attributes
  global_secondary_index_map = var.global_secondary_index_map
}

#--------------------------------------------------------------------------------
# Update the DynamoDB table name
# The name 'MysfitsTable' is hard-coded in the populate-dynamodb.json as AWS CLI expects.
# Repalce the name using JQ.
#--------------------------------------------------------------------------------
resource "null_resource" "pupulate_dynamodb" {
  provisioner "local-exec" {
    command = <<EOF
echo '--------------------------------------------------------------------------------'
echo 'Populating the Dybamodb ${module.mysfits.name}...'
echo '--------------------------------------------------------------------------------'
export PYTHONPATH="~/.local/lib"
aws dynamodb batch-write-item \
--request-items "$(cat ${local.module_path}/aws-cli/populate-dynamodb.json | jq 'with_entries(if .key == "MysfitsTable" then .key = "${module.mysfits.name}" else . end)')"
EOF
  }
  triggers = {
    ts = timestamp()
  }
}