variable "region" {
  type    = string
  default = "us-east-1"
}
variable "account_id" {
  type    = number
  default = 123456789012
}

variable "tag_environment" {
  type    = string
  default = "dev"
}

variable "tag_project" {
  type    = string
  default = "my-tf-project"
}
variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}
variable "lambda_timeout" {
  type    = number
  default = 30
}
variable "claim_function_name" {
  type    = string
  default = "claimFunction"
}
variable "create_function_name" {
  type    = string
  default = "createClaim"
}
variable "get_function_name" {
  type    = string
  default = "get"
}
variable "update_function_name" {
  type    = string
  default = "update"
}
variable "delete_function_name" {
  type    = string
  default = "delete"
}

variable "private_api_domain_name" {
  type    = string
  default = "execute-api.eu-central-1.amazonaws.com"
}