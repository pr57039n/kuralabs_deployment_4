#Get all availability zones in region
data "aws_availability_zones" "azs" {}

#VPC
resource "aws_vpc" "my-vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
       "Name" : "my-vpc"
    }
}

# DATA
data "aws_availability_zones" "available" {
    state = "available"
}

# Subnet 1
resource "aws_subnet" "subnet1" {
    cidr_block = "172.16.0.0/18"
    vpc_id = aws_vpc.my-vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
}

# Internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.my-vpc.id
  
  tags = {
    "Name" = "network-gateway"
  }
}

# VPC Routing table
resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "routing_link_public" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_routing_table.id
}