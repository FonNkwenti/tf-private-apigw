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

  route {
    cidr_block = "172.128.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
  }
  tags = {
    Name = "private_rt_az1"
  }
}

#  create a route table associate between private_rt_az1 private_route_1 and private_sn_az1
resource "aws_route_table_association" "private_rta1_az1" {
  subnet_id      = aws_subnet.private_sn_az1.id
  route_table_id = aws_route_table.private_rt_az1.id
}


# create private subnet for az2
resource "aws_subnet" "private_sn_az2" {
  vpc_id                  = aws_vpc.api_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-sn-az2"
  }
}

# create route table for private subnet az2
resource "aws_route_table" "private_rt_az2" {
  vpc_id = aws_vpc.api_vpc.id

  route {
    cidr_block = "172.128.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
  }
  tags = {
    Name = "private_rt_az2"
  }
}

# create route table associate for private subnet az2
resource "aws_route_table_association" "private_rta_az2" {
  subnet_id      = aws_subnet.private_sn_az2.id
  route_table_id = aws_route_table.private_rt_az2.id
}



#########################################
# VPC Peeting with client VPC
#########################################
# create a vpc peering connection
resource "aws_vpc_peering_connection" "api_client_vpc_peering" {
  vpc_id        = aws_vpc.api_vpc.id
  peer_vpc_id   = aws_vpc.api_client_vpc.id
  auto_accept   = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = "api-client-vpc-peering",
    Side = "Requester"
  }
}


###########################################
# DNS resolution for private api endpoint
###########################################

# create route53 inbound resolver endpoint
resource "aws_route53_resolver_endpoint" "inbound_resolver_ep" {
  name = "private-api-inbound-resolver-endpoint"
  direction      = "INBOUND"
  security_group_ids = [aws_security_group.inbound_resolver_ep_sg.id]
  ip_address {
    subnet_id = aws_subnet.private_sn_az1.id
    ip = "10.0.1.10"
  }
  ip_address {
    subnet_id = aws_subnet.private_sn_az2.id
    ip = "10.0.2.10"
  }
  tags = {
    Name = "private-api-inbound-resolver-endpoint"

  }
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
resource "aws_vpc_endpoint" "ssm2_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssm"

  vpc_id              = aws_vpc.api_vpc.id
  security_group_ids  = [aws_security_group.ssm2_ep_sg.id]
  subnet_ids          = [aws_subnet.private_sn_az1.id]
  tags = {
    Name = "ssm2-endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm2_messages_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssmmessages"

  vpc_id              = aws_vpc.api_vpc.id
  security_group_ids  = [aws_security_group.ssm2_ep_sg.id]
  subnet_ids          = [aws_subnet.private_sn_az1.id]
  tags = {
    Name = "ssm2-messages-endpoint"
  }
}


resource "aws_vpc_endpoint" "ddb_ep" {
  service_name = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  vpc_id = aws_vpc.api_vpc.id
  route_table_ids = [aws_route_table.private_rt_az1.id]
    tags = {
    Name = "dynamodb-gateway-endpoint"
  }

}
resource "aws_vpc_endpoint" "s3_ep" {
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  vpc_id = aws_vpc.api_vpc.id
  route_table_ids = [aws_route_table.private_rt_az1.id]
    tags = {
    Name = "s3-gateway-endpoint"
  }

}