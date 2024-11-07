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

# Create a new VPC 
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.default_tags, {
      Name = "NonProd-vpc"
    }
  )
}




# Add provisioning of the public subnet in the default VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}"
    }
  )
}

# Add provisioning of the private subnet in the default VPC
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index + 1}"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.default_tags, { Name = "${var.prefix}-igw" })
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.prefix}-public-route-table" }
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.prefix}-private-route-table" }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

# Conditionally allocate an Elastic IP only if no allocation ID is provided
resource "aws_eip" "nat_eip" {
  count = var.eip_allocation_id == null ? 1 : 0

  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-nat-eip"
    }
  )
}

# NAT Gateway with conditional allocation ID
resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_allocation_id != null ? var.eip_allocation_id : aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id # Assuming NAT Gateway is in the first public subnet

  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-nat-gateway"
    }
  )
}
# Route traffic from nonprod-private-subnet1 to the NAT Gateway
resource "aws_route" "private_subnet1_nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate nonprod-private-subnet1 with the private route table
resource "aws_route_table_association" "private_route_table_association_nonprod_private_subnet1" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[0].id # Assuming nonprod-private-subnet1 is at index 0
}


resource "aws_key_pair" "nonprod" {
  key_name   = "nonprod"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+KuDWAY0hMSoiX8p7Y11M/iXaxs/T2F+mJY8UsdM/6Ktnzs/xygXeC+twwSzzFC+j91S1M1gRYqLfnmwwXjThGEXhLknWQhQeEQzncm8zqpeR/7LghK8CsqqvzY174QxesDmS6P5/m7GwbWLdEtQAJxemg2PldxbOj+R10Kt8pirMnozh4cOBfPSJhzE+xUp9/ekhINgiZU4Z7nb412sZSQxbmF0NSVwfSaOZT+NSUMpL5cMtU6+SzmLGRiwsB/IiusWfYwnTE/9UNQ2tOEozTg/J6Xjrv39MgKsjjZt2yrW2iTqsnc/ANpwr/TnlwB/qbc4BZuqTVCQNCCyMU3b8fSSPwPdwUgUhaZCTb80uUJt9GPMioGUHD9GlsSLeX6z/sZAYUekqSaIcR36RVDRyQ1WLaV/EWJwAt4C248+gEEpzoO7ZexW/TpMMa3/pe9lx4MGYKtlC2cC+RpZOTILfzjzqlc2LtXS0uKgX0ANeB0jMtuy+lYp8PqxKPhjIhkal77lak/MMoORJZ78kKAwAbQT2Wu+ncyHiIIdRwen1LZFclXYnG4JH39DneWx0Np362pcpps+sl2LJ+PAKoZpiVx15R06Tsp9dXlQJjEn9eUXCslcBKUZpTpetmRgedB6BmJ0DprPP3B47Hxl+pNfaPLkPKlZn9xGvMqGPXUpf4Q== ec2-user@ip-172-31-84-101.ec2.internal"
}

# Create a bastion host in public subnet 2
resource "aws_instance" "bastion" {
  ami                         = var.ami_id # Make sure to replace this with a variable or AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet[1].id # Assuming public subnet 2 is at index 1
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.nonprod.key_name # Correct reference to the key name
  tags = merge(
    local.default_tags, {
      Name = "bastion-host"
    }
  )
}


# Create VM1 in private subnet 1
resource "aws_instance" "vm1" {
  ami                    = var.ami_id # Make sure to replace this with a variable or AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet[0].id # Assuming private subnet 1 is at index 0
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  key_name               = aws_key_pair.nonprod.key_name # Correct reference to the key name
  user_data              = <<-EOF
                                #!/bin/bash
                                sudo yum update -y
                                sudo yum install -y httpd
                                INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
                                echo "<html><body><h1>Krishna-$INSTANCE_IP-Non-Prod</h1></body></html>" > /var/www/html/index.html
                                sudo systemctl start httpd
                                sudo systemctl enable httpd
                                EOF

  tags = merge(
    local.default_tags, {
      Name = "NPVM1"
    }
  )
}

# Create VM2 in private subnet 2
resource "aws_instance" "vm2" {
  ami                    = var.ami_id # Make sure to replace this with a variable or AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnet[1].id # Assuming private subnet 2 is at index 1
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  key_name               = aws_key_pair.nonprod.key_name # Correct reference to the key name

  user_data = <<-EOF
                                #!/bin/bash
                                sudo yum update -y
                                sudo yum install -y httpd
                                INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
                                echo "<html><body><h1>Krishna-$INSTANCE_IP-Non-Prod</h1></body></html>" > /var/www/html/index.html
                                sudo systemctl start httpd
                                sudo systemctl enable httpd
                                EOF

  tags = merge(
    local.default_tags, {
      Name = "NPVM2"
    }
  )
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags, {
      Name = "bastion-sg"
    }
  )
}

# Security Group for VMs
resource "aws_security_group" "vm_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Allow access from bastion host's security group
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # Allow HTTP access from anywhere (you can restrict this if needed)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.default_tags, {
      Name = "vm-sg"
    }
  )
}

