# Request a VPC peering connection from AWS Account A
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = var.b_vpc_id  # VPC ID in Account B
  vpc_id      = module.vpc.vpc_id       # VPC ID in Account A
  peer_owner_id = var.b_owner_id  # AWS account ID of Account B
  auto_accept = false
}

# Accept the VPC peering connection in Account B
resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
  provider                  = aws.remote  # Provider for Account B
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  auto_accept               = true
}

# Update route table in Account A to add route to VPC in Account B
resource "aws_route" "a_peer_route" {
  route_table_id         = module.vpc.vpc_main_route_table_id  # Route table ID in Account A
  destination_cidr_block = var.b_vpc_cidr  # CIDR block of the VPC in Account B
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

# Update route table in Account B to add route to VPC in Account A
resource "aws_route" "b_peer_route" {
  provider              = aws.remote  # Provider for Account B
  route_table_id        = module.vpc.vpc_main_route_table_id  # Route table ID in Account B
  destination_cidr_block = var.vpc_cidr  # CIDR block of the VPC in Account A
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}