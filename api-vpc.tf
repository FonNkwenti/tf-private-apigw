resource "aws_vpc" "api_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "api-vpc"
  }

}

resource "aws_internet_gateway" "api_vpc_igw" {
  vpc_id = aws_vpc.api_vpc.id
  tags = {
    Name = "api-vpc-igw"
  }

}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_sn_az1" {
  vpc_id                  = aws_vpc.api_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
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
  subnet_id      = aws_subnet.public_sn_az1.id
  route_table_id = aws_route_table.public_sn_rt.id

}

# resource "aws_eip" "az1_eip_1" {
#   domain = "vpc"

#   tags = {
#     Name = "EIP for AZ1"
#   }

# }
# resource "aws_nat_gateway" "natgw_az1" {
#   subnet_id = aws_subnet.public_sn_az1.id
#   connectivity_type = "public"
#   allocation_id = aws_eip.az1_eip_1.id

#   tags = {
#     Name = "natgw-az1"
#   }
#   depends_on = [aws_internet_gateway.api_vpc_igw]
# }

resource "aws_subnet" "private_sn_az1" {
  vpc_id                  = aws_vpc.api_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-sn-az1"
  }
}

resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.api_vpc.id
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.natgw_az1.id
  # }
  tags = {
    Name = "Private Route Table AZ1"
  }
}

#  create a route table associate between private_rt_az1 private_route_1 and private_sn_az1
resource "aws_route_table_association" "private_rta1_az1" {
  subnet_id      = aws_subnet.private_sn_az1.id
  route_table_id = aws_route_table.private_rt_az1.id
}




##################################
# VPC Endpoint for private API
##################################

# create a vpc endpoint for the execute-api
resource "aws_vpc_endpoint" "execute_api_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.api_vpc.id
  service_name        = "com.amazonaws.${var.region}.execute-api"
  security_group_ids  = [aws_security_group.execute_api_ep_sg.id]
  subnet_ids          = [aws_subnet.private_sn_az1.id]
  tags = {
    Name = "execute-api-endpoint"
  }
}



resource "aws_vpc_endpoint_policy" "execute_api_ep_policy" {
  vpc_endpoint_id = aws_vpc_endpoint.execute_api_ep.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "execute-api:Invoke"
        ],
        "Resource" : "*"
      }
    ]
  })
}

#####################################
# create a vpc endpoint for the SSM Manager private access
#####################################
resource "aws_vpc_endpoint" "ssm_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.api_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  security_group_ids  = [aws_security_group.ssm_ep_sg.id]
  subnet_ids          = [aws_subnet.private_sn_az1.id]
  tags = {
    Name = "ssm-endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm_messages_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.api_vpc.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  security_group_ids  = [aws_security_group.ssm_ep_sg.id]
  subnet_ids          = [aws_subnet.private_sn_az1.id]
  tags = {
    Name = "ssm-messages-endpoint"
  }
}
# resource "aws_vpc_endpoint" "ec2_messages_ep" {
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true
#   vpc_id              = aws_vpc.api_vpc.id
#   service_name        = "com.amazonaws.${var.region}.ec2messages"
#   security_group_ids  = [aws_security_group.ssm_ep_sg.id]
#   subnet_ids          = [ aws_subnet.private_sn_az1.id]
#   tags = {
#     Name = "ec2-messages-endpoint"
#   }
# }

resource "aws_vpc_endpoint" "ddb_ep" {
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_id = aws_vpc.api_vpc.id
  vpc_endpoint_type = "Gateway"
    tags = {
    Name = "dynamodb-gateway-endpoint"
  }

}