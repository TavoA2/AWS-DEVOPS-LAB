resource "aws_ecr_repository" "app" {
  name                 = "${var.environment}-aws-devops-lab-web"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.environment}-aws-devops-lab-web"
    Environment = var.environment
    Project     = "aws-devops-lab"
    ManagedBy   = "terraform"
  }
}