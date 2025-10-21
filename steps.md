# 🧭 Reproducción completa del workshop desde cero (con backend remoto y GitHub Actions)

Este documento describe paso a paso cómo reproducir el workshop desde cero, validando el backend remoto en S3, el despliegue automático con `deploy.yml`, y la destrucción manual con `destroy.yml`. Cada paso incluye su propósito y explicación didáctica.

## ⚙️ Automatización del backend remoto de Terraform

Este workshop utiliza un bucket S3 como backend remoto para almacenar el estado de Terraform (`terraform.tfstate`). Para facilitar su creación y eliminación controlada, se incluyen dos scripts Bash didácticos:

---

### 🛠️ `create-backend.sh` — Crear el bucket remoto

Este script crea el bucket en la región `us-east-1` y habilita el versionado.

```bash
#!/bin/bash

BUCKET_NAME="secure-static-site-central-seagull"
REGION="us-east-1"

echo "🚀 Iniciando creación del bucket remoto para Terraform backend..."
echo "📦 Bucket: $BUCKET_NAME"
echo "🌍 Región: $REGION"
echo

# Verificar si el bucket ya existe
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "⚠️ El bucket '$BUCKET_NAME' ya existe. No se realizará ninguna acción."
  exit 0
fi

# Crear el bucket
echo "⏳ Creando bucket..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION"

# Habilitar versionado
echo "⏳ Habilitando versionado..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo
echo "✅ Bucket creado y versionado correctamente."
echo "📍 Usa este bucket en tu backend de Terraform para almacenar terraform.tfstate"
```

---

### 💣 `delete-backend.sh` — Eliminar el bucket remoto (con confirmación)

Este script elimina todos los objetos del bucket y luego lo borra, **solo si el usuario confirma explícitamente**.

```bash
#!/bin/bash

BUCKET_NAME="secure-static-site-central-seagull"

echo "⚠️ Vas a eliminar el bucket remoto de Terraform backend:"
echo "📦 Bucket: $BUCKET_NAME"
echo
read -p "¿Estás seguro de que deseas continuar? (escribe 'sí' para confirmar): " CONFIRM

if [[ "$CONFIRM" != "sí" ]]; then
  echo "❌ Operación cancelada por el usuario."
  exit 1
fi

echo "⏳ Eliminando objetos del bucket..."
aws s3 rm s3://"$BUCKET_NAME" --recursive

echo "⏳ Eliminando bucket..."
aws s3api delete-bucket \
  --bucket "$BUCKET_NAME"

echo
echo "✅ Bucket eliminado completamente."
```

---

### 🧠 Consideraciones didácticas

- Estos scripts **no son gestionados por Terraform**, ya que el bucket del backend debe existir antes de ejecutar `terraform init`.
- El script de eliminación requiere confirmación explícita (`sí`) para evitar errores accidentales.
- Puedes incluir estos scripts en una carpeta `scripts/` y referenciarlos en tu guía como parte del flujo de preparación y limpieza del entorno.

---

### 📁 Ubicación sugerida

```
aws-serverless-secure-website-workshop/
├── scripts/
│   ├── create-backend.sh
│   └── delete-backend.sh
```

---

### 📚 Uso en el flujo del workshop

- Ejecutar `create-backend.sh` antes de `terraform init`
- Ejecutar `delete-backend.sh` solo si deseas limpiar completamente el entorno



---

## 1️⃣ Crear el bucket remoto para el backend de Terraform

```bash
aws s3api create-bucket \
  --bucket secure-static-site-central-seagull \
  --region us-east-1
```

> ⚠️ En `us-east-1` no se debe usar `--create-bucket-configuration`

### (Opcional) Habilitar versionado

```bash
aws s3api put-bucket-versioning \
  --bucket secure-static-site-central-seagull \
  --versioning-configuration Status=Enabled
```

🎯 **¿Por qué?**  
Este bucket almacenará el archivo `terraform.tfstate`, que representa el estado de la infraestructura. Usar un backend remoto permite compartir y persistir el estado entre ejecuciones locales y GitHub Actions.

