// generate an archives for the lambda functions
data "archive_file" "createTodo" {
    type                          = "zip"
    source_file                   = "${path.module}/src/createTodo/handler.mjs"  
    output_path                   = "${path.module}/src/createTodo/handler.zip"
}

resource "aws_lambda_function" "createTodo" { 
    filename                      = "${path.module}/src/createTodo/handler.zip"
    function_name                 = "createTodo"
    role                          = aws_iam_role.lambda_exec_role.arn
    handler                       = "handler.createTodo"
    timeout                       = 30
    runtime                       = "nodejs20.x"

    vpc_config {
    subnet_ids                    = []
    security_group_ids            = []
  }
    logging_config {
    log_format                    = "Text"
  }


#   depends_on                      = [
#     aws_iam_role_policy_attachment.lambda_logs,
#     aws_cloudwatch_log_group.createTodo_lg,
#   ]

    environment {
      variables                   = {
        # DYNAMODB_TABLE_NAME       = aws_dynamodb_table.todo_table.name
      }
    }
  }





# create log group for createTodo function
resource "aws_cloudwatch_log_group" "createTodo_lg" {
  name                            = "/aws/lambda/${aws_lambda_function.createTodo.function_name}"
  retention_in_days               = 14
}

# create IAM policy for logging from lambda 
# resource "aws_iam_policy" "lambda_logging" {
#   name                            = "lambda_logging"
#   path                            = "/"
#   description                     = "IAM policy for logging from a lambda"

#   policy                          = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "arn:aws:logs:*:*:*",
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }


# create IAM policy for logging from lambda using the AWS managed policy: AWSLambdaBasicExecutionRole
# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaBasicExecutionRole.html

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn                             = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_logging" {
  name                            = "lambda_logging"
  path                            = "/"
  description                     = "IAM policy for logging from a lambda"
  policy                          = data.aws_iam_policy.AWSLambdaBasicExecutionRole.policy
}

# create IAM role policy attachment
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role                            = aws_iam_role.lambda_exec_role.name
  policy_arn                      = aws_iam_policy.lambda_logging.arn
}