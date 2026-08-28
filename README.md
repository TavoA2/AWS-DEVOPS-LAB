# AWS DevOps Lab

A hands-on AWS DevOps and Site Reliability Engineering lab designed to practice real-world infrastructure, automation, CI/CD, observability, security, high availability, and troubleshooting scenarios.

The infrastructure is managed with **Terraform**, while **GitHub Actions** provides continuous integration and uses **AWS OIDC federation** for keyless authentication.

> This project is intentionally built as a learning and troubleshooting environment. Infrastructure issues, IAM permission errors, networking problems, and CI/CD failures are investigated and resolved as part of the lab.

---

## Architecture

The current AWS environment includes:

- Multi-AZ VPC architecture
- Public and private subnets
- Internet Gateway and route tables
- Layered Security Groups
- EC2 instances
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- EC2 Launch Templates
- Nginx web servers
- AWS Systems Manager (SSM)
- CloudWatch metrics and alarms
- CloudWatch Logs
- Terraform remote state in Amazon S3
- GitHub Actions CI
- GitHub OIDC federation with AWS
- Least-privilege IAM policy for Terraform CI

### High-Level Architecture

```text
                         Internet
                            |
                            v
                  +---------------------+
                  | Application Load    |
                  | Balancer (ALB)      |
                  +----------+----------+
                             |
                    +--------+--------+
                    |                 |
                    v                 v
              +-----------+     +-----------+
              | EC2 / AZ-A|     | EC2 / AZ-B|
              |   Nginx   |     |   Nginx   |
              +-----------+     +-----------+
                    \                 /
                     \               /
                      +-------------+
                      | Auto Scaling|
                      |    Group    |
                      +-------------+

                           AWS VPC
                  +-----------------------+
                  | Public Subnets        |
                  | Private Subnets       |
                  | Multi-AZ Networking   |
                  +-----------------------+

                           |
                           v
                +----------------------+
                | CloudWatch           |
                | Metrics / Alarms     |
                | Logs                 |
                +----------------------+
```

---

## CI/CD Architecture

Pull requests targeting `main` trigger the Terraform CI workflow.

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
    +--> Terraform Format Check
    |
    +--> GitHub OIDC Token
    |
    +--> AWS STS
    |       |
    |       v
    |   AssumeRoleWithWebIdentity
    |
    +--> Temporary AWS Credentials
    |
    +--> Terraform Init
    |
    +--> Terraform Validate
    |
    +--> Terraform Plan
    |
    v
Pull Request Validation
```

The pipeline does **not store permanent AWS access keys in GitHub**.

Instead, GitHub Actions obtains an OIDC token and exchanges it with AWS STS for temporary credentials.

---

## Terraform Remote State

Terraform state is stored remotely in Amazon S3.

```text
S3 Backend
└── environments/
    └── dev/
        └── terraform.tfstate
```

The backend provides:

- Centralized Terraform state
- Server-side encryption
- S3 public access blocking
- State versioning
- S3 lockfile-based state locking

The backend infrastructure is bootstrapped independently from the main environment.

---

## High Availability and Scaling

The web tier runs behind an Application Load Balancer and an Auto Scaling Group distributed across multiple Availability Zones.

Current ASG configuration:

| Setting | Value |
|---|---:|
| Minimum capacity | 2 |
| Desired capacity | 2 |
| Maximum capacity | 4 |
| Health check | ELB |
| Scaling strategy | Target Tracking |
| CPU target | 50% |

The lab has been tested by generating CPU load and verifying that the Auto Scaling Group launches additional EC2 capacity.

---

## Observability

AWS CloudWatch provides infrastructure and application monitoring.

Implemented capabilities include:

- EC2 CPU monitoring
- Custom `ApplicationHealth` metric
- High CPU alarm
- Application health alarm
- Nginx access logs
- Nginx error logs
- CloudWatch Logs integration

Example monitoring flow:

```text
EC2 / Nginx
     |
     +---- Metrics ----> CloudWatch Metrics
     |
     +---- Logs -------> CloudWatch Logs
                              |
                              v
                        CloudWatch Alarms
```

---

## Security

Security controls currently implemented include:

- Layered Security Groups
- HTTP access to web instances restricted through the ALB
- IAM roles for EC2 workloads
- AWS Systems Manager for instance administration
- GitHub OIDC federation
- Temporary AWS STS credentials
- No permanent AWS credentials stored in GitHub
- S3 server-side encryption
- S3 public access blocking
- Custom IAM policy for Terraform CI
- `AdministratorAccess` removed from the GitHub Actions role

### CI Least-Privilege Model

```text
GitHub Actions
      |
      v
GitHub OIDC
      |
      v
AWS STS
      |
      v
github-actions-terraform-role
      |
      v
Custom Terraform CI Policy
      |
      +--> S3 State Access
      +--> EC2 Read
      +--> ELB Read
      +--> Auto Scaling Read
      +--> IAM Read
      +--> CloudWatch Read
      +--> CloudWatch Logs Read
