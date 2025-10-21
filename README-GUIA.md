# 🛠️ Workshop: AWS Serverless Secure Website con Terraform

Este workshop enseña cómo desplegar un sitio web estático en AWS usando Terraform, aplicando buenas prácticas de seguridad, automatización, reproducibilidad y FinOps.

---

## 📁 Estructura del repositorio

```
aws-serverless-secure-website-workshop/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
├── src/
│   └── index.html
```

---

## 📦 ¿Qué hace cada archivo Terraform?

Todos los archivos `.tf` están dentro de la carpeta `terraform/` para mantener la infraestructura separada del contenido del sitio (`src/`). Terraform carga automáticamente todos los `.tf` del directorio activo, sin importar el orden alfabético. Sin embargo, el orden lógico de lectura y ejecución es el siguiente:

### `providers.tf`

- 📌 **Propósito**: Define los proveedores que usaremos (`aws`, `random`) y la región.
- 🧠 **Por qué es importante**: Sin esto, Terraform no sabe qué servicios usar ni dónde desplegar.
- 🧪 **Cuándo se usa**: En `terraform init`, para instalar los plugins necesarios.

### `variables.tf`

- 📌 **Propósito**: Declara las variables que podemos personalizar (`use_custom_domain`, `domain_name`, `budget_notification_email`).
- 🧠 **Por qué es importante**: Permite parametrizar el despliegue y hacerlo reutilizable.
- 🧪 **Cuándo se usa**: En `terraform plan` y `terraform apply`, cuando se solicitan valores o se usan condicionales.

### `main.tf`

- 📌 **Propósito**: Define todos los recursos de AWS que se van a crear.
- 🧠 **Por qué es importante**: Es el núcleo del despliegue: bucket, CloudFront, OAI, política, presupuesto, y subida automática del sitio.
- 🧪 **Cuándo se usa**: En `terraform plan`, `apply` y `destroy`.

### `outputs.tf`

- 📌 **Propósito**: Expone valores útiles después del despliegue, como la URL del sitio.
- 🧠 **Por qué es importante**: Permite mostrar resultados al usuario sin buscar en la consola.
- 🧪 **Cuándo se usa**: En `terraform apply` y `terraform output`.

---

## 🚀 Fase 1 – Validación local

Antes de desplegar, valida y formatea tu configuración:

```bash
terraform fmt
terraform validate
```

Esto asegura que la sintaxis esté correcta y el estilo sea consistente.

---

## ⚙️ Fase 2 – Inicialización y plan

Inicializa el entorno Terraform y genera el plan de ejecución:

```bash
terraform init
terraform plan
```

Verifica que el plan indique `add` y no haya errores. Si usas variables como `budget_notification_email`, se te pedirá ingresarlas.

---

## 🧩 Fase 3 – Despliegue automatizado y validación del sitio

Ejecuta el despliegue completo:

```bash
terraform apply -auto-approve
```

Esto crea automáticamente:

- 🪣 Un bucket S3 con nombre aleatorio (`random_pet`)
- 📦 Una distribución CloudFront con HTTPS y OAI
- 🛡️ Una política de acceso segura que permite solo a CloudFront leer el contenido
- 📤 Subida automática del archivo `src/index.html` al bucket mediante `aws_s3_object`
- 💸 Un presupuesto FinOps con alertas al correo definido

---

### ✅ Validación post-deploy

1. **Obtén la URL del sitio:**

```bash
terraform output site_url
```

Ejemplo:

```
site_url = "https://d9g53hw2erdpd.cloudfront.net"
```

2. **Accede al sitio en tu navegador** y verifica que se muestra el contenido de `index.html`.

3. **Valida seguridad y performance** con herramientas externas:

| Herramienta        | ¿Qué valida?             | Enlace                                      |
|--------------------|--------------------------|---------------------------------------------|
| SSL Labs           | HTTPS y cifrado          | https://www.ssllabs.com/ssltest/            |
| SecurityHeaders    | Cabeceras HTTP seguras   | https://securityheaders.com/                |
| Lighthouse         | Performance y accesibilidad | Chrome DevTools > Audits                |

---

## 🔥 Fase 4 – Destrucción segura (FinOps)

Una vez validado el despliegue, elimina todos los recursos para evitar costos:

```bash
terraform destroy -auto-approve
```

Esto elimina:

- El bucket S3
- La distribución CloudFront
- La política de acceso
- El presupuesto FinOps

---

## 📌 Notas didácticas

- El archivo `index.html` se sube automáticamente gracias al recurso `aws_s3_object`, eliminando el paso manual `aws s3 cp`.
- El nombre del bucket se genera dinámicamente con `random_pet` para evitar colisiones.
- La política de acceso restringe el contenido a CloudFront, siguiendo buenas prácticas de seguridad.
- El presupuesto FinOps permite enseñar control de costos desde el primer despliegue.
- El flujo completo es reproducible, validado y listo para ser integrado en GitHub Actions.

---

## 🎓 Recomendaciones para estudiantes

- Clona el repositorio y sigue las fases paso a paso.
- Modifica el archivo `src/index.html` para personalizar tu sitio.
- Usa `terraform destroy` al finalizar para evitar cargos.
- Comparte tu sitio y validación en redes como parte de tu portafolio DevOps.

