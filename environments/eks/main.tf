data "terraform_remote_state" "dev" {
  backend = "s3"

  config = {
    bucket = "tavoa2-aws-devops-lab-tfstate"
    key    = "environments/dev/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_id = data.terraform_remote_state.dev.outputs.vpc_id

  public_subnet_ids = (
    data.terraform_remote_state.dev.outputs.public_subnet_ids
  )

  private_subnet_ids = (
    data.terraform_remote_state.dev.outputs.private_subnet_ids
  )
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = "devops-lab-eks"

  vpc_id          = local.vpc_id
  subnet_ids      = local.public_subnet_ids
  node_subnet_ids = local.public_subnet_ids
  cluster_version = "1.36"

  instance_types = ["m7i-flex.large"]

  desired_size = 1
  min_size     = 1
  max_size     = 2

  allowed_public_cidrs = ["201.207.52.147/32"]
}