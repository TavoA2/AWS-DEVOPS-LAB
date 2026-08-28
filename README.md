# AWS DevOps Lab

Hands-on AWS DevOps and Site Reliability Engineering lab built to practice
real-world infrastructure, automation, CI/CD, observability, security,
high availability, and troubleshooting scenarios.

The infrastructure is managed with Terraform and uses GitHub Actions for
continuous integration and AWS OIDC for keyless authentication.

## Architecture

Current architecture includes:

- AWS VPC with public and private subnets across multiple Availability Zones
- Internet Gateway and route tables
- Security Groups with layered access
- EC2 instances
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- EC2 Launch Templates
- Nginx web servers
- AWS Systems Manager (SSM)
- CloudWatch metrics, alarms, and logs
- Terraform remote state stored in Amazon S3
- GitHub Actions CI
- GitHub OIDC authentication to AWS

## CI/CD Workflow

Pull Requests targeting `main` trigger the Terraform CI pipeline.

```text
Developer
    |
    v
Feature Branch
    |
    v
Pull Request
    |
    v
GitHub Actions
    |
    +--> terraform fmt -check
    |
    +--> GitHub OIDC Token
    |
    +--> AWS STS AssumeRoleWithWebIdentity
    |
    +--> Temporary AWS Credentials
    |
    +--> terraform init
    |
    +--> terraform validate
    |
    +--> terraform plan
    |
    v
Pull Request Validation