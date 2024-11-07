# Default tags
variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  description = "Name prefix"
  default     = "nonprod"
}
# VPC CIDR range
variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Variable to signal the current environment 
variable "env" {
  default     = "Nonprod"
  type        = string
  description = "Deployment Environment"
}

# Public Subnet CIDRs
variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  description = "CIDR blocks for public subnets"
}

# Private Subnet CIDRs
variable "private_cidr_blocks" {
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
  description = "CIDR blocks for private subnets"
}

# Availability Zones
variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "List of availability zones for subnet placement"
}


# AMI ID for the EC2 instances
variable "ami_id" {
  type        = string
  description = "Amazon Machine Image ID for the EC2 instances"
  default     = "ami-06b21ccaeff8cd686" # Replace with the appropriate AMI ID
}

# Instance Type for the Web Servers and Bastion Host
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type for the web servers and bastion host"
}

# Key Pair for SSH Access
variable "key_pair" {
  type        = string
  description = "Name of the key pair to access EC2 instances via SSH"
  default     = "vockey"
}

# Elastic IP Allocation ID for the NAT Gateway
variable "eip_allocation_id" {
  default     = null
  type        = string
  description = "Elastic IP allocation ID for the NAT Gateway"
}

# Security Group for Bastion Host
variable "bastion_sg_name" {
  type        = string
  default     = "bastion-sg"
  description = "Security group name for the bastion host"
}

# Security Group for Web Servers
variable "web_sg_name" {
  type        = string
  default     = "web-sg"
  description = "Security group name for the web servers"
}

# Allowed CIDR for SSH Access to Bastion
variable "allowed_ssh_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR block allowed to SSH into the bastion host"
}

# NAT Gateway Enablement
variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Set to true to enable NAT Gateway for private subnets"
}
