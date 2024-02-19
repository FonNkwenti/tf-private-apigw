// role for EC2 ssm manager

# create an IAM role for SSM 
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


resource "aws_iam_policy_attachment" "ssm_manager_attachment"{
    name = "ssm-manager-attachement"
    roles = [aws_iam_role.ssm_manager_role.name]
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "ec2-instance-profile"
    role = aws_iam_role.ssm_manager_role.name
}