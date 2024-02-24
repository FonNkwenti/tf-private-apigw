resource "aws_vpc" "api_client_vpc" {
    cidr_block = "172.128.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "api-client-vpc"
    }
}


resource "aws_subnet" "api_client_pri_sn_az1" {
    vpc_id                 = aws_vpc.api_client_vpc.id
    cidr_block             = "172.128.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false

    tags = {
        Name = "api-client-subnet"
    }
  
}

resource "aws_route_table" "api_client_rt_az1" {
    vpc_id = aws_vpc.api_client_vpc.id

    route {
        cidr_block = "10.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
    }

    tags = {
        Name = "api-client-rt-az1"
    }
  
}

# create private aws subnet for az2
resource "aws_subnet" "api_client_pri_sn_az2" {
    vpc_id                 = aws_vpc.api_client_vpc.id
    cidr_block             = "172.128.2.0/24"
    availability_zone = data.aws_availability_zones.available.names[1]
    map_public_ip_on_launch = false

    tags = {
        Name = "api-client-subnet-az2"
    }
  
}

# create route table for private subnet az2
resource "aws_route_table" "api_client_rt_az2" {
    vpc_id = aws_vpc.api_client_vpc.id

    route {
        cidr_block = "10.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
    }

    tags = {
        Name = "api-client-rt-az2"
    }
  
}

# create route table association for private subnet az2
resource "aws_route_table_association" "api_client_rta2_az2" {
    subnet_id = aws_subnet.api_client_pri_sn_az2.id
    route_table_id = aws_route_table.api_client_rt_az2.id
}
# create route table association
resource "aws_route_table_association" "api_client_rta1_az1" {
    subnet_id = aws_subnet.api_client_pri_sn_az1.id
    route_table_id = aws_route_table.api_client_rt_az1.id
}

# create a VPC peering connection accepter
resource "aws_vpc_peering_connection_accepter" "api_client_vpc_peering" {
  vpc_peering_connection_id = aws_vpc_peering_connection.api_client_vpc_peering.id
  auto_accept               = true

    tags = {
    Name = "api-client-vpc-peering",
    Side = "Accepter"
  }
}

resource "aws_vpc_peering_connection" "api_client_vpc_peering" {
  vpc_id        = aws_vpc.api_client_vpc.id
  peer_vpc_id   = aws_vpc.api_vpc.id
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

# create route53 outbound resolver endpoint

resource "aws_route53_resolver_endpoint" "api_client_resolver_endpoint" {
    name      = "api-client-resolver-endpoint"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.api_client_resolver_endpoint_sg.id]

  ip_address {
    subnet_id = aws_subnet.api_client_pri_sn_az1.id
  }

  ip_address {
    subnet_id = aws_subnet.api_client_pri_sn_az2.id
  }

  tags = {
    Name = "api-client-resolver-endpoint"
  }
}

# create route53 resolver rule
resource "aws_route53_resolver_rule" "api_client_resolver_rule" {
  domain_name = var.api_domain_name
  name        = "api-client-resolver-rule"
  rule_type   = "FORWARD"
  resolver_endpoint_id = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX.api_client_resolver_endpoint.id

  target_ip {
    ip = var.api_endpoint_ip
  }

  tags = {
    Name = "api-client-resolver-rule"
  }
}



###########################################
# SSM endpoints to access EC2 instances in private subnet
###########################################
resource "aws_vpc_endpoint" "ssm_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_id              = aws_vpc.api_client_vpc.id
  subnet_ids          = [aws_subnet.api_client_pri_sn_az1.id]
  security_group_ids  = [aws_security_group.ssm_ep_sg.id]
  tags = {
    Name = "ssm-endpoint"
  }
}
resource "aws_vpc_endpoint" "ssm_messages_ep" {
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_id              = aws_vpc.api_client_vpc.id
  subnet_ids          = [aws_subnet.api_client_pri_sn_az1.id]
  security_group_ids  = [aws_security_group.ssm_ep_sg.id]
  tags = {
    Name = "ssm-messages-endpoint"
  }
}