

resource "aws_instance" "jumphost" {
  # ami             = "ami-027d95b1c717e8c5d" // eu-west-1
  ami             = "ami-0a23a9827c6dab833" // eu-central-1
  instance_type   = "t2.micro"  
  subnet_id       = aws_subnet.public_sn_az1.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  key_name        = "default-euc1"  
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "jumphost"
  }
}
