#create an API Gateway private REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = "claims-api"
  description = "Private API for claims service"
  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

#create an API Gateway claim resource
resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "claim"
}

# create an api gateway deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [
   aws_api_gateway_rest_api_policy.claim_policy, aws_api_gateway_integration.post_claim_lambda, aws_api_gateway_integration.delete_claim_lambda, aws_api_gateway_integration.get_claim_lambda, aws_api_gateway_integration.put_claim_lambda
  ]

}

# create an api gateway stage for dev
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "dev"
  
}
## create a HTTP methods for the claim resource
resource "aws_api_gateway_method" "post_claim" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "POST"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "get_claim" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "GET"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "put_claim" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "PUT"
  authorization = "NONE"
}
resource "aws_api_gateway_method" "delete_claim" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "DELETE"
  authorization = "NONE"
}

##create an api gateway lambda proxy integration for the post_claim to the createclaim lambda function

resource "aws_api_gateway_integration" "post_claim_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.post_claim.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createClaim.invoke_arn
}
resource "aws_api_gateway_integration" "get_claim_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.get_claim.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getClaim.invoke_arn
}

resource "aws_api_gateway_integration" "put_claim_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.put_claim.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.updateClaim.invoke_arn
}

resource "aws_api_gateway_integration" "delete_claim_lambda" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.delete_claim.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.deleteClaim.invoke_arn
}




resource "aws_api_gateway_rest_api_policy" "claim_policy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "${aws_api_gateway_rest_api.this.execution_arn}*"
      },
      {
              "Effect": "Deny",
              "Principal": "*",
              "Action": "execute-api:Invoke",
              "Resource": "${aws_api_gateway_rest_api.this.execution_arn}*",
              "Condition": {
                  "StringNotEquals": {
                      "aws:SourceVpce": "${aws_vpc_endpoint.execute_api_ep.id}"
                  }
              }
          }
    ]
  })
}

