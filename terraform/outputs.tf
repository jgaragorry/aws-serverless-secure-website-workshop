output "site_url" {
  description = "URL del sitio desplegado en CloudFront"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "bucket_name" {
  description = "Nombre del bucket S3 creado para el sitio"
  value       = aws_s3_bucket.website_bucket.id
}

output "budget_name" {
  description = "Nombre del presupuesto FinOps creado"
  value       = aws_budgets_budget.monthly_budget.name
}

output "headers_policy_id" {
  description = "ID de la política de headers aplicada en CloudFront"
  value       = aws_cloudfront_response_headers_policy.security_headers.id
}

output "origin_access_control_id" {
  description = "ID del control de acceso de origen para CloudFront"
  value       = aws_cloudfront_origin_access_control.oac.id
}

