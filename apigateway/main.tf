# modules/api_gateway/main.tf
resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  type        = "AWS_PROXY"
  uri         = var.lambda_function_arn
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [aws_api_gateway_integration.proxy]
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.stage_name
}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.this.invoke_url
}