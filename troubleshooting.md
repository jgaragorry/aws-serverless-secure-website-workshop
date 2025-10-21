## ✅ Migración al backend remoto en S3

**Objetivo:** Asegurar que `deploy.yml` y `destroy.yml` compartan el mismo estado para rastrear y destruir recursos correctamente.

---

### 🔧 Paso 1: Configurar el backend remoto en `main.tf`

Se agregó al inicio del archivo:

```hcl
terraform {
  backend "s3" {
    bucket = "secure-static-site-central-seagull"
    key    = "terraform/terraform.tfstate"
    region = "us-east-1"
  }
}
```

Este bucket debe existir previamente en AWS S3. Se recomienda habilitar versioning y aplicar políticas de acceso seguras.

---

### 🧪 Paso 2: Inicializar Terraform con el backend remoto

```bash
terraform -chdir=terraform init
```

Terraform confirma:

```
Successfully configured the backend "s3"!
Terraform will automatically use this backend unless the backend configuration changes.
```

---

### 🚀 Paso 3: Aplicar la infraestructura y migrar el estado

```bash
terraform -chdir=terraform apply -auto-approve
```

Resultado:

```
Apply complete! Resources: 9 added, 0 changed, 0 destroyed.
```

---

### 📁 Paso 4: Validar que el estado fue migrado al bucket S3

```bash
aws s3 ls s3://secure-static-site-central-seagull/terraform/
```

Resultado esperado:

```
2025-10-21 14:07:52      17690 terraform.tfstate
```

---

### ✅ Resultado

- El estado de Terraform ahora está centralizado y compartido
- `destroy.yml` puede acceder al estado y borrar los recursos correctamente
- Se evita la creación de recursos huérfanos en cada push
- Se puede listar recursos con `terraform state list` desde cualquier entorno

---

### 🧪 Validación CLI para destrucción

```bash
terraform -chdir=terraform state list
terraform -chdir=terraform destroy -auto-approve
```

Esto garantiza que los recursos creados por `deploy.yml` sean visibles y destruibles por `destroy.yml`.

---

## ✅ Validación de `destroy.yml` con backend remoto

**Objetivo:** Confirmar que `destroy.yml` puede acceder al estado remoto y destruir todos los recursos creados por `deploy.yml`.

---

### 🧪 Paso 1: Confirmar que el estado remoto está activo

```bash
aws s3 ls s3://secure-static-site-central-seagull/terraform/
```

Resultado esperado:

```
2025-10-21 14:07:52      17690 terraform.tfstate
```

Esto confirma que el estado está guardado en el bucket remoto y es accesible por cualquier workflow que use el mismo backend.

---

### 🔍 Paso 2: Verificar los recursos registrados en el estado

```bash
terraform -chdir=terraform state list
```

Esto muestra todos los recursos que Terraform tiene registrados y que serán destruidos. Ejemplo:

```
aws_s3_bucket.website_bucket
aws_cloudfront_distribution.cdn
aws_budgets_budget.monthly_budget
...
```

---

### 🧨 Paso 3: Ejecutar `destroy.yml` manualmente

Desde GitHub Actions, ejecuta el workflow `destroy.yml` usando `workflow_dispatch`. Asegúrate de que incluya:

```yaml
- name: Terraform Init
  run: terraform -chdir=terraform init

- name: Terraform Destroy
  run: terraform -chdir=terraform destroy -auto-approve
```

---

### ✅ Paso 4: Validar que los recursos fueron eliminados

Desde la consola de AWS o CLI:

```bash
aws s3 ls
aws cloudfront list-distributions
```

Confirma que los recursos como buckets y distribuciones ya no existen.

---

### 🧠 Resultado

- `destroy.yml` accede al estado remoto y destruye todos los recursos registrados
- Se evita la acumulación de recursos huérfanos
- El flujo completo `deploy.yml → destroy.yml` es reproducible y seguro

---
## ✅ Validación final de `destroy.yml` tras sincronización

**Objetivo:** Confirmar que el error `412 PreconditionFailed` se resuelve al sincronizar el estado con `terraform refresh`.

---

### 🧪 Paso 1: Ejecutar `terraform refresh`

```bash
terraform -chdir=terraform refresh
```

Esto actualiza el estado remoto con la configuración real en AWS. Resultado esperado:

```
aws_cloudfront_distribution.cdn: Refreshing state... [id=EU2C1507QBLS9]
```

---

### 🚀 Paso 2: Ejecutar `destroy.yml` desde GitHub Actions

Desde la pestaña **Actions**, selecciona `Destroy AWS Static Site` y haz clic en **Run workflow**.

---

### ✅ Resultado esperado

- Todos los recursos son destruidos sin errores
- El estado remoto se limpia
- El flujo `deploy.yml → destroy.yml` queda validado

---

### 🧨 Si el error persiste

- Verifica si la distribución de CloudFront fue modificada manualmente
- Elimínala desde la consola de AWS
- Ejecuta nuevamente `terraform destroy -auto-approve` para limpiar el resto

---


## ✅ Checklist final para estudiantes

Antes de considerar el flujo como validado, asegúrate de cumplir con los siguientes puntos:

- [x] El backend remoto está configurado en `main.tf` y apunta a un bucket S3 existente
- [x] Se ejecutó `terraform init` y se confirmó la migración del estado
- [x] Se aplicó la infraestructura con `terraform apply` y se generó `terraform.tfstate` en S3
- [x] Se verificó el estado remoto con `aws s3 ls`
- [x] Se listaron los recursos con `terraform state list`
- [x] Se ejecutó `destroy.yml` manualmente desde GitHub Actions
- [x] Se confirmó que los recursos fueron eliminados desde la consola de AWS o CLI
- [x] Se documentó todo el proceso en `troubleshooting.md` para futuras referencias

---

✅ Si todos los puntos están marcados, el flujo `deploy.yml → destroy.yml` está validado, reproducible y listo para enseñanza o producción.

