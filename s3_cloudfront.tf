# S3 bucket for video storage
resource "aws_s3_bucket" "video_bucket" {
  bucket = "buzser-media-assets"
  
  tags = {
    Name        = "Buzser Media Assets"
    Environment = var.environment
  }
}

# Public access block settings for S3
resource "aws_s3_bucket_public_access_block" "video_bucket_access" {
  bucket = aws_s3_bucket.video_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "video_bucket_ownership" {
  bucket = aws_s3_bucket.video_bucket.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# S3 bucket CORS configuration
resource "aws_s3_bucket_cors_configuration" "video_bucket_cors" {
  bucket = aws_s3_bucket.video_bucket.id

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"] # Replace with your actual origins in production
    expose_headers  = []
    max_age_seconds = 3000
  }
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for Buzser media assets"
}

# S3 bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "video_bucket_policy" {
  bucket = aws_s3_bucket.video_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "CloudFrontReadAccess"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.video_bucket.arn}/*"
      }
    ]
  })
}

# CloudFront distribution 
resource "aws_cloudfront_distribution" "video_distribution" {
  origin {
    domain_name = aws_s3_bucket.video_bucket.bucket_regional_domain_name
    origin_id   = "BuzserMediaS3Origin"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "BuzserMediaS3Origin"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }
  
  # Cache behavior for videos with longer TTL
  ordered_cache_behavior {
    path_pattern     = "videos/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "BuzserMediaS3Origin"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    min_ttl                = 0
    default_ttl            = 86400    # 1 day
    max_ttl                = 31536000 # 1 year
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  
  price_class = "PriceClass_100" # Use only North America and Europe edge locations
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
  tags = {
    Name        = "Buzser Media CDN"
    Environment = var.environment
  }
}

# Outputs for easy reference
output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.video_distribution.domain_name
  description = "The domain name of the CloudFront distribution"
}

output "video_url_example" {
  value       = "https://${aws_cloudfront_distribution.video_distribution.domain_name}/videos/waiting.mp4"
  description = "Example URL to access your video"
}