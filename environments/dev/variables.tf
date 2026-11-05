variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the development VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
  default     = "us-east-1"
}

variable "container_image_tag" {
  description = "Immutable ECR image tag to deploy"
  type        = string
  default     = "33e9b7793da0ad1711ead9f92832fa9781a6a9dc"
}

variable "ami_id" {
  description = "Pinned Amazon Linux AMI for the standalone dev EC2"
  type        = string
  default     = "ami-02b3d83d84b07786d"
}

variable "autoscaling_ami_id" {
  description = "AMI used by the web Auto Scaling Group"
  type        = string
  default     = "ami-006d891a2505139b9"
}

variable "lab_enabled" {
  description = "Enable the temporary AWS lab infrastructure"
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Enable Auto Scaling Group EC2 capacity"
  type        = bool
  default     = false
}

variable "enable_loadbalancer" {
  description = "Enable Application Load Balancer and related resources"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Create NAT Gateway, Elastic IP and private default route"
  type        = bool
  default     = false
}

variable "enable_interface_endpoints" {
  description = "Create paid VPC Interface Endpoints"
  type        = bool
  default     = false
}