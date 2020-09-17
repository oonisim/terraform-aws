/*
# TF variable for unit testing
PROJECT = "TBD"
ENV = "TBD"
hash_key = "id"

dynamodb_attributes = [
  {
    name = "start_time"
    type = "N"
  },
  {
    name = "end_time"
    type = "N"
  },
  {
    name = "email"
    type = "S"
  },
]

global_secondary_index_map = [
  {
    # To query long running or non-running jobs
    name            = "EndStartTimeGSI"
    hash_key        = "end_time"
    range_key       = "start_time"
    projection_type = "INCLUDE"
    #--------------------------------------------------------------------------------
    # Github issue #3828 global secondary index always recreated
    # https://github.com/terraform-providers/terraform-provider-aws/issues/3828
    #--------------------------------------------------------------------------------
    non_key_attributes = [
      "email", # Primary key is included by default
      "status",
    ]
    write_capacity = 10
    read_capacity  = 10
  },
  {
    # To query jobs for a user.
    # end_time as partition_key distribute items.
    # end_time == -1 selects active jobs which will be small set in the entire items.
    # email as range key then selects jobs of a specific user.
    # start_time can further filter long running jobs
    name            = "EndTimeEmailGSI"
    hash_key        = "end_time"
    range_key       = "email"
    projection_type = "INCLUDE"
    non_key_attributes = [
      "creation_time",
      "start_time",
      "status",
    ]
    write_capacity = 1
    read_capacity  = 1
  },
]
*/