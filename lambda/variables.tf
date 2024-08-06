variable "filename" {
  description = "Path to the deployment package"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "role" {
  description = "IAM role for Lambda execution"
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
}

variable "role_name" {
  description = "IAM role name"
  type        = string
}
