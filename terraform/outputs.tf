output "site_url" {
  description = "URL pública del sitio web"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

