variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet where the EC2 instance will run"
  type        = string
}

variable "security_group_id" {
  description = "Security group attached to the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository that EC2 instances can pull images from"
  type        = string
}

variable "ami_id" {
  description = "AMI ID used by EC2 instances"
  type        = string
}