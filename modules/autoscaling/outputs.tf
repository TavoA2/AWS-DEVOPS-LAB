output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.web.name
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.web.id
}

output "scaling_policy_name" {
  description = "CPU target tracking scaling policy name"
  value       = aws_autoscaling_policy.cpu_target_tracking.name
}
