module "networking" {
  source = "../../modules/networking"

  vpc_cidr    = var.vpc_cidr
  environment = var.environment
}

module "compute" {
  source = "../../modules/compute"

  environment = var.environment

  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.networking.web_security_group_id

  instance_type = "t3.micro"
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment   = var.environment
  instance_id   = module.compute.instance_id
  cpu_threshold = 20
}

module "loadbalancing" {
  source                = "../../modules/loadbalancing"
  web_security_group_id = module.networking.web_security_group_id

  environment       = "dev"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

module "autoscaling" {
  source = "../../modules/autoscaling"

  environment = var.environment

  ami_id        = module.compute.ami_id
  instance_type = "t3.micro"

  subnet_ids = module.networking.public_subnet_ids

  security_group_id = module.networking.web_security_group_id

  iam_instance_profile_name = module.compute.iam_instance_profile_name

  target_group_arn = module.loadbalancing.target_group_arn

  user_data_path = "${path.root}/../../modules/compute/user_data.sh"
}

module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment
}