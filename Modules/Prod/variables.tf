# Default tags
variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  description = "Name prefix"
  default     = "prod"
}

# VPC CIDR range
variable "prod_vpc_cidr" {
  default     = "10.10.0.0/16"
  type        = string
  description = "VPC to host static web site"
}

# Variable to signal the current environment 
variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}

# Private Subnet CIDRs
variable "prod_private_cidr_blocks" {
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
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
  default     = "ami-06b21ccaeff8cd686"
}

# Instance Type for the Web Servers and Bastion Host
variable "prod_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type for the web servers and bastion host"
}

# Key Pair for SSH Access
variable "key_pair" {
  type        = string
  description = "Name of the key pair to access EC2 instances via SSH"
  default     = "prod"
}


