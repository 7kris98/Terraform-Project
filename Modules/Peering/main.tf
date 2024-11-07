provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc_peering_connection" "this" {
  count       = var.enable_vpc_peering ? 1 : 0
  vpc_id      = var.source_vpc_id
  peer_vpc_id = var.destination_vpc_id
  auto_accept = true # Set to false if peering across different AWS accounts

  tags = merge(
    var.default_tags,
    {
      Name = var.peer_vpc_name
    }
  )
}

resource "aws_vpc_peering_connection_options" "this" {
  count                     = var.enable_vpc_peering ? 1 : 0
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

# Route from source VPC to destination VPC
resource "aws_route" "source_to_dest_route" {
  route_table_id            = var.Nonprod_public_route_table
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id
}

resource "aws_route" "source_to_dest_route_private" {
  route_table_id            = var.Nonprod_private_route_table
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id
}

# Route from destination VPC to source VPC
resource "aws_route" "dest_to_source_route" {
  route_table_id            = var.Prod_private_route_table
  destination_cidr_block    = var.source_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this[0].id
}
