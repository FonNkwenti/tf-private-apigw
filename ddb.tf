
resource "aws_dynamodb_table" "todo" {
  name           = "${local.ddb_table_name}"
  hash_key       = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
    name = "id"
    type = "S"
  }
}