---

## 2️⃣ Configurar el backend en `main.tf`

```hcl
terraform {
  backend "s3" {
    bucket = "secure-static-site-central-seagull"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
```

🎯 **¿Por qué?**  
Esto le indica a Terraform que debe guardar el estado en el bucket remoto, no localmente. Es esencial para reproducibilidad y CI/CD.

---

## 3️⃣ Inicializar Terraform

```bash
terraform -chdir=terraform init
```

🎯 **¿Por qué?**  
Inicializa el backend remoto, descarga proveedores y prepara el entorno para aplicar la infraestructura.

---

## 4️⃣ Aplicar la infraestructura manualmente (opcional pero recomendado)

```bash
terraform -chdir=terraform apply -auto-approve
```

🎯 **¿Por qué?**  
Permite validar que el backend remoto funciona correctamente antes de automatizar. También ayuda a diagnosticar errores sin esperar a que falle el workflow.

---

## 5️⃣ Confirmar que el estado se guardó en S3

```bash
aws s3 ls s3://secure-static-site-central-seagull/terraform/
```

🎯 **¿Por qué?**  
Verifica que `terraform.tfstate` fue creado y está siendo gestionado remotamente.

---

## 6️⃣ Configurar `deploy.yml` para despliegue automático

```yaml
on:
  push:
    branches:
      - main
```

🎯 **¿Por qué?**  
Permite que cualquier cambio en la rama `main` active automáticamente el despliegue de la infraestructura desde GitHub Actions.

---

## 7️⃣ Validar despliegue automático con un cambio mínimo

```bash
vi terraform/main.tf
git add .
git commit -m "se coloco el correo gmail.com"
git push origin main
```

🎯 **¿Por qué?**  
Simula un cambio real. El push activa `deploy.yml`, que ejecuta `terraform init`, `plan`, `apply` y despliega la infraestructura.

---

## 8️⃣ Confirmar que el sitio fue desplegado

Desde la salida del workflow en GitHub Actions:

```
✅ Sitio desplegado en: https://<cloudfront-domain>.cloudfront.net
```

🎯 **¿Por qué?**  
Confirma que el flujo CI/CD está funcionando correctamente y que la infraestructura fue creada desde GitHub.

---

## 9️⃣ Ejecutar `destroy.yml` manualmente desde GitHub Actions

Desde la pestaña **Actions** → `Destroy AWS Static Site` → **Run workflow**

🎯 **¿Por qué?**  
Permite destruir todos los recursos creados por Terraform de forma controlada y reproducible, usando el mismo estado remoto.

---

## 🔁 ¿Qué recursos se destruyen?

- S3 bucket del sitio
- CloudFront distribution
- Origin Access Control
- Response Headers Policy
- Presupuesto AWS
- Objetos HTML
- Recursos auxiliares (`random_pet`, políticas, bloqueos públicos)

---

## 🧱 ¿Qué recurso permanece?

✅ El bucket `secure-static-site-central-seagull` **no se destruye** porque:

- No está definido como recurso en `main.tf`
- Es gestionado manualmente como backend remoto
- Terraform no lo conoce, por lo tanto no lo puede destruir

🎯 **¿Por qué es importante?**  
Este bucket debe persistir para futuras ejecuciones. Es el núcleo del control de estado y permite reproducir el workshop cuantas veces quieras.

---

## ✅ Resultado final

| Elemento | Estado |
|----------|--------|
| Backend remoto | ✅ Persistente y funcional |
| Infraestructura | ✅ Desplegada y destruida exitosamente |
| `deploy.yml` | ✅ Activado por push a `main` |
| `destroy.yml` | ✅ Ejecutado manualmente desde GitHub |
| Estado en S3 | ✅ Sin recursos activos, pero backend intacto |

---

Este procedimiento garantiza que el workshop es **100% reproducible**, **seguro**, y **enseñable** desde cero, con validación de cada paso y control total desde GitHub Actions.

