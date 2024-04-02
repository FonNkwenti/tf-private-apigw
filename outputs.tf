output "claim_url" {
  description = "The API Gateway invocation url pointing to the stage"
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}/${aws_api_gateway_resource.claim.path_part}"
}
output "claim_id_url" {
  description = "The API Gateway invocation url for a single resource pointing to the stage"
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}/${aws_api_gateway_resource.claim_id.path_part}"
}


output "execute_api_endpoint" {
  value = aws_vpc_endpoint.execute_api_ep.id
}
output "execute_api_endpoint_dns_name" {
    value = aws_vpc_endpoint.execute_api_ep.dns_entry[0].dns_name
}
output "execute_api_arn" {
    value = aws_api_gateway_rest_api.this.arn
}
output "api_instance_private_ip" {
    value = aws_instance.api_vpc_instance.private_ip
}

output "ddb_endpoint_id" {
    value = aws_vpc_endpoint.ddb_ep.id
}