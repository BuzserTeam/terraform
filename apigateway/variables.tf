# modules/api_gateway/variables.tf
variable "name" {
  description = "The name of the API Gateway"
  type        = string
}

variable "description" {
  description = "The description of the API Gateway"
  type        = string
  default     = ""
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to integrate with the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "The name of the deployment stage"
  type        = string
  default     = "dev"
}