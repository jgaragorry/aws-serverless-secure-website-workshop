# 🧭 Guía Paso a Paso para el Workshop: Zero-Cost Secure Static Website on AWS

Este documento te guía fase por fase para ejecutar el workshop de forma ordenada, reproducible y sin incurrir en costos innecesarios. Está diseñado para estudiantes, profesionales y educadores que buscan aplicar DevOps, DevSecOps, IaC y FinOps en un proyecto real.

---

## 🧩 Fase 0: Preparación del Entorno

### 🎯 Objetivo
Configurar todo lo necesario para ejecutar el workshop sin errores ni gastos innecesarios.

### 🛠️ Acciones

1. Forkea el repositorio en tu cuenta de GitHub
2. Clónalo localmente:
   ```bash
   git clone https://github.com/TU_USUARIO/aws-serverless-secure-website-workshop.git
   ```
3. Instala Terraform CLI
4. Crea una cuenta gratuita en AWS
5. Configura tus credenciales en GitHub:
   - Ve a Settings > Secrets > Actions
   - Añade:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

### ✅ Buenas prácticas aplicadas
- Uso de secretos encriptados (DevSecOps)
- Separación de infraestructura y código fuente
- Repositorio modular y didáctico

---

## 🧩 Fase 1: Configuración de Variables

### 🎯 Objetivo
Definir parámetros clave para el despliegue, sin usar dominio personalizado.

### 🛠️ Acciones

1. Abre `terraform/variables.tf`
2. Asegúrate de que `use_custom_domain = false`
3. Define tu correo para alertas de presupuesto:
   ```hcl
   budget_notification_email = "tu@email.com"
   ```

### ✅ Buenas prácticas aplicadas
- FinOps: alertas de presupuesto
- Flexibilidad: soporte para despliegue con o sin dominio

---

## 🧩 Fase 2: Despliegue Automatizado

### 🎯 Objetivo
Ejecutar el pipeline CI/CD para desplegar la infraestructura y el sitio web.

### 🛠️ Acciones

1. Haz push a la rama `main`
2. Ve a la pestaña **Actions** en GitHub
3. Aprueba el workflow `Deploy Static Website`
4. Espera a que se complete el despliegue

### 🔍 ¿Qué se despliega?

- 🪣 S3 Bucket con el sitio estático
- 📦 CloudFront Distribution con HTTPS
- 🛡️ WAF y cabeceras de seguridad
- 💸 AWS Budgets para control de costos

### ✅ Buenas prácticas aplicadas
- CI/CD con aprobación manual
- Seguridad desde el diseño (DevSecOps)
- Infraestructura como código (IaC)

---

## 🧩 Fase 3: Validación Post-Despliegue

### 🎯 Objetivo
Verificar que el sitio esté activo, seguro y optimizado.

### 🛠️ Acciones

1. Copia el endpoint de CloudFront desde la salida del workflow
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

1. Ve a la pestaña **Actions**
2. Ejecuta el workflow `Destroy Infrastructure`
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

