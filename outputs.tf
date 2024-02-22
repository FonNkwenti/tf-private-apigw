output "todo_url" {
  description = "The API Gateway invocation url pointing to the stage"
  #   value       = aws_api_gateway_rest_api.todo_api.apigateway_restapi_invoke_url
  value = "https://${aws_api_gateway_rest_api.todo_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.todo_api_dev_stage.stage_name}/${aws_api_gateway_resource.todo.path_part}"
}

# output "todo2_url" {
#   description = "The API Gateway invocation url pointing to the stage"
# #   value       = aws_api_gateway_rest_api.todo_api.apigateway_restapi_invoke_url
# value           = "https://${aws_api_gateway_rest_api.todo2_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.tod2o_api_dev_stage.stage_name}"
# }


output "jumphost_private_ip" {
  value = aws_instance.jumphost.private_ip
}
output "jumphost_public_ip" {
  value = aws_instance.jumphost.public_ip
}
output "jumphost_dns" {
  value = aws_instance.jumphost.public_dns
}
output "execute_api_endpoint" {
  value = aws_vpc_endpoint.execute_api_ep.id
}
