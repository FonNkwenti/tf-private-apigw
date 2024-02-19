

resource "aws_instance" "jumphost" {
  ami             = "ami-027d95b1c717e8c5d" 
  instance_type   = "t2.micro"  
  subnet_id       = aws_subnet.public_sn_az1.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  key_name        = "default-eu1"  
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  tags = {
    Name = "jumphost"
  }
}

output "jumphost_private_ip" {
  value = aws_instance.jumphost.private_ip
}
output "jumphost_public_ip" {
  value = aws_instance.jumphost.public_ip
}
