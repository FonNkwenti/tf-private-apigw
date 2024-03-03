
data "aws_availability_zones" "available" {}
locals {
  ddb_table_name = "claimsTable"
  env            = "dev"
  az1             = data.aws_availability_zones.available.names[0]
  az2             = data.aws_availability_zones.available.names[1]
}