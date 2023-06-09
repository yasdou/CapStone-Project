//variables.tf

#If you want to change any of the variables go to the terraform.tfvars and specify anthing you want there

variable "name"{
    description = "Give a name that will be used to create all your ressources"
    default = "jellyfin"
}

##################
#### Network #####
##################
variable "region"{
    default = "us-west-2"
}
variable "VPC_CIDR" {
    default = "10.0.0.0/16"
}
variable "enable_dns_support" {
    default = true
}
variable "enable_dns_hostnames" {
    default = true
}



##################
## EC2 instances #
##################


variable "ami_id" {
    default = "ami-0ac64ad8517166fb1"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "ami_key_pair_name" {
    default = "vokey"
}
variable "instance_profile" {
    default = "EC2_Admin"
}
variable "container_port" {
  description = "Which Ports do you need to be exposed for your containers?"
  default = 8096
}
variable "useremail" {
  description = "Whats the Email you want to get the Auto Scaling Notifications to?"
}


##################
# Var local prov #
##################
locals {
  vars = {
  #  rdsendpoint = aws_rds_cluster.RDSWP.endpoint
  #  s3bucketname = aws_s3_bucket.s3bucket.bucket
    DBName = var.DBName
    DBPassword = var.DBPassword
    DBUser = var.DBUser
    container_port = var.container_port
    elb =  aws_alb.ELBJellyfin.dns_name
  #  efs_dns_name = aws_efs_file_system.WPfilesystem.dns_name
  }
}


##################
#### Database ####
##################
variable "clusteridentifier" {
    description = "Name of the RDS Cluster. Only lowercase letters allowed"
    default = "wordpresscluster"
}
variable "db_engine" {
    default = "aurora-mysql"
}
variable "db_engine_version" {
    default = "5.7.mysql_aurora.2.11.1"
}
variable "db_skip_final_snapshot" {
    default = true
}
variable "max_capacity" {
    default = "1.0"
}
variable "min_capacity" {
    default = "0.5"
}
variable "db_count" {
    description = "Specify the amount of rds database instances you want to run"
    default = 2
}
variable "db_instance_class" {
  default = "db.t3.small"
}
variable "DBName"{
    default = "WPDatabase"
}
variable "DBPassword"{
    default = "12345678"
}
variable "DBUser"{
    default = "root"
}

######################
# Auto Scaling Group #
######################
variable "asg_desired"{
    description = "Autoscaling Group desired instances"
    default = 2
}
variable "asg_max"{
    description = "Autoscaling Group max instances"
    default = 6
}
variable "asg_min"{
    description = "Autoscaling Group min instances"
    default = 2
}
variable "up_cooldown" {
    description = "Upscaling cooldown in seconds"
    default = 300
}
variable "up_scaling_adjustment" {
    description = "Autoscaling Group scale up by how many instances at a time"
    default = 1
}
variable "up_threshold" {
  description = "Which CPU Utilization in % should trigger the upscaling adjustment?"
  default = 40
}
variable "actions_enabled_up" {
    description = "Do you want to enable automatic upscaling?"
    default = true
}
variable "down_cooldown" {
    description = "Sownscaling cooldown in seconds"
    default = 300
}
variable "down_scaling_adjustment" {
    description = "Autoscaling Group scale down by how many instances at a time"
    default = -1
}
variable "down_threshold" {
  description = "Which CPU Utilization in % should trigger the downscaling adjustment?"
  default = 5
}
variable "actions_enabled_down" {
    description = "Do you want to enable automatic downscaling?"
    default = true
}

##################
##### Subnets ####
##################
variable "cidr_privat1" {
  description = "Specify CIDR Range for private subnet 1"
  default = "10.0.1.0/24"
}
variable "cidr_privat2" {
  description = "Specify CIDR Range for private subnet 2"
  default = "10.0.2.0/24"
}
variable "cidr_public1" {
  description = "Specify CIDR Range for public subnet 1"
  default = "10.0.3.0/24"
}
variable "cidr_public2" {
  description = "Specify CIDR Range for public subnet 2"
  default = "10.0.4.0/24"
}
variable "cidr_db_privat1" {
  description = "Specify CIDR Range for database private subnet 1"
  default = "10.0.5.0/24"
}
variable "cidr_db_privat2" {
  description = "Specify CIDR Range for database private subnet 2"
  default = "10.0.6.0/24"
}

##################
### s3 Bucket ####
##################
# you have to change these values manually in the backup.py script
variable "s3bucketname" {
  default = "jellybelly1"
}

variable "s3backupbucketname" {
  default = "jellybellybackup1"
}