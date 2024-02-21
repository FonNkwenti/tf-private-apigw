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

# execution role for lambdas
resource "aws_iam_role" "lambda_exec_role" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# # create vpc endpoint policy for the execute-api interface endpoint
# resource "aws_iam_policy" "vpc_endpoint_policy" {
#   name        = "vpc_endpoint_policy"
#   path        = "/"
#   description = "VPC Endpoint Policy for execute-api interface"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "execute-api:Invoke",
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
      
#     ]
#   })
# }


