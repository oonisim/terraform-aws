name = "MysfitsTable"
hash_key = "MysfitId"
attributes = [
  {
    name = "MysfitId"
    type = "S"
  },
  {
    name = "GoodEvil"
    type = "S"
  },
  {
    name = "LawChaos"
    type = "S"
  },
]

global_secondary_index_map = [
  {
    name            = "GoodEvilIndex"
    hash_key        = "GoodEvil"
    range_key       = "MysfitId"
    projection_type = "ALL"
    non_key_attributes = []
    write_capacity = 5
    read_capacity  = 5
  },
  {
    name            = "LawChaosIndex"
    hash_key        = "LawChaos"
    range_key       = "MysfitId"
    projection_type = "ALL"
    non_key_attributes = []
    write_capacity = 5
    read_capacity  = 5
  },
]