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

# create a vpc endpoint for the execute-api
resource "aws_vpc_endpoint" "execute_api_ep" {
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  vpc_id       = aws_vpc.api_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.execute-api"
  security_group_ids = [aws_security_group.endpoint_sg.id]
  subnet_ids = [aws_subnet.public_sn_az1.id]
  tags = {
    Name = "execute-api"
  }
}

# create vpc endpoint policy using the aws_vpc_endpoint_policy resource for the execute-api interface endpoint 


resource "aws_vpc_endpoint_policy" "execute_api_ep_policy" {
  vpc_endpoint_id = aws_vpc_endpoint.execute_api_ep.id

policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "*",
        "Resource" : "*"
      }
    ]
  })
}
# resource "aws_vpc_endpoint_policy" "execute_api_ep_policy" {
#   vpc_endpoint_id = aws_vpc_endpoint.execute_api_ep.id

# policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Sid" : "AllowAll",
#         "Effect" : "Allow",
#         "Principal" : {
#           "AWS" : "*"
#         },
#         "Action" : [
#           "execute-api:Invoke"
#         ],
#         "Resource" : "*"
#       }
#     ]
#   })
# }