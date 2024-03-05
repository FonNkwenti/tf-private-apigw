resource "aws_vpc" "api_client_vpc" {
    cidr_block = "172.128.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "client-vpc"
    }
}


resource "aws_subnet" "api_client_pri_sn_az1" {
    vpc_id                 = aws_vpc.api_client_vpc.id
    cidr_block             = "172.128.1.0/24"
    availability_zone = data.aws_availability_zones.available.names[0]
    map_public_ip_on_launch = false

    tags = {
        Name = "api-client-subnet-az1"
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


#/*
###########################################
# DNS resolution for private api endpoint
###########################################

resource "aws_route53_resolver_endpoint" "outbound_resolver_ep" {

  name      = "private-api-outbound-resolver-endpoint"
  direction = "OUTBOUND"
  security_group_ids = [aws_security_group.outbound_resolver_ep_sg.id]

  ip_address {
    subnet_id = aws_subnet.api_client_pri_sn_az1.id
    ip        = "172.128.1.10"
  }

  ip_address {
    subnet_id = aws_subnet.api_client_pri_sn_az2.id
    ip        = "172.128.2.10"
  }

  tags = {
    Name = "private-api-resolver-endpoint"
  }
}


# create route53 resolver rule
resource "aws_route53_resolver_rule" "private_api_resolver_rule" {
  name        = "private-api-resolver-rule"
  domain_name = var.private_api_domain_name
  rule_type   = "FORWARD"
  
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_resolver_ep.id
  target_ip     {
    ip = "10.0.0.2"
  }
  target_ip     {
    ip = "10.0.1.10"
  }
  target_ip     {
    ip = "10.0.2.10"
  }

  depends_on = [ aws_route53_resolver_endpoint.outbound_resolver_ep ]
  tags = {
    Name = "private-api-resolver-rule"
  }
}

# create route53 resolver rule association with client_vpc
resource "aws_route53_resolver_rule_association" "private_api_resolver_rule_assoc" {
  resolver_rule_id = aws_route53_resolver_rule.private_api_resolver_rule.id
  vpc_id = aws_vpc.api_client_vpc.id
}
#*/


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


/*
###########################################
# private zone for private API as an alternative to using inbound and outbound Route53 resolvers
###########################################
resource "aws_route53_zone" "private_api_zone" {
  name = "${aws_api_gateway_rest_api.claims.id}.execute-api.${var.region}.amazonaws.com"
#   name = "execute-api.eu-central-1.amazonaws.com"
  vpc {
    vpc_id = aws_vpc.api_client_vpc.id
  }

  tags = {
    Name = "Private API Zone"
  }
}

resource "aws_route53_record" "api_gateway_endpoint_record" {
  zone_id = aws_route53_zone.private_api_zone.zone_id
  name    = ""        
  type    = "A"
#   records = 

  alias {
    name                   = aws_vpc_endpoint.execute_api_ep.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.execute_api_ep.dns_entry[0].hosted_zone_id
    evaluate_target_health = false   
 
  }
}

*/