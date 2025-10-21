# 🛡️ Workshop: Sitio Web Estático Seguro y Sin Costos en AWS

Una masterclass práctica en **DevSecOps, FinOps y Cloud Engineering**, usando Terraform y GitHub Actions para desplegar un sitio web estático, seguro y automatizado en AWS.

---

## 📚 1. Introducción

Este workshop te guía paso a paso para construir una solución **serverless**, segura y con control de costos, aplicando prácticas reales de:

- DevOps y CI/CD
- DevSecOps
- Infraestructura como Código (IaC)
- FinOps
- SRE y automatización

Ideal para quienes buscan un proyecto tangible y profesional para su portafolio.

---

## 🎯 2. Público Objetivo

Nivel **intermedio**. Se recomienda tener conocimientos básicos en:

- Conceptos de nube (S3, CDN, DNS)
- Git y línea de comandos
- Fundamentos de Terraform

Cada paso está documentado para facilitar el aprendizaje autodidacta.

---

## 🧰 3. Tecnologías y Disciplinas

| Disciplina                  | Herramienta / Concepto                 | Propósito en el Workshop         |
|-----------------------------|----------------------------------------|----------------------------------|
| Cloud Engineering           | AWS (S3, CloudFront, ACM, Route 53)    | Infraestructura serverless       |
| Infraestructura como Código | Terraform                              | Infraestructura reproducible     |
| DevOps / CI/CD              | GitHub Actions                         | Automatización del despliegue    |
| DevSecOps                   | OAI, cabeceras seguras, HTTPS          | Seguridad desde el diseño        |
| FinOps                      | AWS Budgets, destrucción segura        | Control de costos y limpieza     |

---

## 🏗️ 4. Arquitectura de la Solución

```
graph TD
    A[👨‍💻 Usuario Final] --> B[🌐 Route 53: DNS]
    B --> C[🛡️ HTTPS + OAI + Política S3]
    C --> D[📦 CloudFront CDN]
    D --> E[🪣 S3 Bucket: Contenido Estático]
```
Seguridad: HTTPS, OAI, política de acceso restringido  
Automatización: Terraform + GitHub Actions  
Costo controlado: AWS Budgets + destrucción segura

---

## 🧪 5. Flujo CI/CD

```
graph LR
    A[👨‍💻 Código Fuente] --> B[📦 GitHub Repo]
    B --> C[🤖 GitHub Actions]
    C --> D[🏗️ Terraform Apply en AWS]
    D --> E[🌐 Sitio Web Activo con HTTPS]
```

---

## 🔧 6. Prerrequisitos

| Componente   | Propósito                   |
|---------------|------------------------------|
| Cuenta AWS    | Desplegar infraestructura    |
| Cuenta GitHub | Ejecutar CI/CD              |
| Terraform CLI | Pruebas locales              |
| AWS CLI       | Configurar credenciales      |

---

## 📁 7. Estructura del Repositorio

```
aws-serverless-secure-website-workshop/
├── src/                  # Código HTML del sitio
├── terraform/            # Infraestructura como código
│   ├── main.tf           # Recursos AWS y lógica principal
│   ├── variables.tf      # Variables parametrizables
│   ├── outputs.tf        # Resultados como la URL del sitio
│   ├── providers.tf      # Proveedores y región AWS
│   └── README-GUIA.md    # Guía paso a paso del workshop
├── .github/workflows/    # Pipelines CI/CD (opcional)
├── LICENSE               # Licencia MIT
├── SECURITY.md           # Política de seguridad
├── README.md             # Portada del repositorio
```

---

## 🚀 8. Guía Paso a Paso

1. Clona el repositorio
2. Edita `terraform/variables.tf` con tu correo de alerta
3. Ejecuta localmente:

```
cd terraform
terraform init
terraform apply -auto-approve
```

4. Accede al sitio en el endpoint generado por CloudFront (por ejemplo: https://d123abc456xyz.cloudfront.net)

---

## ✅ 9. Validación post-deploy

Valida que el sitio esté seguro y optimizado:

- SSL Labs — Verifica el certificado HTTPS
- SecurityHeaders.com — Evalúa cabeceras de seguridad
- Lighthouse — Audita performance y accesibilidad

---

## 💸 10. FinOps y Destrucción Segura

Terraform crea un presupuesto en AWS Budgets.  
Si superas el umbral, recibirás una alerta por correo.

```
terraform destroy -auto-approve
```

Para eliminar todos los recursos y evitar cargos innecesarios.

---

## 🧠 11. Documentación extendida (opcional)

Puedes añadir explicaciones didácticas en `/docs/` para principiantes:

```
docs/que-es-cloudfront.md
docs/por-que-usar-oai.md
docs/finops-en-aws.md
```

---

## 👨‍🏫 12. Autor

José Garagorry  
🔗 LinkedIn · 🐙 GitHub · 📺 YouTube

---

## 📄 13. Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.
```

