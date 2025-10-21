# 🛠️ Workshop: Despliegue y destrucción automática de sitio estático seguro en AWS con Terraform y GitHub Actions

## 📋 Descripción General

Este workshop guía a través del despliegue automatizado de un sitio web estático seguro en AWS utilizando Terraform como Infraestructura como Código (IaC) y GitHub Actions para CI/CD. Incluye prácticas de seguridad, monitoreo de costos (FinOps) y destrucción automática de recursos.

## 🎯 Objetivos de Aprendizaje

- **Infraestructura como Código (IaC)**: Utilizar Terraform para definir y gestionar recursos AWS
- **CI/CD Automatizado**: Implementar pipelines con GitHub Actions
- **Seguridad**: Configurar políticas IAM mínimas y distribución segura con CloudFront + S3
- **FinOps**: Monitorear costos con AWS Budgets
- **Resolución de Problemas**: Diagnosticar y solucionar errores comunes en despliegues automatizados

## 🏗️ Arquitectura de la Solución

Usuario → CloudFront (CDN) → S3 Bucket (Sitio Estático)  
↓  
AWS Budgets (Alertas)

## ⚙️ Prerrequisitos

- Cuenta AWS con permisos administrativos  
- Cuenta GitHub con acceso a GitHub Actions  
- Terraform instalado localmente (opcional, para testing)  
- AWS CLI configurado (opcional)

## 📘 Reproducción completa del workshop desde cero

Para ver el procedimiento validado paso a paso, consulta [`steps.md`](./steps.md). Incluye desde la creación del backend remoto hasta la destrucción de la infraestructura con GitHub Actions.


## 🚀 Despliegue Manual con Terraform

```bash
git clone https://github.com/jgaragorry/aws-serverless-secure-website-workshop
cd aws-serverless-secure-website-workshop/terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform output -raw site_url
```

## 🔐 Configuración Crítica de Credenciales AWS en GitHub Actions

⚠️ Esta configuración es fundamental para el funcionamiento del despliegue automatizado. Si no se configura desde el inicio, Terraform no podrá autenticarse con AWS, y todos los pasos del workflow fallarán.

### ✅ Configuración de Secrets en GitHub

Ir al repositorio → Settings → Secrets and variables → Actions  
Crear los siguientes secretos:

| Nombre               | Valor (desde AWS IAM)                  |
|----------------------|----------------------------------------|
| AWS_ACCESS_KEY_ID    | Ejemplo: AKIAIOSFODNN7EXAMPLE          |
| AWS_SECRET_ACCESS_KEY| Ejemplo: wJalrXUtnFEMI/K7MDENG/...     |

💡 Asegúrate de copiar los valores sin espacios extra, saltos de línea ni caracteres ocultos. Usa texto plano.

### 🧠 ¿Por qué es importante?

Terraform usa estas variables para autenticarse con AWS. Si no están definidas correctamente:

- `terraform plan` falla con `No valid credential sources found`  
- `terraform apply` no puede crear recursos  
- El workflow completo se detiene

## 🚀 Despliegue Automático con GitHub Actions

Archivo: `.github/workflows/deploy.yml`  
Este workflow se ejecuta automáticamente al hacer push a la rama `main`:

1. Checkout del código  
2. Configuración de credenciales AWS usando GitHub Secrets  
3. `terraform init`  
4. `terraform plan -var-file=terraform.tfvars`  
5. `terraform apply`  
6. `terraform output -raw site_url`  
7. `curl -I $site_url` para verificar que el sitio esté activo

### 🧠 Corrección Importante en Output

Para evitar errores de formato en `$GITHUB_OUTPUT`, se debe usar:

```yaml
- name: Obtener URL del sitio
  id: terraform_output
  run: |
    site_url=$(terraform -chdir=terraform output -raw site_url)
    echo "site_url=$site_url" >> $GITHUB_OUTPUT
```

### 🧪 Validación Esperada

- `terraform plan` y `apply` funcionan sin errores  
- Se extrae la URL del sitio con `terraform output`  
- El sitio se verifica con `curl -I` y retorna estado 200

## 🧹 Destrucción Automática con GitHub Actions

Archivo: `.github/workflows/destroy.yml`  
Permite destruir toda la infraestructura manualmente desde la pestaña Actions de GitHub.

### Flujo del workflow:

1. `terraform init`  
2. `terraform destroy -auto-approve -var-file=terraform.tfvars`

### ✅ Ejecución Manual

Ir a GitHub → pestaña Actions  
Seleccionar el workflow `Destroy Infrastructure`  
Click en `Run workflow`

