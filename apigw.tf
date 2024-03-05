#create an API Gateway private REST API
resource "aws_api_gateway_rest_api" "claims" {
  name        = "claims-api"
  description = "Private API for claims service"
  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

#create an API Gateway claim resource
resource "aws_api_gateway_resource" "claim" {
  rest_api_id = aws_api_gateway_rest_api.claims.id
  parent_id   = aws_api_gateway_rest_api.claims.root_resource_id
  path_part   = "claim"
}

# create an api gateway deployment
resource "aws_api_gateway_deployment" "claim_deployment" {
  depends_on = [
   aws_api_gateway_rest_api_policy.claim_policy
  ]

  rest_api_id = aws_api_gateway_rest_api.claims.id
}

# create an api gateway stage for dev
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.claim_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.claims.id
  stage_name    = "dev"
  
  # access_log_settings {
  #   destination_arn = aws_cloudwatch_log_group.api_gw.arn
  #   format = "$context.httpMethod $context.resourcePath $context.status_code $context.requestTime $requestLatency $integrationLatency $user-agent $sourceIp $requestPayload"
  # }

#   depends_on = [  aws_cloudwatch_log_group.api_gw, aws_iam_role.api_gw_logging ]
}


# create a HTTP methods for the claim resource
# resource "aws_api_gateway_method" "post_claim" {
#   rest_api_id   = aws_api_gateway_rest_api.claims.id
#   resource_id   = aws_api_gateway_resource.claim.id
#   http_method   = "POST"
#   authorization = "NONE"
# }
resource "aws_api_gateway_method" "get_claim" {
  rest_api_id   = aws_api_gateway_rest_api.claims.id
  resource_id   = aws_api_gateway_resource.claim.id
  http_method   = "GET"
  authorization = "NONE"
}
# resource "aws_api_gateway_method" "put_claim" {
#   rest_api_id   = aws_api_gateway_rest_api.claims.id
#   resource_id   = aws_api_gateway_resource.claim.id
#   http_method   = "PUT"
#   authorization = "NONE"
# }
# resource "aws_api_gateway_method" "delete_claim" {
#   rest_api_id   = aws_api_gateway_rest_api.claims.id
#   resource_id   = aws_api_gateway_resource.claim.id
#   http_method   = "DELETE"
#   authorization = "NONE"
# }

# create an api gateway lambda proxy integration for the post_claim to the createclaim lambda function
# resource "aws_api_gateway_integration" "post_claim_lambda" {
#   rest_api_id = aws_api_gateway_rest_api.claims.id
#   resource_id = aws_api_gateway_resource.claim.id
#   http_method = aws_api_gateway_method.post_claim.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.createClaim.invoke_arn
# }
resource "aws_api_gateway_integration" "get_claim_lambda" {
  rest_api_id = aws_api_gateway_rest_api.claims.id
  resource_id = aws_api_gateway_resource.claim.id
  http_method = aws_api_gateway_method.get_claim.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getClaim.invoke_arn
}
# resource "aws_api_gateway_integration" "put_claim_lambda" {
#   rest_api_id = aws_api_gateway_rest_api.claims.id
#   resource_id = aws_api_gateway_resource.claim.id
#   http_method = aws_api_gateway_method.put_claim.http_method

#   integration_http_method = "PUT"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.updateClaim.invoke_arn
# }

# resource "aws_api_gateway_integration" "delete_claim_lambda" {
#   rest_api_id = aws_api_gateway_rest_api.claims.id
#   resource_id = aws_api_gateway_resource.claim.id
#   http_method = aws_api_gateway_method.delete_claim.http_method

#   integration_http_method = "DELETE"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.deleteClaim.invoke_arn
# }




resource "aws_api_gateway_rest_api_policy" "claim_policy" {
  rest_api_id = aws_api_gateway_rest_api.claims.id
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "${aws_api_gateway_rest_api.claims.execution_arn}*"
      },
      {
              "Effect": "Deny",
              "Principal": "*",
              "Action": "execute-api:Invoke",
              "Resource": "${aws_api_gateway_rest_api.claims.execution_arn}*",
              "Condition": {
                  "StringNotEquals": {
                      "aws:SourceVpce": "${aws_vpc_endpoint.execute_api_ep.id}"
                  }
              }
          }
    ]
  })
}


# create log group for api gateway
# resource "aws_cloudwatch_log_group" "apigw" {
#   name              = "/aws/api_gw/${aws_api_gateway_rest_api.claims.name}"
#   retention_in_days = 30
# }

# # create IAM role for API Gateway logging
# resource "aws_iam_role" "api_gw_logging" {
#   name = "apigw-exec-role"

#   assume_role_policy = jsonencode({

#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "apigateway.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# })
# }

# # Attach policy allowing CloudWatch logging access
# resource "aws_iam_role_policy_attachment" "api_gw_cloudwatch_logs" {
#   role       = aws_iam_role.apigw-exec-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
# }