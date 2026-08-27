output "terraform_state_bucket" {
  description = "S3 bucket containing Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}