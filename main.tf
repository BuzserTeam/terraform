

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-lambda-code-${var.environment}"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-lambda-code"
    Environment = var.environment
  }
}


resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}