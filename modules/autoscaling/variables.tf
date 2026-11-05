variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "Subnets for the Auto Scaling Group"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for ASG instances"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile attached to ASG instances"
  type        = string
}

variable "aws_region" {
  description = "AWS region used to authenticate with ECR"
  type        = string
}

variable "ecr_registry" {
  description = "Amazon ECR registry hostname"
  type        = string
}

variable "container_image" {
  description = "Full ECR image URI including immutable tag"
  type        = string
}

variable "lab_enabled" {
  description = "Enable EC2 capacity and CPU autoscaling"
  type        = bool
  default     = true
}

variable "target_group_arn" {
  description = "Optional ALB target group ARN"
  type        = string
  default     = null
  nullable    = true
}