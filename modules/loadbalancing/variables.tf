variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets where the ALB will be deployed"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group ID attached to the web EC2 instance"
  type        = string
}