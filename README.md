# 🚀 Workshop: Sitio Web Estático Seguro y Sin Costos en AWS

Este repositorio contiene el código y la infraestructura necesaria para desplegar automáticamente un sitio web estático en AWS, utilizando **Terraform** como herramienta de infraestructura como código (IaC) y **GitHub Actions** como motor de automatización CI/CD.

---

## 🎯 ¿Qué logramos con este workshop?

- ✅ Desplegar un sitio web estático en AWS S3 + CloudFront  
- ✅ Automatizar el despliegue con GitHub Actions al hacer push a `main`  
- ✅ Aplicar cabeceras de seguridad HTTP con CloudFront  
- ✅ Validar el sitio con herramientas profesionales (SSL Labs, Security Headers, Lighthouse)  
- ✅ Implementar un presupuesto FinOps para evitar costos inesperados  
- ✅ Documentar todo el proceso para reproducibilidad  

---

## 🧠 Buenas prácticas aplicadas

### 🔐 Seguridad  
- Cabeceras HTTP aplicadas con `aws_cloudfront_response_headers_policy` como:  
  `Strict-Transport-Security`, `Content-Security-Policy`, `X-Frame-Options`, `X-XSS-Protection`, `Referrer-Policy`, `X-Content-Type-Options`  
- Redirección a HTTPS obligatoria (`redirect-to-https`)  
- Política de acceso restringido al bucket S3  
- Mínimo protocolo TLS 1.2 (`TLSv1.2_2021`)  
- Política de acceso CloudFront con OAC (Origin Access Control)  

### 💸 FinOps  
- Presupuesto mensual configurado (`monthly-budget`) con alertas al 80%  
- Monitorización del servicio Amazon CloudFront para control de costos  

### 🤖 Automatización CI/CD  
- Workflow en `.github/workflows/deploy.yml` que ejecuta `terraform init`, `plan` y `apply` automáticamente con cada push a `main`  
- Verificación automática de que el sitio se encuentra activo  
- Uso seguro de secretos para credenciales AWS  

---

## 🔍 Validación del despliegue

### 🌐 Sitio desplegado  
[https://d3ktm8cm9qh9bk.cloudfront.net](https://d3ktm8cm9qh9bk.cloudfront.net)

### 🔐 Seguridad TLS — [SSL Labs](https://www.ssllabs.com/ssltest/)  
- Calificación **A** para servidores  
- Certificado válido y protocolo TLS seguro  

### 🛡️ Cabeceras HTTP — [SecurityHeaders.com](https://securityheaders.com/)  
- Cabeceras críticas implementadas correctamente  
- Protección contra XSS, clickjacking, sniffing y fugas de información  

### 🚀 Rendimiento y SEO — [Lighthouse](https://web.dev/measure/)  
- **Performance: 100**  
- **Accessibility: 100**  
- **Best Practices: 100**  
- **SEO: 100**  

---

## 📂 1. Estructura del repositorio

```
aws-serverless-secure-website-workshop/
├── src/                      # Código HTML del sitio
│   └── index.html            # Página principal para S3
├── terraform/                # Infraestructura como código
│   ├── main.tf               # Recursos AWS y lógica principal
│   ├── variables.tf          # Variables parametrizables
│   ├── outputs.tf            # Resultados como URL de sitio
│   └── README-GUIA.md        # Guía técnica detallada
├── .github/workflows/        # Pipelines CI/CD
│   ├── deploy.yml            # Workflow de despliegue automático
│   └── destroy.yml           # Workflow de destrucción manual
├── scripts/                  # Automatización del backend remoto
│   ├── create-backend.sh     # Script para crear el bucket remoto con versionado
│   └── delete-backend.sh     # Script para eliminar el bucket remoto con confirmación
├── steps.md                  # Procedimiento completo validado desde cero
├── LICENSE                   # Licencia MIT
├── SECURITY.md               # Política de seguridad y cumplimiento
├── README.md                 # Este archivo principal
```

---

## 📂 2. Detalle de configuraciones importantes

### `main.tf`  
Define recursos: S3 sin acceso público, CloudFront con OAC y políticas de seguridad, carga automática de contenido, y presupuesto FinOps.

### `variables.tf`  
Variables: región AWS, correo para alertas, límite presupuestario, dominio personalizado.

### `outputs.tf`  
Entrega la URL final del sitio, por ejemplo:

```
output "cloudfront_url" {
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
  description = "URL del sitio desplegado en CloudFront"
}
```

---

## ⚙️ 3. Despliegue manual con Terraform

```
terraform init
terraform plan
terraform apply --auto-approve
```

---

## 🤖 4. Automatización con GitHub Actions

Workflow `.github/workflows/deploy.yml`, que:

- Se activa con push a `main`  
- Ejecuta `terraform init`, `plan` y `apply`  
- Obtiene URL desplegada y verifica disponibilidad  
- Usa secretos `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`  

---

## 🧹 5. Destrucción segura

Para evitar cobros no deseados, elimina los recursos con:

```
terraform destroy --auto-approve
```

---

## 👨‍🏫 6. Autor y contacto

José Garagorry  
🔗 [GitHub](https://github.com/jgaragorry) · [LinkedIn](https://www.linkedin.com/in/jgaragorry/) · [YouTube](https://www.youtube.com/@Softraincorp) · [TikTok](https://www.tiktok.com/@softtraincorp) · [Comunidad WhatsApp](https://chat.whatsapp.com/ENuRMnZ38fv1pk0mHlSixa)

---

## 📄 7. Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo LICENSE para detalles.
```

