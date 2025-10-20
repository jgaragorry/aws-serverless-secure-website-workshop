module "static_site" {
  source = "./modules/static-site"

  domain_name               = var.domain_name
  budget_notification_email = var.budget_notification_email
}

