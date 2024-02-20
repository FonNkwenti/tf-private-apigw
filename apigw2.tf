
// API Gateway stuff


#create an API Gateway private REST API
resource "aws_api_gateway_rest_api" "todo2_api" {
  name                                  = "todo2_api"
  description                           = "Private API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

}

#create an API Gateway todo2 resource
resource "aws_api_gateway_resource" "todo2" {
  rest_api_id = aws_api_gateway_rest_api.todo2_api.id
  parent_id   = aws_api_gateway_rest_api.todo2_api.root_resource_id
  path_part   = "todo2"
}

# create a POST method for the todo2 resource
resource "aws_api_gateway_method" "todo2_post" {
  rest_api_id   = aws_api_gateway_rest_api.todo2_api.id
  resource_id   = aws_api_gateway_resource.todo2.id
  http_method   = "POST"
  authorization = "NONE"
}

# create an api gateway lambda proxy integration for the todo2_post to the createTodo2 lambda function
resource "aws_api_gateway_integration" "todo2_post_lambda" {
    rest_api_id = aws_api_gateway_rest_api.todo2_api.id
  resource_id = aws_api_gateway_resource.todo2.id
  http_method = aws_api_gateway_method.todo2_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createTodo.invoke_arn
}

# create an api gateway deployment
resource "aws_api_gateway_deployment" "todo2_api_deployment" {
    depends_on = [
    aws_api_gateway_integration.todo2_post_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.todo2_api.id
  stage_name  = "dev"
}

# create an api gateway stage for dev
resource "aws_api_gateway_stage" "todo2_api_dev_stage" {
  deployment_id = aws_api_gateway_deployment.todo2_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.todo2_api.id
  stage_name    = "dev"
} 

# create aws lambda permission for the api gateway to invoke the createTodo2 lambda function
resource "aws_lambda_permission" "api_gw_createTodo2_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.createTodo.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.todo2_api.execution_arn}/*"
}

# create an API Gateway resource policy for the execute-api permitting only a certain VPC endpoint 
resource "aws_api_gateway_rest_api_policy" "todo2_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.todo2_api.id
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}
# resource "aws_api_gateway_rest_api_policy" "todo2_api_policy" {
#   rest_api_id = aws_api_gateway_rest_api.todo2_api.id
#   policy      = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "execute-api:Invoke",
#       "Resource": "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.todo2_api.id}/*"
#     },
#     {
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "execute-api:Invoke",
#             "Resource": "arn:aws:execute-api:${var.aws_region}:${var.account_id}:${aws_api_gateway_rest_api.todo2_api.id}/*",
#             "Condition": {
#                 "StringNotEquals": {
#                     "aws:SourceVpce": "${aws_vpc_endpoint.execute_api_ep.id}"
#                 }
#             }
#         }
#   ]
# }
# EOF
# }


