terraform {
  backend "s3" {
    bucket       = "tavoa2-aws-devops-lab-tfstate"
    key          = "environments/dev/terraform.tfstate"
    region       = "us-east-1"

    use_lockfile = true
    encrypt      = true
  }
}