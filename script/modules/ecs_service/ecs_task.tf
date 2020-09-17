#--------------------------------------------------------------------------------
# ECS task (a task is 1 to 1 with a docker container)
#--------------------------------------------------------------------------------
resource "aws_ecs_task_definition" "this" {
  family                = "${var.PROJECT}_${var.ENV}_${var.ecs_task_name}"

  #--------------------------------------------------------------------------------
  # (Optional) The Docker networking mode to use for the containers in the task.
  # The valid values are none, bridge, awsvpc, and host.
  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#network_mode
  #--------------------------------------------------------------------------------
  network_mode  = var.ecs_task_network_mode

  #  container_definitions = data.template_file.ecs_task_container_definition.rendered
  # TODO: Handle when task_definition have multiple docker container definitions.
  # TODO: container_definitions is to be passed from the inventory.
  # Wrong 1 to 1 relationship was assumed between task_definition and container_definition before.
  container_definitions = templatefile(local.ecs_task_container_definition_template, {
    #--------------------------------------------------------------------------------
    # WARNING!!!
    # AWS BUG https://forums.aws.amazon.com/thread.jspa?threadID=217532
    # The ECR registry name MUST match with the name in the ecs_task container defintion name.
    # Otherwise:
    # Error: InvalidParameterException: The container <NAME> does not exist in the task definition.
    # status code: 400, request id: 36b51b69-972a-11e9-b5d2-9bf21e15212b "<NAME>"
    #
    # [Example]
    # For the ECR registry 675450155784.dkr.ecr.us-west-2.amazonaws.com/ecstest_masa_TBD/api:latest
    # the container name "api" must match the "name" attribute value in the container_definition.json.
    # [
    # {
    #   "name": "api",
    # "image": "675450155784.dkr.ecr.us-west-2.amazonaws.com/ecstest_masa_TBD/api:latest",
    # "cpu": 256,
    # "memory": 256,
    # "essential": true,
    # "portMappings": [{"containerPort":3000,"hostPort":0}]
    # }
    # ]
    #--------------------------------------------------------------------------------
    # name          = "${var.PROJECT}_${var.ENV}_${var.container_name}"
    name          = var.container_name
    #--------------------------------------------------------------------------------

    image         = "${var.container_image_url}"
    cpu_units     = "${var.ecs_task_cpu_units}"
    memory_units  = "${var.ecs_task_memory_units}"
    port_mappings = jsonencode(var.ecs_task_port_mappings)

    #--------------------------------------------------------------------------------
    # Cloudwatch log group for awslogs log-driver
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#create_awslogs_logdriver_options
    #--------------------------------------------------------------------------------
    aws_region    = data.aws_region.current.name

    #--------------------------------------------------------------------------------
    # [awslogs log driver]
    # The container definition requires the configuration below.
    #"logConfiguration": {
    #  "logDriver": "awslogs",
    #  "options": {
    #    "awslogs-group": "ecs_cluster_hoge",      <--- Your cloudwatch log group
    #    "awslogs-stream-prefix": "service_tako",  <--- Specific directory for the microservice container.
    #    "awslogs-region": "us-west-2"
    #  }
    #}
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html
    #--------------------------------------------------------------------------------
    cloudwatch_lg_ecs_name = aws_cloudwatch_log_group.ecs.name
    #--------------------------------------------------------------------------------
    # To have specific log groupp directory for each container, use the microservice
    # container name as the prefix.
    #
    # TODO: Identify the way to distinguish each container in the same ECS task/microservice.
    # With multiple same task deployed for scaleability, multiple containers will have
    # the same name, hence not able to identify which container emits which log line.
    #
    # TODO: The awslogs driver may look after this part. Need to verify.
    #--------------------------------------------------------------------------------
    cloudwatch_lg_ecs_prefix = var.container_name

    #--------------------------------------------------------------------------------
    # Environment variables
    #--------------------------------------------------------------------------------
    project =var.PROJECT
    environment = var.ENV
  })

  /*
  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
  */
}

/*
#--------------------------------------------------------------------------------
# Template - ECS container definition
#--------------------------------------------------------------------------------
data "template_file" "ecs_task_container_definition" {
  template = "${file(local.ecs_task_container_definition_template)}"
  vars = {
    #--------------------------------------------------------------------------------
    # WARNING!!!
    # AWS BUG https://forums.aws.amazon.com/thread.jspa?threadID=217532
    # The ECR registry name MUST match with the name in the ecs_task container defintion name.
    # Otherwise:
    # Error: InvalidParameterException: The container <NAME> does not exist in the task definition.
    # status code: 400, request id: 36b51b69-972a-11e9-b5d2-9bf21e15212b "<NAME>"
    #
    # [Example]
    # For the ECR registry 675450155784.dkr.ecr.us-west-2.amazonaws.com/ecstest_masa_TBD/api:latest
    # the container name "api" must match the "name" attribute value in the container_definition.json.
    # [
    # {
    #   "name": "api",
    # "image": "675450155784.dkr.ecr.us-west-2.amazonaws.com/ecstest_masa_TBD/api:latest",
    # "cpu": 256,
    # "memory": 256,
    # "essential": true,
    # "portMappings": [{"containerPort":3000,"hostPort":0}]
    # }
    # ]
    #--------------------------------------------------------------------------------
    # name          = "${var.PROJECT}_${var.ENV}_${var.container_name}"
    name          = var.container_name
    #--------------------------------------------------------------------------------
    image         = "${var.container_image_url}"
    cpu_units     = "${var.ecs_task_cpu_units}"
    memory_units  = "${var.ecs_task_memory_units}"
    port_mappings = jsonencode(var.ecs_task_port_mappings)

    #--------------------------------------------------------------------------------
    # Cloudwatch log group for awslogs log-driver
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html#create_awslogs_logdriver_options
    #--------------------------------------------------------------------------------
    aws_region    = data.aws_region.current.name
    cloudwatch_lg_ecs_name = aws_cloudwatch_log_group.ecs.name
    #cloudwatch_lg_ecs_prefix = aws_cloudwatch_log_group.ecs.name_prefix
  }
}
*/

#--------------------------------------------------------------------------------
# Container definition file (to be able to review the generated content only)
#--------------------------------------------------------------------------------
resource "local_file" "ecs_task_container_definition" {
  #content  = data.template_file.ecs_task_container_definition.rendered
  content = aws_ecs_task_definition.this.container_definitions
  filename = "${local.module_path}/${var.ecs_task_container_definition_path}"
}
