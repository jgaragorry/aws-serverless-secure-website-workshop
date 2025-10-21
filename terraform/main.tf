terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

# 🪣 Bucket S3 para sitio estático
resource "aws_s3_bucket" "website_bucket" {
  bucket        = "secure-static-site-${random_pet.bucket_suffix.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontAccessOnly",
        Effect    = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 📤 Subida automática del contenido
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/../src/index.html"
  etag         = filemd5("${path.module}/../src/index.html")
  content_type = "text/html"
}

# 🛡️ CloudFront con OAC y headers seguros
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "secure-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "secure-headers-policy"

  security_headers_config {
    content_security_policy {
      override                 = true
      content_security_policy = "default-src 'self'"
    }

    frame_options {
      override     = true
      frame_option = "DENY"
    }

    referrer_policy {
      override        = true
      referrer_policy = "no-referrer"
    }

    strict_transport_security {
      override                  = true
      access_control_max_age_sec = 63072000
      include_subdomains        = true
      preload                   = true
    }

    content_type_options {
      override = true
    }

    xss_protection {
      override    = true
      protection  = true
      mode_block  = true
    }
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "s3-origin"
    viewer_protocol_policy   = "redirect-to-https"
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Project = "SecureStaticSite-v2"
  }
}

# 💸 Presupuesto FinOps
resource "aws_budgets_budget" "monthly_budget" {
  name         = "monthly-budget"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.budget_limit
  limit_unit   = "USD"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}

