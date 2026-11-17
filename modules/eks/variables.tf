variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets used by the EKS cluster"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnets used by the managed node group"
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "allowed_public_cidrs" {
  description = "Public CIDRs authorized to access the EKS API"
  type        = list(string)
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
}