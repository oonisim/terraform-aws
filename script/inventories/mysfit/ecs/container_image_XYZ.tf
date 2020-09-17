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
#
# Make sure the NAME in "docker build -t <NAME>:[tag]" matches the name in the
# "name" ecs_task container definition.
#--------------------------------------------------------------------------------
locals {
  microservice_XYZ_dir           = "${path.module}/${var.microservice_XYZ_dir}"
  microservice_XYZ_template_path = "${local.microservice_XYZ_dir}/${var.microservice_XYZ_dockerfile_template_name}"
  microservice_XYZ_file_path     = "${local.microservice_XYZ_dir}/${var.microservice_XYZ_dockerfile_name}"
}
/*
#--------------------------------------------------------------------------------
# Template - Dockerfile
#--------------------------------------------------------------------------------
data "template_file" "dockerfile_for_microservice_XYZ" {
  template = "${file(local.microservice_XYZ_template_path)}"
  vars = {
    #--------------------------------------------------------------------------------
    # Port to expose. Can be multiple e.g. EXPOSE 3000 80 443 22 in dockerfile
    #--------------------------------------------------------------------------------
    expose_ports = local.docker_container_port_for_microservice_XYZ
  }
}
*/

#--------------------------------------------------------------------------------
# Restore dockerfile that is to be deleted at local_file destruction.
# At first when Dockerfile does not exist, create it manually.
# Then at the subsequent terraform destroy time, it will get recreated here.
#--------------------------------------------------------------------------------
resource "null_resource" "restore_dockerfile" {
  provisioner "local-exec" {
    command = <<EOF
set -ue
touch ${local.microservice_XYZ_file_path}
EOF
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOF
set -ue
touch ${local.microservice_XYZ_file_path}
EOF
  }
}

#--------------------------------------------------------------------------------
# Container definition file (to be able to review the generated content only)
# Build container image depends on the trigger upon filemd(Dockerfile).
#--------------------------------------------------------------------------------
resource "local_file" "dockerfile_for_microservice_XYZ" {
  #content  = data.template_file.dockerfile_for_microservice_XYZ.rendered
  content = templatefile(local.microservice_XYZ_template_path, {
    #--------------------------------------------------------------------------------
    # Port to expose. Can be multiple e.g. EXPOSE 3000 80 443 22 in dockerfile
    #--------------------------------------------------------------------------------
    expose_ports = local.docker_container_port_for_microservice_XYZ
  })
  filename = local.microservice_XYZ_file_path

  depends_on = [
    null_resource.restore_dockerfile
  ]
}

#--------------------------------------------------------------------------------
# Build service image
# npm is being used in Dockerfile to build npm applications.
#
# Dockerfile must exist before terraform plan or apply runs because while DAG is
# being created, the local_file has not get executed yet, hence has not generated
# Dockerfile, but build container image null_resouce expects the file to check
# the trigger during the DAG creation.
#
# Understand how Terraform works. Evaluation the resources and creating DAG
# does not create resources. Do not expect the dependent resources exist when the
# depending resource is being evaluated.
#--------------------------------------------------------------------------------
resource "null_resource" "build_container_image_api" {
  provisioner "local-exec" {
    working_dir = local.microservice_XYZ_dir
    command = <<EOF
      pwd
      npm install
EOF
  }
  provisioner "local-exec" {
    #--------------------------------------------------------------------------------
    # [Note]
    # Build a docker image, and assign a tag for versioning
    # "${var.region}"
    # aws ecr get-loing was deprecated and removed in CLI 2.x
    # $(aws ecr get-login --no-include-email --region "${var.REGION}")
    #--------------------------------------------------------------------------------
    working_dir = local.microservice_XYZ_dir
    command = <<EOF
      set -ue

      aws ecr get-login-password --region "${var.REGION}" \
      | docker login \
        --username AWS \
        --password-stdin "${data.aws_caller_identity}.dkr.ecr.${data.aws_region}.amazonaws.com"

      docker build \
        -t "${lower("${local.microservice_XYZ_name}:${var.microservice_XYZ_build_version}")}" \
        -f "${local.module_path}/${local_file.dockerfile_for_microservice_XYZ.filename}" .

      docker tag \
        "${lower("${local.microservice_XYZ_name}:${var.microservice_XYZ_build_version}")}" \
        "${local.container_image_registry_XYZ_url}:${var.microservice_XYZ_release_tag}"

      printf "Pushing to "${local.container_image_registry_XYZ_url}:${var.microservice_XYZ_release_tag}"\n"
      docker push "${local.container_image_registry_XYZ_url}:${var.microservice_XYZ_release_tag}"
EOF
  }

  triggers = {
    #--------------------------------------------------------------------------------
    # Trigger on dockerfile (not template as the value change will not be detected)
    # Make sure dockerfile exits so that filemd6 will not complain file does not exist.
    # TODO: Identify the way to prevent Dockerfile from including sensitve data, e,g, via env.
    # Hoever, if the dockerfile contains sensitive data, checkin Dockerfile is a risk.
    #--------------------------------------------------------------------------------
    #dockerfile_template = filemd5(local.microservice_XYZ_template_path)
    dockerfile = filemd5(local.microservice_XYZ_file_path)

    # TODO: Add triggers to run build when Python source code change.
    ts = timestamp()
  }

  depends_on = [
    local_file.dockerfile_for_microservice_XYZ
  ]

  #--------------------------------------------------------------------------------
  # Create dummy dockerfile so that null_resource docker container builder trigger
  # will not file due to file does not exist.
  #
  # This may cause an error as the hash value is different.
  #   Error: Provider produced inconsistent final plan
  #   When expanding the plan for null_resource.build_container_image_api to include
  #   new values learned so far during apply, provider
  #   "registry.terraform.io/-/null" produced an invalid new value for
  #   .triggers["dockerfile"]: was
  #   cty.StringVal("d41d8cd98f00b204e9800998ecf8427e"), but now
  #   cty.StringVal("20f52f51499c963b87368748e2bca78d").
  #--------------------------------------------------------------------------------
  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOF
set -ue
touch ${local.microservice_XYZ_file_path}
EOF
  }
}

