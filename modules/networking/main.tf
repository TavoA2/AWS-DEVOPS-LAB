data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-devops-lab-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-public-subnet-a"
    Environment = var.environment
    Type        = "public"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-public-subnet-b"
    Environment = var.environment
    Type        = "public"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "${var.environment}-private-subnet-a"
    Environment = var.environment
    Type        = "private"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name        = "${var.environment}-private-subnet-b"
    Environment = var.environment
    Type        = "private"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-devops-lab-igw"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
    Type        = "public"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = var.environment
    Type        = "private"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for public web traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
    Layer       = "web"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS from Internet"
}

resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Security group for application layer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
    Layer       = "application"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_web" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.web.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"

  description = "Allow application traffic from Web SG"
}


resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Security group for database layer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
    Layer       = "database"
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id = aws_security_group.db.id

  referenced_security_group_id = aws_security_group.app.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Allow PostgreSQL traffic from App SG"
}

#trivy:ignore:AWS-0104
resource "aws_vpc_security_group_egress_rule" "web_https_outbound" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS outbound traffic"
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-vpc-endpoints-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https_from_web" {
  security_group_id = aws_security_group.vpc_endpoints.id

  referenced_security_group_id = aws_security_group.web.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS from private web instances"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name        = "${var.environment}-s3-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name        = "${var.environment}-ecr-api-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name        = "${var.environment}-ecr-dkr-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name        = "${var.environment}-ssm-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name        = "${var.environment}-ssmmessages-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name        = "${var.environment}-ec2messages-endpoint"
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "aws-devops-lab"
  }
}