
resource "aws_dynamodb_table" "claims_table" {
  name           = local.ddb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PK"
  range_key      = "SK"
  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }
  
  tags = {
    Name = "Healthcare Insurance Claims Table"
  }
}
