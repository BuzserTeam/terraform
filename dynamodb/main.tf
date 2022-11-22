resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Wailist"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"
  range_key      = "Waitlist"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "Waitlist"
    type = "S"
  }

  attribute {
    name = "Waitlist"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  global_secondary_index {
    name               = "WaitlistIndex"
    hash_key           = "Waitlist"
    range_key          = "Waitlist"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["UserId"]
  }

  tags = {
    Name        = "buzser-waitlist"
    Environment = "development"
  }
}