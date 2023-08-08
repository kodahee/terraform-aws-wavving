provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project = "wavving"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.address_space
  enable_dns_hostnames = true

  tags = {
    name = "${var.prefix}-vpc-${var.region}"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[0]

  availability_zone = "ap-northeast-2a"

  map_public_ip_on_launch = true

  tags = {
    name = "${var.prefix}-subnet-1"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/eks-prod-wavving-cluster"= "shared"
    "kubernetes.io/cluster/eks-dev-wavving-cluster"= "shared"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[1]

  availability_zone = "ap-northeast-2c"

  tags = {
    name = "${var.prefix}-subnet-2"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/eks-prod-wavving-cluster"= "shared"
    "kubernetes.io/cluster/eks-dev-wavving-cluster"= "shared"
  }
}

resource "aws_subnet" "private-subnet-3" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[2]

  availability_zone = "ap-northeast-2a"

  tags = {
    name = "${var.prefix}-subnet-3"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/eks-prod-wavving-cluster"= "shared"
    "kubernetes.io/cluster/eks-dev-wavving-cluster"= "shared"
  }
}

resource "aws_subnet" "private-subnet-4" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[3]

  availability_zone = "ap-northeast-2c"

  tags = {
    name = "${var.prefix}-subnet-4"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/eks-prod-wavving-cluster"= "shared"
    "kubernetes.io/cluster/eks-dev-wavving-cluster"= "shared"
  }
}

resource "aws_subnet" "private-subnet-5" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[4]

  availability_zone = "ap-northeast-2a"

  tags = {
    name = "${var.prefix}-subnet-5"
  }
}

resource "aws_subnet" "private-subnet-6" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[5]

  availability_zone = "ap-northeast-2c"

  tags = {
    name = "${var.prefix}-subnet-6"
  }
}

resource "aws_security_group" "sg" {
  name = "${var.prefix}-security-group"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.internet_gateway}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.internet_gateway}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.internet_gateway}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.internet_gateway}"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-internet-gateway"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-public"
  }
}

resource "aws_route_table" "rt_private_3" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-private-3"
  }
}

resource "aws_route_table" "rt_private_4" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-private-4"
  }
}

resource "aws_route_table" "rt_private_5" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-private-5"
  }
}

resource "aws_route_table" "rt_private_6" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-private-6"
  }
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.rt.id
  destination_cidr_block = "${var.internet_gateway}"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rt-association-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt-association-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt-association-3" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.rt_private_3.id
}

resource "aws_route_table_association" "rt-association-4" {
  subnet_id      = aws_subnet.private-subnet-4.id
  route_table_id = aws_route_table.rt_private_4.id
}

resource "aws_route_table_association" "rt-association-5" {
  subnet_id      = aws_subnet.private-subnet-5.id
  route_table_id = aws_route_table.rt_private_5.id
}

resource "aws_route_table_association" "rt-association-6" {
  subnet_id      = aws_subnet.private-subnet-6.id
  route_table_id = aws_route_table.rt_private_6.id
}

resource "aws_route" "private_nat_3" {
  route_table_id              = aws_route_table.rt_private_3.id
  destination_cidr_block      = "${var.internet_gateway}"
  nat_gateway_id              = aws_nat_gateway.nat-gw-1.id
}

resource "aws_route" "private_nat_4" {
  route_table_id              = aws_route_table.rt_private_4.id
  destination_cidr_block      = "${var.internet_gateway}"
  nat_gateway_id              = aws_nat_gateway.nat-gw-2.id
}

resource "aws_route" "private_nat_5" {
  route_table_id              = aws_route_table.rt_private_5.id
  destination_cidr_block      = "${var.internet_gateway}"
  nat_gateway_id              = aws_nat_gateway.nat-gw-1.id
}

resource "aws_route" "private_nat_6" {
  route_table_id              = aws_route_table.rt_private_6.id
  destination_cidr_block      = "${var.internet_gateway}"
  nat_gateway_id              = aws_nat_gateway.nat-gw-2.id
}

resource "aws_eip" "eip-1" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "eip-2" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat-gw-1" {
  allocation_id = aws_eip.eip-1.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "${var.prefix}-nat-gateway-1"
  }
}

resource "aws_nat_gateway" "nat-gw-2" {
  allocation_id = aws_eip.eip-2.id
  subnet_id     = aws_subnet.public-subnet-2.id

  tags = {
    Name = "${var.prefix}-nat-gateway-2"
  }
}

#########################################################################################

resource "aws_vpc_endpoint" "vpc_ep" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-northeast-2.ecr.dkr"    # ecr dkr
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_ep.id,
  ]

  private_dns_enabled = true
}

resource "aws_subnet" "private_subnet_ep" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_prefix[6]

  availability_zone = "ap-northeast-2a"

  tags = {
    name = "${var.prefix}-subnet-ep"
  }
}

resource "aws_security_group" "sg_ep" {
  name = "${var.prefix}-security-group-ep"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.internet_gateway}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.internet_gateway}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["${var.internet_gateway}"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.prefix}-security-group-ep"
  }
}

resource "aws_route_table" "rt_ep" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-public-ep"
  }
}

resource "aws_route" "private_nat_ep" {
  route_table_id              = aws_route_table.rt_ep.id
  destination_cidr_block      = "${var.internet_gateway}"
  nat_gateway_id              = aws_nat_gateway.nat-gw-1.id
}

resource "aws_route_table_association" "rt-association-ep" {
  subnet_id      = aws_subnet.private_subnet_ep.id
  route_table_id = aws_route_table.rt_ep.id
}

resource "aws_vpc_endpoint_subnet_association" "sn_ec2" {
  vpc_endpoint_id = aws_vpc_endpoint.vpc_ep.id
  subnet_id       = aws_subnet.private_subnet_ep.id
}