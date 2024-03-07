# EC2 exec role
resource "aws_iam_role" "ec2_exec_role" {
  name = "ec2-exec-role"

  assume_role_policy = jsonencode(
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
})

  tags = {
    tag-key = "ec2-exec-role"
  }
}


resource "aws_iam_policy_attachment" "ssm_manager_attachment" {
  name       = "ec2-exec-attachement"
  roles      = [aws_iam_role.ec2_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_exec_role.name
}

resource "aws_instance" "client_vpc_instance" {
  ami                    = local.ami // 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.client_private_sn_az1.id
  vpc_security_group_ids = [aws_security_group.api_client_sg.id, ]
  key_name               = "default-euc1"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "client-vpc-instance"
  }
}

# instance in the api-vpc required in part 1 to test the private API within the same VPC
resource "aws_instance" "api_vpc_instance" {
  ami                    = local.ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_sn_az1.id
  vpc_security_group_ids = [ aws_security_group.execute_api_ep_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "api-vpc-instance"
  }
}
