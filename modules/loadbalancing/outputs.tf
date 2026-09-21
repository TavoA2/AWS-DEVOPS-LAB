output "alb_security_group_id" {
  description = "Security Group ID of the Application Load Balancer"
  value = one(aws_security_group.alb[*].id)
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value = one(aws_lb.main[*].dns_name)
}

output "target_group_arn" {
  description = "ARN of the web target group"
  value = one(aws_lb_target_group.web[*].arn)
}

output "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metrics"
  value = one(aws_lb.main[*].arn_suffix)
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group for CloudWatch metrics"
  value = one(aws_lb_target_group.web[*].arn_suffix)
  }