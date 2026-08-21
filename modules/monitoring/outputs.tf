output "high_cpu_alarm_name" {
  description = "Name of the high CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.alarm_name
}

output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.high_cpu.arn
}

output "application_health_alarm_name" {
  description = "Application health CloudWatch alarm name"
  value       = aws_cloudwatch_metric_alarm.application_unhealthy.alarm_name
}

output "nginx_access_log_group_name" {
  description = "CloudWatch Log Group for Nginx access logs"
  value       = aws_cloudwatch_log_group.nginx_access.name
}

output "nginx_error_log_group_name" {
  description = "CloudWatch Log Group for Nginx error logs"
  value       = aws_cloudwatch_log_group.nginx_error.name
}