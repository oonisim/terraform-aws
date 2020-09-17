#--------------------------------------------------------------------------------
# Values for testing.
# !!! Disable them for actual use !!!
#--------------------------------------------------------------------------------
/*
PROJECT="masa-alb"
ENV="test"
REGION= "us-west-2"
bucket_log= "ecs-masa-poc-data"

name = "masa_elb"
is_internal = false

security_group_ids = [
  "sg-00790073a52b81e2d"
]

vpc_id = "vpc-09ba92b8bc3d7fab3"
subnet_ids = [
  "subnet-04b2efb602217d5ff",
  "subnet-05aad3a3c13e1cba5",
  "subnet-0dd9852cc7662f648"
]

listeners = [
  {
    port = 80
    protocol = "HTTP"
    action = "forward"
  },
  {
    port = 8080
    protocol = "HTTP"
    action = "forward"
  },
]

targets = [
  {
    target_type = "ip"
    port = 80
    protocol = "HTTP"
    stickiness = true
  },
  {
    target_type = "ip"
    port = 8080
    protocol = "HTTP"
    stickiness = true
  },
]
*/