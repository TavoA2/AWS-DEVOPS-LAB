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