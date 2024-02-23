###############################
# execution role for lambdas
###############################
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

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

##################################
# Using managed IAM policies for VPC EC2 networking, Cloudwatch & DynamoDB
##################################

# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaVPCAccessExecutionRole.html
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonDynamoDBFullAccess.html
resource "aws_iam_role_policy_attachment" "ddb_full_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

##################################
# Create Lambda
##################################
data "archive_file" "create_handler_zip" {
  type        = "zip"
  source_dir = "${path.module}/src/handlers/"
  output_path = "${path.module}/src/files/create.zip"

}

resource "aws_lambda_function" "createClaim" {
  filename      = data.archive_file.create_handler_zip.output_path
  # filename      = "${path.module}/src/handlers/create.zip"
  function_name = var.create_function_name
  handler       = "create.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.create_handler_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn_az1.id]
    security_group_ids = [aws_security_group.pri_lambda_sg.id]
  }
  logging_config {
    log_format = "Text"
  }
  #   depends_on                      = [
  #     aws_iam_role_policy_attachment.lambda_logs,
  #     aws_cloudwatch_log_group.create_lg,
  #   ]

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = local.ddb_table_name
    }
  }
}


# create log group for create function
resource "aws_cloudwatch_log_group" "create_lg" {
  name              = "/aws/lambda/${aws_lambda_function.createClaim.function_name}"
  retention_in_days = 14
}


resource "aws_lambda_permission" "api_gw_create_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.createClaim.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.claims.execution_arn}/*"
}






