variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region where networking resources are deployed"
  type        = string
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