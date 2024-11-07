variable "source_vpc_id" {
  description = "The VPC ID of the Non-Prod environment"
  type        = string
  default     = "vpc-097478adf2490f6a7"
}

variable "destination_vpc_id" {
  description = "The VPC ID of the Prod environment"
  type        = string
  default     = "vpc-0538cc83feb3e8411"
}

variable "Nonprod_public_route_table" {
  description = "Public Route table ID for the Non-Prod VPC"
  type        = string
  default     = "rtb-0f73fe460942de0b9"
}

variable "Nonprod_private_route_table" {
  description = "Private Route table ID for the Non-Prod VPC"
  type        = string
  default     = "rtb-09c3b8c3bcc0e22c2"
}

variable "Prod_private_route_table" {
  description = "Private Route table ID for the Prod VPC"
  type        = string
  default     = "rtb-0213dee475b572ebf"
}

variable "source_cidr_block" {
  description = "CIDR block of the Non-Prod VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "destination_cidr_block" {
  description = "CIDR block of the Prod VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "enable_vpc_peering" {
  description = "Enable or disable VPC peering connection"
  type        = bool
  default     = true
}

variable "peer_vpc_name" {
  description = "Name tag for the VPC peering connection"
  type        = string
  default     = "VPC-Peering"
}

variable "default_tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)
  default = {
    "Environment" = "Production"
  }
}
