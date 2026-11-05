packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1.4"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami" {
  type    = string
  default = "ami-02b3d83d84b07786d"
}

variable "subnet_id" {
  type    = string
  default = "subnet-07de8faf99f94eafa"
}

source "amazon-ebs" "al2023-docker" {
  region        = var.aws_region
  instance_type = "t3.micro"

  source_ami   = var.source_ami
  ssh_username = "ec2-user"

  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  temporary_security_group_source_public_ip = true

  ami_name        = "aws-devops-lab-docker-{{timestamp}}"
  ami_description = "Amazon Linux 2023 with Docker preinstalled for NAT-independent EC2 bootstrap"

  tags = {
    Project     = "aws-devops-lab"
    Environment = "dev"
    CreatedBy   = "packer"
    Ticket      = "29"
  }
}

build {
  name    = "golden-docker-image"
  sources = ["source.amazon-ebs.al2023-docker"]

  provisioner "shell" {
    inline = [
      "sudo dnf install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",

      "echo '=== Docker ==='",
      "sudo docker --version",

      "echo '=== Docker enabled ==='",
      "sudo systemctl is-enabled docker",

      "echo '=== AWS CLI ==='",
      "aws --version"
    ]
  }
}