variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "terraform-lab"
}

variable "bucket_name" {
  description = "S3 bucket used for Terraform remote state"
  type        = string
}