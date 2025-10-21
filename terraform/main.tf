resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket         = "secure-static-site-${random_pet.bucket_suffix.id}"
  force_destroy  = true
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/../src/index.html"
  etag         = filemd5("${path.module}/../src/index.html")
  content_type = "text/html"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "secure-oac-${random_pet.bucket_suffix.id}"
  description                       = "Managed by Terraform"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "secure-headers-policy-${random_pet.bucket_suffix.id}"

  security_headers_config {
    content_security_policy {
      override = true
      content_security_policy = "default-src https:"
    }

    strict_transport_security {
      override = true
      include_subdomains = true
      preload = true
      access_control_max_age_sec = 31536000
    }

    content_type_options {
      override = true
    }

    frame_options {
      override     = true
      frame_option = "DENY"
    }

    referrer_policy {
      override        = true
      referrer_policy = "no-referrer"
    }
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin-${random_pet.bucket_suffix.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin-${random_pet.bucket_suffix.id}"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "secure-static-site-${random_pet.bucket_suffix.id}"
  }
}

resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget-${random_pet.bucket_suffix.id}"
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  limit_amount      = "5"
  limit_unit        = "USD"

  time_period_start = formatdate("YYYY-MM-DD_HH:mm", timestamp())

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_email_addresses = ["jgaragorry@gmail.com"]
    subscriber_sns_topic_arns  = []

    subscriber {
      subscription_type = "EMAIL"
      address           = "jgaragorry@gmail.com"
    }
  }
}