## 🔍 Verificación Manual Post-Destroy en AWS

Aunque `terraform destroy` reporta eliminación completa, puede que queden recursos activos en consola AWS, especialmente distribuciones CloudFront.

### 🧠 Diagnóstico

Recursos creados o modificados fuera del control de Terraform no pueden ser destruidos automáticamente.  
Ejemplo: distribuciones CloudFront activas que no están en estado Terraform.

### ✅ Solución Aplicada

- Deshabilitar la distribución manualmente en la consola AWS  
- Esperar la propagación de cambios  
- Eliminar manualmente la distribución residual

## 📋 Checklist de Verificación Post-Destroy

- S3 → Buckets: no debe existir `secure-static-site-*`  
- CloudFront → Distributions: ninguna activa  
- Billing → Budgets: presupuesto eliminado  
- (Opcional) IAM → Roles/Policies: sin residuos  
- (Opcional) CloudFormation / EC2 / Elastic IPs: sin recursos huérfanos

## 🛠️ Estructura de Archivos Terraform

```text
terraform/
├── main.tf              # Recursos principales
├── variables.tf         # Variables definidas
├── terraform.tfvars     # Valores de variables
├── outputs.tf           # Outputs para GitHub Actions
└── providers.tf         # Configuración de providers
```

## 🛠️  Estructura del REPO

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


## 📦 Recursos Principales Creados

- S3 Bucket: Almacenamiento estático del sitio web  
- CloudFront Distribution: CDN para distribución global y HTTPS  
- IAM Policies: Permisos mínimos necesarios  
- AWS Budget: Monitoreo de costos y alertas

## 🧪 Reproducción del Workshop para Validación Completa

### Proceso de Validación

1. Despliegue Inicial: Ejecutar workflow de deploy  
2. Verificación Funcional: Confirmar que el sitio está accesible  
3. Destrucción: Ejecutar workflow de destroy  
4. Limpieza Manual: Verificar y eliminar recursos residuales  
5. Repetición: Confirmar que el proceso es reproducible

### Criterios de Éxito

- Todos los recursos se crean bajo control de Terraform  
- No quedan residuos manuales después de destroy  
- El modelo es reproducible y consistente  
- Las credenciales se gestionan de forma segura  
- Los costos se monitorean adecuadamente

## 🔧 Troubleshooting Común

- **Error**: `No valid credential sources found`  
  **Causa**: Secrets de AWS no configurados correctamente en GitHub  
  **Solución**: Verificar formato y valores en GitHub Secrets

- **Error**: `CloudFront distribution still exists after destroy`  
  **Causa**: Distribución no completamente deshabilitada  
  **Solución**: Deshabilitar manualmente y esperar propagación

- **Error**: `BucketNotEmpty` durante destroy  
  **Causa**: Objetos residuales en bucket S3  
  **Solución**: Vaciar bucket manualmente antes de destroy
---

## 🛠️ Troubleshooting y validación del flujo completo

Este workshop documenta no solo el despliegue exitoso de una infraestructura segura en AWS, sino también los errores encontrados y cómo se resolvieron de forma reproducible y didáctica.

Para revisar los problemas comunes, las correcciones aplicadas y cómo validar que el flujo `deploy.yml → destroy.yml` funciona correctamente con backend remoto, consulta el archivo:

📄 [`troubleshooting.md`](./troubleshooting.md)

Incluye:

- Migración al backend remoto en S3
- Validación de estado compartido entre workflows
- Ejecución y verificación de `destroy.yml`
- Checklist final para estudiantes

Este archivo forma parte integral del aprendizaje del workshop y debe ser revisado antes de avanzar a nuevas fases.

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

## ⚙️ Automatización del backend remoto

Este workshop incluye dos scripts para facilitar la creación y eliminación del bucket remoto que almacena el estado de Terraform (`terraform.tfstate`):

- [`create-backend.sh`](./scripts/create-backend.sh): crea el bucket con versionado habilitado
- [`delete-backend.sh`](./scripts/delete-backend.sh): elimina el bucket con confirmación y soporte para versionado

Consulta [`steps.md`](./steps.md) para ver el flujo completo validado desde cero.

---

## 📝 Conclusión

Este workshop demuestra un flujo completo de DevOps para infraestructura serverless en AWS, integrando mejores prácticas de seguridad, automatización y gestión de costos. El enfoque en la destrucción automática asegura control de costos y reproduceibilidad.

¿Listo para implementar? 🚀 Configura correctamente las credenciales AWS en GitHub Secrets y sigue los workflows automatizados para un despliegue sin problemas.


