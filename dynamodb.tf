# dynamodb.tf

resource "aws_dynamodb_table" "leads_table" {
  name         = "BuzserLeads"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  global_secondary_index {
    name            = "TimestampIndex"
    hash_key        = "timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-leads-table"
    Environment = var.environment
  }
}