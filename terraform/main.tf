resource "aws_s3_bucket" "site" {
  bucket = "${random_pet.bucket.id}-static-site"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.use_custom_domain ? false : true
    acm_certificate_arn            = var.use_custom_domain ? aws_acm_certificate.cert.arn : null
    ssl_support_method             = var.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  aliases = var.use_custom_domain ? [var.domain_name] : []
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "Access identity for S3"
}

resource "aws_acm_certificate" "cert" {
  count = var.use_custom_domain ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_zone" "dns" {
  count = var.use_custom_domain ? 1 : 0

  name = var.domain_name
}

resource "aws_budgets_budget" "finops" {
  name              = "WorkshopBudget"
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  limit_amount      = "5"
  limit_unit        = "USD"

  cost_filters = {
    "Service" = "Amazon S3"
  }

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}

