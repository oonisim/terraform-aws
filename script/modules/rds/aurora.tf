#================================================================================
# [Objective]
# Setup RDS (Aurora/MySQL)
#
# [Note]
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Aurora.Overview.html
# Amazon Aurora instance requires a cluster which consists of one or more DB.
#
# https://www.terraform.io/docs/commands/apply.html
# -input=true - Ask for input for variables if not directly set
#
# [Variables]
# https://www.terraform.io/intro/getting-started/variables.html
# Define Terraform variable file and specify with -var-file="<file>.tfvars"
#================================================================================

#================================================================================
# Subnert Group
# Must select a DB subnet group when creating a DB instance in VPC.
# RDS uses the subnet group and preferred AZ to select a subnet and an IP address
# within that subnet to associate with your DB instance.
#================================================================================
# To be created in AWS VPC module.
resource "aws_db_subnet_group" "this" {
    name            = "${var.ENV}-${var.PROJECT}-subnet-group"
    description     = "VPC subnet group for RDS DB cluster instances"
    subnet_ids      = [
        "${split(",", var.subnet_ids)}"
    ]

    tags = {
        Name        = "${var.ENV}-${var.PROJECT}-subnet-group"
        Project     = "${var.PROJECT}"
        Environment = "${var.ENV}"
        Type        = "db_subnet_group"
        VPC         = "${var.vpc_name}"
        ManagedBy   = "terraform"
    }

    lifecycle {
      create_before_destroy = true
      prevent_destroy       = true
    }
}
resource "aws_rds_cluster" "this" {
    cluster_identifier            = "${var.ENV}-${var.PROJECT}-rds-cluster"
    db_subnet_group_name          = "${aws_db_subnet_group.this.name}"
    vpc_security_group_ids        = [
      "${var.security_group_id}"
    ]
    tags = {
        Name        = "${var.ENV}-${var.PROJECT}-rds-cluster"
        Type        = "rds_subnet"
        VPC         = "${var.vpc_name}"
        Project     = "${var.PROJECT}"
        Environment = "${var.ENV}"
        ManagedBy   = "terraform"
    }

    database_name   = "${var.db_name}"
    master_username = "${var.username}"
    master_password = "${var.password}"
    engine = "${var.db_engine}"
    port   = "${var.db_port}"

    backup_retention_period       = "${var.retention_period}"
    #preferred_backup_window       = "02:00-03:00"
    #preferred_maintenance_window  = "wed:03:00-wed:04:00"
    final_snapshot_identifier     = "${var.ENV}-snapshot-${var.PROJECT}-${var.db_name}"

    lifecycle {
        create_before_destroy = true
        prevent_destroy       = true
    }
    timeouts {
        create = "60m"
        delete = "2h"
    }

}

resource "aws_rds_cluster_instance" "this" {
    #--------------------------------------------------------------------------------
    # To deploy multi instance.
    #--------------------------------------------------------------------------------
    count                 = "${length(split(",", var.subnet_ids))}"
    identifier            = "${aws_rds_cluster.this.id}-instance-${count.index}"
    cluster_identifier    = "${aws_rds_cluster.this.id}"
    instance_class        = "${var.db_instance_class}"

    db_subnet_group_name  = "${aws_db_subnet_group.this.name}"
    publicly_accessible   = false

    tags = {
        Name        = "${aws_rds_cluster.this.id}-instance-${var.db_name}-${count.index}"
        Type        = "rds_cluster_instance"
        VPC         = "${var.vpc_name}"
        Project     = "${var.PROJECT}"
        Environment = "${var.ENV}"
        ManagedBy   = "terraform"
    }

    lifecycle {
      create_before_destroy = true
      prevent_destroy       = true
    }

    timeouts {
      create = "60m"
      delete = "2h"
    }

}

