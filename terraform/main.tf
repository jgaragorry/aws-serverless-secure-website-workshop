resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "secure-static-site-${random_pet.bucket_suffix.id}"
  acl    = "private"
  force_destroy = true
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
    x_content_type_options {
      override = true
    }
    x_frame_options {
      override = true
      frame_option = "DENY"
    }
    referrer_policy {
      override = true
      referrer_policy = "no-referrer"
    }
  }
}

resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget-${random_pet.bucket_suffix.id}"
  budget_type       = "COST"
  time_unit         = "MONTHLY"
  limit_amount      = "5"
  limit_unit        = "USD"

  cost_filters = {
    Service = "Amazon Simple Storage Service"
  }

  time_period_start = formatdate("YYYY-MM-DD'T'HH:MM:SS'Z'", timestamp())

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"

    subscriber {
      subscription_type = "EMAIL"
      address           = "tu-email@ejemplo.com"
    }
  }
}

