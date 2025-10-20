# 🧭 Guía Paso a Paso para el Workshop: Zero-Cost Secure Static Website on AWS

Esta guía te acompaña fase por fase para ejecutar el workshop desde tu entorno local (WSL) hasta la nube, aplicando prácticas reales de DevOps, DevSecOps, IaC y FinOps. Está diseñada para que puedas reproducir el despliegue sin errores, sin costos innecesarios y con validación completa.

---

## 🧩 Fase 0: Preparación del Entorno

### 🎯 Objetivo
Configurar todo lo necesario para ejecutar el workshop desde WSL de forma segura y reproducible.

### 🛠️ Acciones

1. Forkea el repositorio en tu cuenta de GitHub
2. Clónalo localmente en WSL:
   ```bash
   git clone https://github.com/TU_USUARIO/aws-serverless-secure-website-workshop.git
   cd aws-serverless-secure-website-workshop
   ```
3. Instala Terraform CLI en WSL
4. Configura tus credenciales AWS en WSL:
   ```bash
   export AWS_ACCESS_KEY_ID="TU_ACCESS_KEY"
   export AWS_SECRET_ACCESS_KEY="TU_SECRET_KEY"
   ```
5. Configura los mismos secretos en GitHub:
   - Ve a Settings > Secrets > Actions
   - Añade:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

### ✅ Buenas prácticas aplicadas
- Separación de infraestructura y código fuente
- Uso de secretos encriptados (DevSecOps)
- Repositorio modular y didáctico

---

## 🧩 Fase 1: Validación Local con Terraform

### 🎯 Objetivo
Verificar que la infraestructura se puede desplegar correctamente antes de usar CI/CD.

### 🛠️ Acciones

1. Desde WSL, entra a la carpeta Terraform:
   ```bash
   cd terraform
   terraform init
   terraform plan
   ```
2. Si el plan es correcto, puedes aplicar manualmente:
   ```bash
   terraform apply -auto-approve
   ```
3. Verifica que se haya creado el bucket y la distribución de CloudFront

4. Si estás en modo CI/CD, omite el `apply` local y continúa con la Fase 2

### ✅ Buenas prácticas aplicadas
- Validación previa al despliegue
- Infraestructura como código (IaC)
- Control de errores antes de automatizar

---

## 🧩 Fase 2: Despliegue Automatizado con GitHub Actions

### 🎯 Objetivo
Ejecutar el pipeline CI/CD para desplegar la infraestructura y el sitio web automáticamente.

### 🛠️ Acciones

1. Haz push a la rama `main`:
   ```bash
   git add .
   git commit -m "Inicio del workshop"
   git push origin main
   ```
2. Ve a la pestaña **Actions** en GitHub
3. Aprueba el workflow `Deploy Static Website`
4. Espera a que se complete el despliegue

### 🔍 ¿Qué se despliega?

- 🪣 S3 Bucket con el sitio estático
- 📦 CloudFront Distribution con HTTPS
- 🛡️ WAF y cabeceras de seguridad
- ⚙️ CloudFront Function
- 💸 AWS Budgets para control de costos

### ✅ Buenas prácticas aplicadas
- CI/CD con aprobación manual
- Seguridad desde el diseño (DevSecOps)
- FinOps: presupuesto con alertas
- Despliegue reproducible y automatizado

---

## 🧩 Fase 3: Análisis y Validación Post-Despliegue

### 🎯 Objetivo
Verificar que el sitio esté activo, seguro y optimizado.

### 🛠️ Acciones

1. Copia el endpoint de CloudFront desde la salida del workflow o desde WSL:
   ```bash
   terraform output site_url
   ```
2. Accede al sitio en tu navegador
3. Valida con herramientas externas:
   - [SSL Labs](https://www.ssllabs.com/ssltest/)
   - [SecurityHeaders.com](https://securityheaders.com/)
   - Lighthouse (desde Chrome DevTools)

### ✅ Buenas prácticas aplicadas
- Validación externa de seguridad y performance
- Uso de HTTPS sin dominio personalizado
- Cabeceras seguras con CloudFront Function

---

## 🧩 Fase 4: Destrucción Segura (FinOps)

### 🎯 Objetivo
Eliminar todos los recursos para evitar costos residuales.

### 🛠️ Acciones

1. Desde WSL:
   ```bash
   terraform destroy -auto-approve
   ```
2. O desde GitHub:
   - Ve a la pestaña **Actions**
   - Ejecuta el workflow `Destroy Infrastructure`
3. Confirma que el mensaje final indique éxito

### 🔥 ¿Qué se destruye?

- 🪣 S3 Bucket
- 📦 CloudFront Distribution
- 🛡️ WAF
- ⚙️ CloudFront Function
- 💸 AWS Budgets

### ✅ Buenas prácticas aplicadas
- FinOps: destrucción total automatizada
- Terraform `force_destroy` en S3
- Eliminación de presupuestos y configuraciones

---

## 🧠 Extras y Extensiones

- Puedes crear la carpeta `/docs/` con explicaciones para principiantes
- Puedes exportar los diagramas como PNG para tus redes
- Puedes crear un release `v1.0.0` para compartir una versión estable

---

## 🧑‍🏫 Autor

**Jesús Garagorry**  
[🔗 LinkedIn](https://www.linkedin.com/in/jgaragorry/) · [🐙 GitHub](https://github.com/jgaragorry) · [📺 YouTube](https://www.youtube.com/@Softraincorp)

---

## 📄 Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

