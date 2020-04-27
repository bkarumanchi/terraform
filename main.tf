wget -q https://releases.hashicorp.com/terraform/0.11.6/terraform_0.11.6_linux_amd64.zip


resource "aws_vpc" "Balaji_VPC" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy 
  enable_dns_support   = var.dnsSupport 
  enable_dns_hostnames = var.dnsHostNames
  tags = {
    Name = "Balaji VPC"
}
}


resource "aws_subnet" "Balaji_Subnet" {
  vpc_id                  = aws_vpc.Balaji_VPC.id
  cidr_block              = var.subnetCIDRblock
  map_public_ip_on_launch = var.mapPublicIP 
  availability_zone       = var.availabilityZone
tags = {
   Name = "Balaji Subnet"
}} 



resource "aws_security_group" "Balaji_Security_Group" {
  vpc_id       = aws_vpc.Balaji_VPC.id
  name         = "Balaji Security Group"
  description  = "Balaji Security Group"
  # allow ingress of port 22
  ingress {
    cidr_blocks = var.ingressCIDRblock  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "Balaji Security Group"
   Description = "Balaji Security Group"
}
} 


resource "aws_network_acl" "Balaji_Security_ACL" {
  vpc_id = aws_vpc.My_VPC.id
  subnet_ids = [ aws_subnet.Balaji_Subnet.id ]
  
  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 22
    to_port    = 22
  }
  
  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock 
    from_port  = 80
    to_port    = 80
  }
  
  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  
  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22 
    to_port    = 22
  }
  
  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80  
    to_port    = 80 
  }
  
  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "Balaji VPC ACL"
}
}


resource "aws_internet_gateway" "Balaji_VPC_GW" {
 vpc_id = aws_vpc.Balaji_VPC.id
 tags = {
        Name = "Balaji VPC Internet Gateway"
}

}


resource "aws_route_table" "Balaji_VPC_route_table" {
 vpc_id = aws_vpc.Balaji_VPC.id
 tags = {
        Name = "Balaji VPC Route Table"
}
}


resource "aws_route" "Balaji_VPC_internet_access" {
  route_table_id         = aws_route_table.Balaji_VPC_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.Balaji_VPC_GW.id
} 


resource "aws_route_table_association" "Balaji_VPC_association" {
  subnet_id      = aws_subnet.Balaji_Subnet.id
  route_table_id = aws_route_table.Balaji_VPC_route_table.id
}