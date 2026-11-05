module "networking" {
  source = "../../modules/networking"

  vpc_cidr    = var.vpc_cidr
  environment = var.environment
  aws_region  = var.aws_region

  enable_nat_gateway         = var.enable_nat_gateway
  enable_interface_endpoints = var.enable_interface_endpoints
}

module "compute" {
  source = "../../modules/compute"

  environment = var.environment

  create_instance = false

  ecr_repository_arn = module.ecr.repository_arn


  subnet_id         = module.networking.public_subnet_ids[0]
  security_group_id = module.networking.web_security_group_id

  instance_type = "t3.micro"

  ami_id = var.ami_id
}

module "monitoring" {
  source = "../../modules/monitoring"

  enable_alb_alarms = var.enable_loadbalancer

  environment   = var.environment
  instance_id   = module.compute.instance_id
  cpu_threshold = 20

  alb_arn_suffix          = module.loadbalancing.alb_arn_suffix
  target_group_arn_suffix = module.loadbalancing.target_group_arn_suffix
}

module "loadbalancing" {
  source = "../../modules/loadbalancing"

  enabled = var.enable_loadbalancer

  web_security_group_id = module.networking.web_security_group_id

  environment       = "dev"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
}

module "autoscaling" {
  lab_enabled = var.enable_autoscaling

  source = "../../modules/autoscaling"

  environment = var.environment

  ami_id        = var.autoscaling_ami_id
  instance_type = "t3.micro"

  subnet_ids = module.networking.private_subnet_ids

  security_group_id = module.networking.web_security_group_id

  iam_instance_profile_name = module.compute.iam_instance_profile_name

  target_group_arn = module.loadbalancing.target_group_arn

  aws_region      = var.aws_region
  ecr_registry    = split("/", module.ecr.repository_url)[0]
  container_image = "${module.ecr.repository_url}:${var.container_image_tag}"
}

module "ecr" {
  source = "../../modules/ecr"

  environment = var.environment
}

