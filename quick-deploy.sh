#!/bin/bash

# Script de Deploy Rápido para Workshop S3
# Uso: ./quick-deploy.sh nombre-del-bucket ruta-del-sitio

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo "🚀 Script de Deploy Rápido para S3"
    echo ""
    echo "Uso: $0 <nombre-bucket> <ruta-sitio> [region]"
    echo ""
    echo "Parámetros:"
    echo "  nombre-bucket    Nombre único para el bucket S3"
    echo "  ruta-sitio      Ruta local del sitio web"
    echo "  region          Región AWS (opcional, default: us-east-1)"
    echo ""
    echo "Ejemplo:"
    echo "  $0 mi-sitio-2026 ./mi-sitio us-east-1"
    echo ""
    echo "Prerrequisitos:"
    echo "  - AWS CLI instalado y configurado"
    echo "  - Permisos para crear buckets S3"
    echo ""
}

# Verificar parámetros
if [ $# -lt 2 ]; then
    show_help
    exit 1
fi

BUCKET_NAME=$1
SITE_PATH=$2
REGION=${3:-us-east-1}

# Verificar que AWS CLI esté instalado
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI no está instalado${NC}"
    echo "Instala AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Verificar que el directorio del sitio existe
if [ ! -d "$SITE_PATH" ]; then
    echo -e "${RED}❌ El directorio $SITE_PATH no existe${NC}"
    exit 1
fi

# Verificar que existe index.html
if [ ! -f "$SITE_PATH/index.html" ]; then
    echo -e "${RED}❌ No se encontró index.html en $SITE_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Iniciando deploy del sitio estático...${NC}"
echo -e "${BLUE}📦 Bucket: $BUCKET_NAME${NC}"
echo -e "${BLUE}📁 Sitio: $SITE_PATH${NC}"
echo -e "${BLUE}🌍 Región: $REGION${NC}"
echo ""

# Paso 1: Crear bucket
echo -e "${YELLOW}📦 Creando bucket S3...${NC}"
if aws s3 mb s3://$BUCKET_NAME --region $REGION 2>/dev/null; then
    echo -e "${GREEN}✅ Bucket creado exitosamente${NC}"
else
    echo -e "${YELLOW}⚠️  El bucket ya existe o no se pudo crear${NC}"
fi

# Paso 2: Remover block public access
echo -e "${YELLOW}🔓 Configurando acceso público...${NC}"
aws s3api delete-public-access-block --bucket $BUCKET_NAME 2>/dev/null || true

# Paso 3: Configurar website hosting
echo -e "${YELLOW}🌐 Configurando website hosting...${NC}"
aws s3 website s3://$BUCKET_NAME \
    --index-document index.html \
    --error-document error.html

# Paso 4: Crear política de bucket
echo -e "${YELLOW}📋 Configurando política de bucket...${NC}"
cat > /tmp/bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file:///tmp/bucket-policy.json

# Paso 5: Subir archivos
echo -e "${YELLOW}📤 Subiendo archivos...${NC}"
aws s3 sync $SITE_PATH s3://$BUCKET_NAME/ \
    --delete \
    --acl public-read \
    --cache-control "max-age=3600"

# Paso 6: Configurar tipos MIME
echo -e "${YELLOW}🔧 Configurando tipos MIME...${NC}"

# HTML files
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --metadata-directive REPLACE \
    --content-type "text/html" \
    --exclude "*" \
    --include "*.html" \
    --acl public-read

# CSS files
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --metadata-directive REPLACE \
    --content-type "text/css" \
    --exclude "*" \
    --include "*.css" \
    --acl public-read

# JavaScript files
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --metadata-directive REPLACE \
    --content-type "application/javascript" \
    --exclude "*" \
    --include "*.js" \
    --acl public-read

# Limpiar archivos temporales
rm -f /tmp/bucket-policy.json

# Obtener URL del sitio
WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

echo ""
echo -e "${GREEN}🎉 ¡Deploy completado exitosamente!${NC}"
echo ""
echo -e "${GREEN}🌐 URL del sitio: $WEBSITE_URL${NC}"
echo ""
echo -e "${BLUE}📊 Información del bucket:${NC}"
aws s3 ls s3://$BUCKET_NAME --recursive --human-readable --summarize

echo ""
echo -e "${YELLOW}⏰ Nota: Puede tomar unos minutos para que el sitio esté disponible${NC}"
echo ""
echo -e "${BLUE}🔗 Comandos útiles:${NC}"
echo -e "${BLUE}   Ver archivos: aws s3 ls s3://$BUCKET_NAME --recursive${NC}"
echo -e "${BLUE}   Actualizar:   aws s3 sync $SITE_PATH s3://$BUCKET_NAME/ --delete${NC}"
echo -e "${BLUE}   Eliminar:     aws s3 rb s3://$BUCKET_NAME --force${NC}"
echo ""

# Verificar si el sitio responde
echo -e "${YELLOW}🔍 Verificando que el sitio responda...${NC}"
sleep 5

if curl -s --head $WEBSITE_URL | head -n 1 | grep -q "200 OK"; then
    echo -e "${GREEN}✅ El sitio está respondiendo correctamente${NC}"
else
    echo -e "${YELLOW}⚠️  El sitio aún no responde, espera unos minutos más${NC}"
fi

echo ""
echo -e "${GREEN}🚀 ¡Tu sitio está listo! Comparte la URL: $WEBSITE_URL${NC}"
