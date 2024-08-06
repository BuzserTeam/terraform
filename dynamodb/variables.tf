# terraform-modules/dynamodb/variables.tf
variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "The billing mode of the DynamoDB table"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "The primary key attribute name"
  type        = string
}

variable "hash_key_type" {
  description = "The primary key attribute type"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "The range key attribute name"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "The range key attribute type"
  type        = string
  default     = "S"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}