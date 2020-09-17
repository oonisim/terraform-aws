# Overview
Test component. 

## Limitation
Currently assuming AMZN1 ECS AMI. Need to incorporate the logic to identify the Amazon Linux type.

# Test connections to the ECS EC2 and a microservice host port.

Craete a bustion EC2 instance in the public subnet and test connectivities to the ECS EC2 instances from the bastion host.
* SSH conenctivity
* Microservice XCZ EC2 host port connectivity.

! ASG ECS/EC2 instances are not supported.

# Display the Docker and ECS agent process information.

Using the Terraform remote-exec provisioner bastion ssh connection, run the command to display the docker and ECS agent information.

* Docker daemon status
* Docker processes
* Docker daemon log
* ECS agent process status
* ECS agent init log

# Access ELB endpoint for the microservice XYZ
```
"http://${local.elb_dns_name}:${local.client_port_for_microservice_XYZ}"
```