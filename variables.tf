variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "account_id" {
  type    = number
  default = 404148889442
}

variable "tag_environment" {
  type    = string
  default = "dev"
}

variable "tag_project" {
  type    = string
  default = "tf-private-apigw"
}