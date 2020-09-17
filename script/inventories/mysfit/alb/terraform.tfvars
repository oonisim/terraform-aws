#--------------------------------------------------------------------------------
# ALB SG
#--------------------------------------------------------------------------------
/*
alb_ecs_service_ABC_name = "service-alb"
alb_ecs_service_ABC_protocol = "tcp"
alb_ecs_service_ABC_port = 80
*/

#--------------------------------------------------------------------------------
# ALB target ECS/EC2 instance port.
# TODO: For dynamic port mapping, we do not know the value, hence set the ephemeral por range.
# TODO: Move the configuration to common module.
#--------------------------------------------------------------------------------
/*
ec2_microservice_XYZ_protocol = "tcp"
ec2_microservice_XYZ_host_port = 80
 = 22
lc_ecs_cluster_ssh_protocol = "tcp"
*/
bucket_log_name = "lb-log"
alb_enable_access_logs = false