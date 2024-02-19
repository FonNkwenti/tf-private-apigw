resource "aws_vpc" "api_vpc" {
    cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "api-vpc"
  }
  
}

resource "aws_internet_gateway" "api_vpc_igw"  {
    vpc_id = aws_vpc.api_vpc.id
  tags = {
    Name = "api-vpc-igw"
  }
  
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_sn_az1" {
    vpc_id = aws_vpc.api_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = true
    tags = {
        Name = "public-sn-az1"
    }
}
  

resource "aws_route_table" "public_sn_rt" {
  vpc_id = aws_vpc.api_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.api_vpc_igw.id
    }
        tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_rta_az1" {
  subnet_id = aws_subnet.public_sn_az1.id
  route_table_id = aws_route_table.public_sn_rt.id
  
}

# resource "aws_subnet" "private_sn_az1" {
#     vpc_id = aws_vpc.api_vpc.id
#     cidr_block = "10.0.1.0/24"
#     availability_zone = data.aws_availability_zones.available.names[0]
#     map_public_ip_on_launch = false
#     tags = {
#         Name = "private-sn-az1"
#     }
# }

# resource "aws_route_table" "private_rt_az1" {
#   vpc_id = aws_vpc.api_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.natgw_az1.id
#   }
#   tags   = {
#     Name = "Private Route Table AZ1"
#   }
# }

# #  create a route table associate between private_rt_az1 private_route_1 and private_sn_az1
# resource "aws_route_table_association" "private_rta1_az1" {
#   subnet_id = aws_subnet.private_sn_az1.id
#   route_table_id = aws_route_table.private_rt_az1.id
# }