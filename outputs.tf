# outputs.tf

output "api_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}/${aws_api_gateway_resource.resource.path_part}"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.leads_table.name
}

output "pinpoint_app_id" {
  description = "ID of the Pinpoint application"
  value       = aws_pinpoint_app.buzser_pinpoint.application_id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.demo_request_handler.function_name
}