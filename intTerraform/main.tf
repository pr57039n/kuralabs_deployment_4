variable "aws_access_key" {}
variable "aws_secret_key" {}


provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
  
}

data "aws_availability_zones" "azs" {}

#VPC
resource "aws_vpc" "my-vpc" {
    cidr_block = "172.16.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
       "Name" : "my-vpc"
    }
}

# Subnet 1
resource "aws_subnet" "subnet1" {
    cidr_block = "172.16.0.0/18"
    vpc_id = aws_vpc.my-vpc.id
    map_public_ip_on_launch = "true"
    availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_instance" "web_server01" {
  ami = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
  key_name = "DeploymentKey"
  vpc_security_group_ids = [aws_security_group.web_ssh.id]
  subnet_id = aws_subnet.subnet1.id
  user_data = "${file("deploy.sh")}"

  tags = {
    "Name" : "Webserver001"
  }
  
}

output "instance_ip" {
  value = aws_instance.web_server01.public_ip
  
}
