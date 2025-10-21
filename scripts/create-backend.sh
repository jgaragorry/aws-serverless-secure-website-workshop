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

