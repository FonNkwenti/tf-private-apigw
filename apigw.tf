
// API Gateway stuff


#create an API Gateway private REST API
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "todo_api"
  description = "Private API"
  endpoint_configuration {
    types = ["PRIVATE"]
  }

}

#create an API Gateway todo resource
resource "aws_api_gateway_resource" "todo" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todo"
}

# create a POST method for the todo resource
resource "aws_api_gateway_method" "todo_post" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "POST"
  authorization = "NONE"
}

# create an api gateway lambda proxy integration for the todo_post to the createTodo lambda function
resource "aws_api_gateway_integration" "todo_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.todo_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createTodo.invoke_arn
}

# create an api gateway deployment
resource "aws_api_gateway_deployment" "todo_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.todo_post_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.todo_api.id
}

# create an api gateway stage for dev
resource "aws_api_gateway_stage" "todo_api_dev_stage" {
  deployment_id = aws_api_gateway_deployment.todo_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  stage_name    = "dev"
}



resource "aws_api_gateway_rest_api_policy" "todo_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.todo_api.execution_arn}*"
    },
    {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.todo_api.execution_arn}*",
            "Condition": {
                "StringNotEquals": {
                    "aws:SourceVpce": "${aws_vpc_endpoint.execute_api_ep.id}"
                }
            }
        }
  ]
}
EOF
}


