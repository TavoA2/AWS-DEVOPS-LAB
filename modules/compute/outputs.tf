output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.lab.id
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.lab.private_ip
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.lab.public_ip
}