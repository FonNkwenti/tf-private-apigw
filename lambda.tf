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
data "archive_file" "get_handler_zip" {
  type        = "zip"
  source_dir = "${path.module}/src/handlers/"
  output_path = "${path.module}/src/files/get.zip"

}
data "archive_file" "update_handler_zip" {
  type        = "zip"
  source_dir = "${path.module}/src/handlers/"
  output_path = "${path.module}/src/files/update.zip"

}
data "archive_file" "delete_handler_zip" {
  type        = "zip"
  source_dir = "${path.module}/src/handlers/"
  output_path = "${path.module}/src/files/delete.zip"

}


resource "aws_lambda_function" "createClaim" {
  filename      = data.archive_file.create_handler_zip.output_path
  function_name = var.create_function_name
  handler       = "create.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.create_handler_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn_az1.id, aws_subnet.private_sn_az2.id]
    security_group_ids = [aws_security_group.private_lambda_sg.id]
  }
  logging_config {
    log_format = "Text"
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = local.ddb_table_name
    }
  }
}
resource "aws_lambda_function" "getClaim" {
  filename      = data.archive_file.get_handler_zip.output_path
  function_name = var.get_function_name
  handler       = "get.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.get_handler_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn_az1.id, aws_subnet.private_sn_az2.id]
    security_group_ids = [aws_security_group.private_lambda_sg.id]
  }
  logging_config {
    log_format = "Text"
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = local.ddb_table_name
    }
  }
}
resource "aws_lambda_function" "updateClaim" {
  filename      = data.archive_file.update_handler_zip.output_path
  function_name = var.update_function_name
  handler       = "update.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.update_handler_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn_az1.id, aws_subnet.private_sn_az2.id]
    security_group_ids = [aws_security_group.private_lambda_sg.id]
  }
  logging_config {
    log_format = "Text"
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = local.ddb_table_name
    }
  }
}
resource "aws_lambda_function" "deleteClaim" {
  filename      = data.archive_file.delete_handler_zip.output_path
  function_name = var.delete_function_name
  handler       = "delete.handler"
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 30
  runtime       = "nodejs20.x"
  source_code_hash = data.archive_file.delete_handler_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_sn_az1.id, aws_subnet.private_sn_az2.id]
    security_group_ids = [aws_security_group.private_lambda_sg.id]
  }
  logging_config {
    log_format = "Text"
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = local.ddb_table_name
    }
  }
}


# create log group for create function
resource "aws_cloudwatch_log_group" "createClaim_lg" {
  name              = "/aws/lambda/${aws_lambda_function.createClaim.function_name}"
  retention_in_days = 14
}
resource "aws_cloudwatch_log_group" "getClaim_lg" {
  name              = "/aws/lambda/${aws_lambda_function.getClaim.function_name}"
  retention_in_days = 14
}
resource "aws_cloudwatch_log_group" "updateClaim_lg" {
  name              = "/aws/lambda/${aws_lambda_function.updateClaim.function_name}"
  retention_in_days = 14
}
resource "aws_cloudwatch_log_group" "deleteClaim_lg" {
  name              = "/aws/lambda/${aws_lambda_function.deleteClaim.function_name}"
  retention_in_days = 14
}




resource "aws_lambda_permission" "apigw_create_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.createClaim.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}


resource "aws_lambda_permission" "apigw_get_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getClaim.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}


resource "aws_lambda_permission" "apigw_update_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.updateClaim.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}
resource "aws_lambda_permission" "apigw_delete_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deleteClaim.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}






