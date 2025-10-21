# 📘 README-GUIA.md — Workshop: Sitio Web Estático Seguro y Sin Costos en AWS

Este documento guía el despliegue completo, validación de seguridad, automatización y documentación del workshop. Está diseñado para enseñar buenas prácticas DevSecOps, FinOps y IaC usando Terraform y GitHub Actions.

---

## 🧩 1. Estructura del repositorio

```
aws-serverless-secure-website-workshop/
├── src/                  # Contenido HTML del sitio web
│   └── index.html        # Página principal que se sube a S3
├── terraform/            # Módulo de infraestructura
│   ├── main.tf           # Define todos los recursos AWS
│   ├── variables.tf      # Variables parametrizables
│   ├── outputs.tf        # Resultados como la URL del sitio
│   └── README-GUIA.md    # Este archivo
├── .github/workflows/    # Automatización CI/CD
│   └── deploy.yml        # Workflow para aplicar Terraform automáticamente
├── LICENSE               # Licencia MIT
├── SECURITY.md           # Política de seguridad del proyecto
├── README.md             # Portada del repositorio
```

---

## 📂 2. Detalle de cada archivo Terraform

### `main.tf`
Define todos los recursos del workshop:
- S3 bucket con acceso restringido
- CloudFront con OAC y cabeceras seguras
- Subida automática de `index.html`
- Política de acceso segura
- Presupuesto FinOps
- Outputs con la URL del sitio

### `variables.tf`
Contiene las variables necesarias:
- `aws_region`: región AWS
- `budget_notification_email`: correo para alertas
- `budget_limit`: monto mensual
- `use_custom_domain` y `domain_name`: opcionales para dominio propio

### `outputs.tf`
Entrega la URL final del sitio desplegado:

```
output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
  description = "URL del sitio desplegado en CloudFront"
}
```

---

## 💸 3. Presupuesto FinOps en AWS

El recurso creado en Terraform es:

```
resource "aws_budgets_budget" "monthly_budget" {
  name         = "monthly-budget"
  # ... configuración adicional
}
```

🔍 En la consola de AWS, búscalo como:

```
Presupuesto: monthly-budget
```

Este presupuesto monitorea el servicio Amazon CloudFront y envía alertas al correo definido cuando se supera el 80% del límite.

---

## 🔐 4. Validación de seguridad del sitio

Una vez desplegado, accede a la URL generada:

[https://d3ktm8cm9qh9bk.cloudfront.net](https://d3ktm8cm9qh9bk.cloudfront.net)

Valida la seguridad con estas herramientas:

1. **SSL Labs**
   - Verifica el certificado HTTPS
   - Evalúa el protocolo TLS
   - Detecta vulnerabilidades en la configuración SSL

2. **SecurityHeaders.com**
   - Analiza las cabeceras HTTP
   - Detecta si faltan cabeceras críticas como:
     - Strict-Transport-Security
     - Content-Security-Policy
     - X-Frame-Options
     - Referrer-Policy

3. **Lighthouse**
   - Audita performance, accesibilidad, SEO y buenas prácticas
   - Ideal para validar la calidad del sitio como producto web

---

## ⚙️ 5. Despliegue manual con Terraform

Este workshop puede desplegarse manualmente con los siguientes comandos:

```
terraform init
terraform plan
terraform apply --auto-approve
```

Esto garantiza control total, validación paso a paso y corrección de errores en tiempo real.

---

## 🤖 6. Automatización con GitHub Actions

El archivo `.github/workflows/deploy.yml` está configurado para ejecutar el despliegue automáticamente al hacer push a la rama `main`.

Contenido del workflow:

```
name: Deploy Static Website

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform -chdir=terraform init

      - name: Terraform Plan
        run: terraform -chdir=terraform plan

      - name: Terraform Apply
        run: terraform -chdir=terraform apply -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

      - name: Obtener URL del sitio
        id: terraform_output
        run: |
          echo "site_url=$(terraform -chdir=terraform output -raw site_url)" >> $GITHUB_OUTPUT

      - name: Verificar sitio activo
        run: curl -I ${{ steps.terraform_output.outputs.site_url }}
```

**Requisitos previos:**
- Las credenciales AWS deben estar configuradas como secretos en GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
- El código en `terraform/` debe estar completo y sin errores.
- Las variables deben tener valores por defecto o estar definidas en `terraform.tfvars`.

---

## 🧠 7. Lecciones aprendidas

- Terraform no permite duplicar bloques `provider` ni `required_providers`.
- Algunos atributos como `iam_arn`, `cost_filters` o `budget_filter` han sido deprecados.
- Las cabeceras de seguridad deben configurarse con `aws_cloudfront_response_headers_policy`.
- Validar cada paso con `terraform plan` evita errores en producción.
- Documentar cada corrección como parte del aprendizaje DevSecOps.

---

## 🧹 8. Destrucción segura

Para evitar cargos innecesarios en AWS:

```
terraform destroy --auto-approve
```

Esto elimina todos los recursos creados, incluyendo:
- S3 bucket
- CloudFront distribution
- Presupuesto FinOps

---

## 👨‍🏫 9. Autor

José Garagorry  
🔗 LinkedIn · 🐙 GitHub · 📺 YouTube

---

## 📄 10. Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.
```

