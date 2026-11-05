variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID for instance-specific alarms"
  type        = string
  nullable    = true
}

variable "cpu_threshold" {
  description = "CPU threshold percentage"
  type        = number
  default     = 20
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer"
  type        = string
  default     = null
  nullable    = true
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group"
  type        = string
  default     = null
  nullable    = true
}
variable "enable_alb_alarms" {
  description = "Enable CloudWatch alarms associated with the ALB"
  type        = bool
  default     = true
}