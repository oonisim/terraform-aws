#--------------------------------------------------------------------------------
# DynamoDB based on https://github.com/cloudposse/terraform-aws-dynamodb
#--------------------------------------------------------------------------------
locals {
  #attributes = var.dynamodb_attributes
  attributes = flatten([
    [
      # Range key must come fist to remove it if empty using slice.
      {
        name = "${var.range_key}"
        type = "S"
      },
      {
        name = "${var.hash_key}"
        type = "S"
      }
    ],
    "${var.dynamodb_attributes}",
  ])

  # Use the `slice` pattern (instead of `conditional`) to remove the first map from the list if no `range_key` is provided
  # Terraform does not support conditionals with `lists` and `maps`: aws_dynamodb_table.default: conditional operator cannot be used with list values
  from_index = length(var.range_key) > 0 ? 0 : 1

  #attributes_final = slice(local.attributes, local.from_index, length(local.attributes))
  attributes_final = slice(local.attributes, local.from_index, length(local.attributes))
}


resource "aws_dynamodb_table" "this" {
  name             = var.name

  hash_key         = var.hash_key
  range_key        = var.range_key

  dynamic "attribute" {
    for_each = local.attributes_final
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_index_map
    content {
      hash_key           = global_secondary_index.value.hash_key
      name               = global_secondary_index.value.name
      non_key_attributes = global_secondary_index.value.non_key_attributes
      projection_type    = global_secondary_index.value.projection_type
      range_key          = global_secondary_index.value.range_key
      read_capacity      = global_secondary_index.value.read_capacity
      write_capacity     = global_secondary_index.value.write_capacity
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_index_map
    content {
      name               = local_secondary_index.value.name
      non_key_attributes = local_secondary_index.value.non_key_attributes
      projection_type    = local_secondary_index.value.projection_type
      range_key          = local_secondary_index.value.range_key
    }
  }

  billing_mode     = var.billing_mode
  read_capacity    =var.autoscale_min_read_capacity
  write_capacity   = var.autoscale_min_write_capacity

  #--------------------------------------------------------------------------------
  # Stream
  # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html
  #--------------------------------------------------------------------------------
  stream_enabled   = var.enable_streams
  stream_view_type = var.stream_view_type

  server_side_encryption {
    enabled = var.enable_encryption
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  lifecycle {
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }

  ttl {
    # https://github.com/terraform-providers/terraform-provider-aws/issues/3463
    #attribute_name = "${"${var.ttl_attribute}"}"
    attribute_name = ""
    enabled        = var.enable_ttl
  }

  tags = var.tags
}

