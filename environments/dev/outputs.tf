output "vpc_id" {
  description = "Development VPC ID"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "Development VPC CIDR"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "Development public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Development private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Development Internet Gateway ID"
  value       = module.networking.internet_gateway_id
}

output "public_route_table_id" {
  description = "Development public route table ID"
  value       = module.networking.public_route_table_id
}

output "private_route_table_id" {
  description = "Development private route table ID"
  value       = module.networking.private_route_table_id
}

output "web_security_group_id" {
  description = "Development web security group ID"
  value       = module.networking.web_security_group_id
}

output "app_security_group_id" {
  description = "Development application security group ID"
  value       = module.networking.app_security_group_id
}

output "db_security_group_id" {
  description = "Development database security group ID"
  value       = module.networking.db_security_group_id
}

output "ec2_instance_id" {
  description = "Development EC2 instance ID"
  value       = module.compute.instance_id
}

output "ec2_private_ip" {
  description = "Development EC2 private IP"
  value       = module.compute.private_ip
}

output "ec2_public_ip" {
  description = "Development EC2 public IP"
  value       = module.compute.public_ip
}

output "high_cpu_alarm_name" {
  description = "Development high CPU alarm"
  value       = module.monitoring.high_cpu_alarm_name
}

output "application_health_alarm_name" {
  description = "Development application health alarm"
  value       = module.monitoring.application_health_alarm_name
}

output "nginx_access_log_group_name" {
  description = "Nginx access CloudWatch Log Group"
  value       = module.monitoring.nginx_access_log_group_name
}

output "nginx_error_log_group_name" {
  description = "Nginx error CloudWatch Log Group"
  value       = module.monitoring.nginx_error_log_group_name
}

output "alb_dns_name" {
  description = "Development ALB DNS name"
  value       = module.loadbalancing.alb_dns_name
}

output "target_group_arn" {
  description = "Development target group ARN"
  value       = module.loadbalancing.target_group_arn
}

output "autoscaling_group_name" {
  description = "Development Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_name
}

output "launch_template_id" {
  description = "Development Launch Template ID"
  value       = module.autoscaling.launch_template_id
}

output "scaling_policy_name" {
  description = "Auto Scaling CPU target tracking policy"
  value       = module.autoscaling.scaling_policy_name
}