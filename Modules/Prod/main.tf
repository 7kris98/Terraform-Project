# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  default_tags = merge(
    var.default_tags,
    { "Env" = var.env }
  )
}


# Create a new VPC for prod
resource "aws_vpc" "prod" {
  cidr_block       = var.prod_vpc_cidr
  instance_tenancy = "default"
    enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags, {
      Name = "Prod-vpc"
    }
  )

}



resource "aws_key_pair" "prod" {
  key_name   = "prod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+GxSEHQt62N5wSQ3N0GQmsq8SCVVmwKPUAoFSOU9N0m+5HBb4l/2ILcltPNI2dyC7q7dbfryVBHUYmhhfw0GijKECr0AXoDBp+CZqhJIK7XvhuoIBD2uS89E1Uq7pDF380T62PoefQlMnznubc2PBR8Uo1HRmrgBHQE1RK1TLLefcBz0QUSQ1Hd2dLiaGwjuN8vkqlSA+5E0g+30E4RP4z2sN9ZYsWCeHyb0jXWbJ5Nau0gW7PVpNiXHqr+3IDRwnqeUAB+91VwDBUn8MOGC5NuGYb419TeaE5qLIM5mMqB9MUAPxciumiJZxBF6yYjSEMoWOLLB1nIubv8k5VwRL ec2-user@ip-172-31-84-101.ec2.internal"
}

# Add provisioning of the private subnet in the prod VPC
resource "aws_subnet" "prod_private_subnet" {
  count             = length(var.prod_private_cidr_blocks)
  vpc_id            = aws_vpc.prod.id
  cidr_block        = var.prod_private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-prod-private-subnet-${count.index + 1}"
    }
  )
}

# Create Internet Gateway for prod VPC
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod.id
  tags   = merge(local.default_tags, { Name = "${var.prefix}-prod-igw" })
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "prod_private_route_table" {
  vpc_id = aws_vpc.prod.id
  tags   = { Name = "${var.prefix}-private-route-table" }
}

resource "aws_route_table_association" "prod_private_route_table_association" {
  count          = length(aws_subnet.prod_private_subnet[*].id)
  route_table_id = aws_route_table.prod_private_route_table.id
  subnet_id      = aws_subnet.prod_private_subnet[count.index].id
}

# Creation of VM1 in private subnet 1
resource "aws_instance" "vm1" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.prod_private_subnet[0].id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = aws_key_pair.prod.key_name # Ensure you're using the correct key pair
  tags = merge(
    local.default_tags, {
      Name = "PVM1"
    }
  )
}

# Creation of VM2 in private subnet 2
resource "aws_instance" "vm2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.prod_private_subnet[1].id
  vpc_security_group_ids = [aws_security_group.prod_web_sg.id]
  key_name               = aws_key_pair.prod.key_name # Ensure you're using the correct key pair
  tags = merge(
    local.default_tags, {
      Name = "PVM2"
    }
  )
}

# Security Group for prod VMs
resource "aws_security_group" "prod_web_sg" {
  vpc_id = aws_vpc.prod.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere, consider restricting this
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags, {
      Name = "prod-web-sg"
    }
  )
}

