
resource "aws_dynamodb_table" "claims_table" {
  name           = local.ddb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "memberId"
  range_key      = "policyId"
  attribute {
    name = "memberId"
    type = "N"
  }

  attribute {
    name = "policyId"
    type = "N"
  }

  attribute {
    name = "claimId"
    type = "N"
  }

  attribute {
    name = "memberName"
    type = "S"
  }

    
  global_secondary_index {
    name               = "memberNameIndex"
    hash_key           = "memberName"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }
  global_secondary_index {
    name               = "claimIdIndex"
    hash_key           = "claimId"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }
  
  tags = {
    Name = "Healthcare Insurance Claims Table"
  }
}
