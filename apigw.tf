
// API Gateway stuff


#create an API Gateway private REST API
resource "aws_api_gateway_rest_api" "claim" {
  name        = "claim"
  description = "Private API for claims microservice"
  endpoint_configuration {
    types = ["PRIVATE"]
  }

}

#create an API Gateway claim resource
resource "aws_api_gateway_resource" "claim" {
  rest_api_id = aws_api_gateway_rest_api.claim.id
  parent_id   = aws_api_gateway_rest_api.claim.root_resource_id
  path_part   = "claim"
}

# create a POST method for the claim resource
resource "aws_api_gateway_method" "claim_post" {
  rest_api_id   = aws_api_gateway_rest_api.claim.id
  resource_id   = aws_api_gateway_resource.claim.id
  http_method   = "POST"
  authorization = "NONE"
}

# create an api gateway lambda proxy integration for the claim_post to the createclaim lambda function
resource "aws_api_gateway_integration" "claim_post_lambda" {
  rest_api_id = aws_api_gateway_rest_api.claim.id
  resource_id = aws_api_gateway_resource.claim.id
  http_method = aws_api_gateway_method.claim_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createClaim.invoke_arn
}

# create an api gateway deployment
resource "aws_api_gateway_deployment" "claim_deployment" {
  depends_on = [
    aws_api_gateway_integration.claim_post_lambda, aws_api_gateway_rest_api_policy.claim_policy
  ]

  rest_api_id = aws_api_gateway_rest_api.claim.id
}

# create an api gateway stage for dev
resource "aws_api_gateway_stage" "claim_dev_stage" {
  deployment_id = aws_api_gateway_deployment.claim_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.claim.id
  stage_name    = "dev"
}



resource "aws_api_gateway_rest_api_policy" "claim_policy" {
  rest_api_id = aws_api_gateway_rest_api.claim.id
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.claim.execution_arn}*"
    },
    {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.claim.execution_arn}*",
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


