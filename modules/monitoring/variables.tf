variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU threshold percentage"
  type        = number
  default     = 20
}