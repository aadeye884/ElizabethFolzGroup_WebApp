# Cloudfront Distribution Data
data "aws_cloudfront_distribution" "elizabethfolzgroup_cloudfront" {
  id = aws_cloudfront_distribution.elizabethfolzgroup_distribution.id
}

# Cloudfront Distribution
locals {
  s3_origin_id = "aws_s3_bucket.elizabethfolzgroupmedia.id"
}
resource "aws_cloudfront_distribution" "elizabethfolzgroup_distribution" {
  origin {
    domain_name = aws_s3_bucket.elizabethfolzgroupmedia.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 600
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}