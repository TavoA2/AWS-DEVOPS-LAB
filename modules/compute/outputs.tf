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

output "ami_id" {
  description = "AMI used by compute"
  value       = var.ami_id
}

output "iam_instance_profile_name" {
  description = "EC2 IAM instance profile name"
  value       = aws_iam_instance_profile.ec2_ssm.name
}