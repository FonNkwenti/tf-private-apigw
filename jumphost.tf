# role for EC2 ssm manager
resource "aws_iam_role" "ssm_manager_role" {
  name = "ssm-manager-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "ssm_manager_role"
  }
}


resource "aws_iam_policy_attachment" "ssm_manager_attachment" {
  name       = "ssm-manager-attachement"
  roles      = [aws_iam_role.ssm_manager_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ssm_manager_role.name
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners     = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "jumphost" {
  ami                    = data.aws_ami.amazon_linux_2.id
  # ami                    = "ami-0a23a9827c6dab833" // eu-central-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_sn_az1.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id, aws_security_group.execute_api_ep_sg.id]
  key_name               = "default-euc1"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data_replace_on_change = true
  user_data = base64encode(file("userdata.sh")) 
  tags = {
    Name = "jumphost"
  }
}
resource "aws_instance" "client_vpc_instance" {
  ami                    = "ami-0a23a9827c6dab833" // eu-central-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.api_client_pri_sn_az1.id
  vpc_security_group_ids = [aws_security_group.api_client_sg.id, ]
  key_name               = "default-euc1"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data_replace_on_change = true
  user_data = base64encode(file("userdata.sh")) 

  tags = {
    Name = "client-vpc-instance"
  }
}
resource "aws_instance" "api_vpc_instance" {
  ami                    = "ami-0a23a9827c6dab833" // eu-central-1
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_sn_az1.id
  vpc_security_group_ids = [ aws_security_group.execute_api_ep_sg.id, aws_security_group.ssh_sg.id]
  key_name               = "default-euc1"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data_replace_on_change = true
  user_data = base64encode(file("userdata.sh")) 

  tags = {
    Name = "api-vpc-instance"
  }
}

