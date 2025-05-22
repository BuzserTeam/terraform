# variables.tf

# variable "aws_region" {
#   description = "AWS region for all resources"
#   type        = string
#   default     = "us-east-1"
# }

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "buzser"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "domain" {
  description = "Domain for SES verification"
  type        = string
  default     = "buzser.com"
}

variable "notification_email" {
  description = "Email to receive notifications"
  type        = string
  default     = "chris.hickey@buzser.com"
}

variable "sender_email" {
  description = "Email to send from"
  type        = string
  default     = "hello@buzser.com"
}

variable "confirmation_sender_email" {
  description = "Email to send confirmations from"
  type        = string
  default     = "chris.hickey@buzser.com"
}

variable "cors_allowed_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["https://buzser.com"]
}

