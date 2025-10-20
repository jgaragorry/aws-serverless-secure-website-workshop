output "site_url" {
  description = "URL pública del sitio"
  value       = var.use_custom_domain ? "https://${var.domain_name}" : aws_cloudfront_distribution.cdn.domain_name
}

