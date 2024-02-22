

# Create a security group for SSH access
resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.api_vpc.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere (for testing purposes)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "execute_api_ep_sg" {
  name        = "execute-api-endpoint-sg"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = aws_vpc.api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["${aws_subnet.private_sn_az1.cidr_block}"]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # depends_on = [ aws_subnet.private_sn_az1 ]

   lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "ssm_ep_sg" {
  name        = "ssm-endpoint-sg"
  description = "Security group for SSM endpoints"
  vpc_id      = aws_vpc.api_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["${aws_subnet.private_sn_az1.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # depends_on = [ aws_subnet.private_sn_az1 ]
    lifecycle {
    create_before_destroy = true
  }
}
