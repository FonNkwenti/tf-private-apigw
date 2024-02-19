

# Create a security group for SSH access
resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.this.id
  

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere (for testing purposes)
  }
}

