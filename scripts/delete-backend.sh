#!/bin/bash

BUCKET_NAME="secure-static-site-central-seagull"

echo "⚠️ Vas a eliminar el bucket remoto de Terraform backend:"
echo "📦 Bucket: $BUCKET_NAME"
echo
read -p "¿Estás seguro de que deseas continuar? (escribe 'si' para confirmar): " CONFIRM

if [[ "$CONFIRM" != "si" ]]; then
  echo "❌ Operación cancelada por el usuario."
  exit 1
fi

echo "⏳ Eliminando objetos actuales del bucket..."
aws s3 rm s3://"$BUCKET_NAME" --recursive

echo "⏳ Verificando si el bucket tiene versionado habilitado..."
VERSIONING_STATUS=$(aws s3api get-bucket-versioning --bucket "$BUCKET_NAME" --query 'Status' --output text)

if [[ "$VERSIONING_STATUS" == "Enabled" ]]; then
  echo "🔍 Versionado habilitado. Eliminando versiones anteriores..."

  # Obtener todas las versiones
  aws s3api list-object-versions --bucket "$BUCKET_NAME" \
    --query 'Versions[].{Key:Key,VersionId:VersionId}' \
    --output json > /tmp/versions.json

  # Obtener todos los marcadores de eliminación
  aws s3api list-object-versions --bucket "$BUCKET_NAME" \
    --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' \
    --output json > /tmp/deletemarkers.json

  # Eliminar versiones si existen
  if grep -q '"Key":' /tmp/versions.json; then
    echo "⏳ Eliminando versiones..."
    aws s3api delete-objects --bucket "$BUCKET_NAME" --delete file:///tmp/versions.json
  else
    echo "✅ No hay versiones que eliminar."
  fi

  # Eliminar marcadores si existen
  if grep -q '"Key":' /tmp/deletemarkers.json; then
    echo "⏳ Eliminando marcadores de eliminación..."
    aws s3api delete-objects --bucket "$BUCKET_NAME" --delete file:///tmp/deletemarkers.json
  else
    echo "✅ No hay marcadores de eliminación que eliminar."
  fi
else
  echo "ℹ️ El bucket no tiene versionado habilitado. No se requieren pasos adicionales."
fi

echo "⏳ Eliminando bucket..."
aws s3api delete-bucket --bucket "$BUCKET_NAME"

echo
echo "✅ Bucket eliminado completamente, incluyendo versiones y marcadores si existían."

