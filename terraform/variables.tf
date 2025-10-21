variable "use_custom_domain" {
  description = "¿Usar dominio personalizado?"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Nombre de dominio personalizado (si aplica)"
  type        = string
  default     = ""
}

variable "budget_notification_email" {
  description = "Email para alertas de presupuesto"
  type        = string
}

variable "aws_region" {
  description = "Región AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "budget_limit" {
  description = "Límite mensual de presupuesto en USD"
  type        = string
  default     = "5.00"
}

