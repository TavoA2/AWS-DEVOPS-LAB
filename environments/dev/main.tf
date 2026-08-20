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