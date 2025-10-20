variable "use_custom_domain" {
  description = "¿Usar dominio personalizado?"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Dominio raíz del sitio (solo si use_custom_domain = true)"
  type        = string
  default     = ""
}

variable "budget_notification_email" {
  description = "Email para alertas de presupuesto"
  type        = string
}