```

The IAM policy was refined iteratively based on the AWS API operations Terraform requires during state refresh and planning.

This replaced the temporary `AdministratorAccess` policy used during initial development.

---

## Repository Structure

```text
aws-devops-lab/
│
├── .github/
│   └── workflows/
│       └── terraform-ci.yml
│
├── bootstrap/
│   ├── state-backend/
│   └── github-oidc/
│       └── terraform-ci-policy.tf
│
├── environments/
│   └── dev/
│       ├── backend.tf
│       ├── main.tf
│       ├── providers.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── modules/
│   ├── networking/
│   ├── compute/
│   ├── loadbalancing/
│   ├── autoscaling/
│   └── monitoring/
│
└── README.md
```

---

## Troubleshooting Scenarios

An important goal of this project is practicing real-world troubleshooting instead of only deploying infrastructure.

Issues encountered and resolved include:

- Terraform IAM `AccessDenied` errors
- Interrupted Terraform deployments
- AWS provider authentication issues
- Terraform backend authentication failures
- EC2 connectivity problems
- SSM `TargetNotConnected`
- ALB unhealthy targets
- Auto Scaling instance replacement loops
- Missing outbound connectivity during EC2 bootstrap
- Nginx installation failures caused by network connectivity
- Terraform formatting failures in CI
- GitHub OIDC `AssumeRoleWithWebIdentity` failures
- GitHub OIDC subject claim mismatch
- Local AWS CLI profile dependency inside CI
- Terraform remote-state authentication issues
- CloudWatch Logs IAM permission failures
- IAM Instance Profile permission failures
- CloudWatch alarm tag permission failures
- Iterative least-privilege IAM tuning

### Example: Auto Scaling Connectivity Incident

New EC2 instances created by the Auto Scaling Group initially failed ALB health checks and were repeatedly replaced.

Investigation identified that the instances did not receive public IP addresses while using public subnets without automatic public IP assignment.

Without outbound connectivity, instance bootstrap could not successfully install and configure Nginx.

The launch template networking configuration was corrected and the health-check grace period was adjusted.

Result:

```text
ASG
 |
 +--> EC2 AZ-A --> Healthy
 |
 +--> EC2 AZ-B --> Healthy
 |
 +--> ALB Target Group --> Healthy
```

### Example: GitHub OIDC Authentication Incident

GitHub Actions initially failed with:

```text
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

The issue was traced to a mismatch between the GitHub OIDC `sub` claim and the AWS IAM role trust policy.

The actual OIDC claims were inspected and the trust relationship was updated accordingly.

Result:

```text
GitHub Actions
      |
      v
OIDC Token
      |
      v
AWS STS
      |
      v
AssumeRoleWithWebIdentity
      |
      v
Temporary AWS Credentials
      |
      v
Terraform Plan
```

---

## Project Progress

| Ticket | Implementation | Status |
|---|---|:---:|
| 01 | AWS CLI and IAM Setup | ✅ |
| 02 | VPC | ✅ |
| 03 | Multi-AZ Subnets | ✅ |
| 04 | Internet Gateway and Route Tables | ✅ |
| 05 | Security Groups | ✅ |
| 06 | EC2 and IAM Role | ✅ |
| 07 | Nginx and User Data | ✅ |
| 08 | CloudWatch CPU Alarm | ✅ |
| 09 | Custom Application Health Metric | ✅ |
| 10 | CloudWatch Logs | ✅ |
| 11 | Application Load Balancer | ✅ |
| 12 | Auto Scaling Group | ✅ |
| 13 | GitHub Actions Terraform CI | ✅ |
| 14 | Terraform Remote State | ✅ |
| 15 | GitHub OIDC + Terraform Plan | ✅ |
| 16 | CI/CD IAM Least Privilege | ✅ |
| 17 | Terraform Security Scanning | ⏳ |

---

## CI Validation

Every pull request targeting `main` runs automated Terraform validation.

Current checks:

```text
terraform fmt -check
        |
        v
OIDC Authentication
        |
        v
terraform init
        |
        v
terraform validate
        |
        v
terraform plan
```

A pull request should only be merged after the CI checks pass.

---

## Local Development

### Requirements

- Terraform
- AWS CLI
- Git
- AWS account

Authenticate locally using an AWS CLI profile:

```powershell
$env:AWS_PROFILE = "terraform-lab"
```

Initialize the development environment:

```powershell
cd environments/dev
terraform init
```

Review changes:

```powershell
terraform plan
```

Apply changes when appropriate:

```powershell
terraform apply
```

> Local AWS profiles are not referenced directly inside the Terraform AWS provider. This keeps the configuration portable between local development and GitHub Actions.

---

## Development Workflow

Infrastructure changes follow a feature-branch workflow.

```text
main
  |
  +--> feature/<ticket>
          |
          +--> Terraform changes
          |
          +--> Local validation
          |
          +--> Commit / Push
          |
          +--> Pull Request
                    |
                    +--> CI checks
                    |
                    +--> Review
                    |
                    +--> Merge
```

---

## Next Steps

Planned improvements:

- Terraform security scanning
- CI security and quality gates
- Automated deployment strategy
- IAM policy hardening
- Cost monitoring and FinOps controls
- Containerized workloads
- Kubernetes
- GitOps
- Expanded observability
- Reliability testing
- Failure simulation and recovery exercises

---

## Skills Practiced

This project is designed to strengthen practical experience with:

- AWS
- Terraform
- Infrastructure as Code
- Linux
- Networking
- Git
- GitHub Actions
- CI/CD
- IAM
- OIDC
- AWS STS
- EC2
- Auto Scaling
- Application Load Balancers
- CloudWatch
- Systems Manager
- Observability
- High Availability
- Security
- Troubleshooting
- Site Reliability Engineering

---

## Project Goal

The goal of this repository is not simply to provision AWS resources.

It is intended to simulate the engineering lifecycle of a real cloud platform:

```text
Design
  ↓
Provision
  ↓
Automate
  ↓
Secure
  ↓
Observe
  ↓
Break
  ↓
Troubleshoot
  ↓
Improve
```

The environment evolves incrementally as new DevOps and SRE scenarios are introduced.