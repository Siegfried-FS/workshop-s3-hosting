#!/bin/bash

# Script Automático para Deploy S3 - Workshop
# Uso: ./auto-deploy.sh nombre-bucket ruta-sitio

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para mostrar paso
show_step() {
    echo ""
    echo -e "${BLUE}🔄 PASO $1: $2${NC}"
    echo "----------------------------------------"
}

# Función para validar nombre de bucket
validate_bucket_name() {
    local name=$1
    
    # Verificar longitud (3-63 caracteres)
    if [ ${#name} -lt 3 ] || [ ${#name} -gt 63 ]; then
        echo -e "${RED}❌ Nombre de bucket debe tener entre 3 y 63 caracteres${NC}"
        return 1
    fi
    
    # Verificar que solo contenga caracteres válidos
    if [[ ! $name =~ ^[a-z0-9][a-z0-9.-]*[a-z0-9]$ ]]; then
        echo -e "${RED}❌ Nombre de bucket inválido${NC}"
        echo -e "${RED}Debe contener solo: minúsculas, números, puntos y guiones${NC}"
        echo -e "${RED}Debe empezar y terminar con letra o número${NC}"
        return 1
    fi
    
    # Verificar que no parezca IP
    if [[ $name =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}❌ El nombre no puede parecer una dirección IP${NC}"
        return 1
    fi
    
    return 0
}

# Función para sugerir nombres alternativos
suggest_bucket_name() {
    local base_name=$1
    local timestamp=$(date +%s)
    local random=$(shuf -i 1000-9999 -n 1 2>/dev/null || echo $RANDOM)
    
    echo -e "${YELLOW}💡 Nombres alternativos sugeridos:${NC}"
    echo -e "${YELLOW}   • $base_name-$timestamp${NC}"
    echo -e "${YELLOW}   • $base_name-$random${NC}"
    echo -e "${YELLOW}   • $base_name-$(whoami)-2026${NC}"
}

# Función para validar éxito
validate_step() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1 - ÉXITO${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 - ERROR${NC}"
        echo -e "${RED}Deteniendo script...${NC}"
        exit 1
    fi
}

# Verificar parámetros
if [ $# -ne 2 ]; then
    echo -e "${RED}❌ Uso: $0 <nombre-bucket> <ruta-sitio>${NC}"
    echo "Ejemplo: $0 mi-sitio-2026 ./mi-sitio"
    exit 1
fi

BUCKET_NAME=$1
SITE_PATH=$2
REGION="us-east-1"

echo -e "${BLUE}🚀 DEPLOY AUTOMÁTICO S3${NC}"
echo -e "${BLUE}📦 Bucket: $BUCKET_NAME${NC}"
echo -e "${BLUE}📁 Sitio: $SITE_PATH${NC}"

# Validar nombre de bucket
if ! validate_bucket_name $BUCKET_NAME; then
    suggest_bucket_name $BUCKET_NAME
    exit 1
fi

# PASO 1: Verificar prerrequisitos
show_step "1" "Verificando prerrequisitos"

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI no instalado${NC}"
    exit 1
fi

# Verificar credenciales
aws sts get-caller-identity > /dev/null 2>&1
validate_step "Credenciales AWS"

# Verificar directorio
if [ ! -d "$SITE_PATH" ]; then
    echo -e "${RED}❌ Directorio $SITE_PATH no existe${NC}"
    exit 1
fi

# Verificar index.html
if [ ! -f "$SITE_PATH/index.html" ]; then
    echo -e "${RED}❌ No se encontró index.html en $SITE_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerrequisitos - OK${NC}"

# PASO 2: Crear bucket
show_step "2" "Creando bucket S3"

# Verificar si el bucket ya existe
if aws s3 ls s3://$BUCKET_NAME 2>/dev/null; then
    echo -e "${YELLOW}⚠️  El bucket '$BUCKET_NAME' ya existe${NC}"
    
    # Verificar si es nuestro bucket
    if aws s3api get-bucket-location --bucket $BUCKET_NAME 2>/dev/null; then
        echo -e "${GREEN}✅ Usando bucket existente${NC}"
    else
        echo -e "${RED}❌ El bucket '$BUCKET_NAME' pertenece a otra cuenta${NC}"
        echo -e "${RED}Los nombres de bucket son únicos globalmente${NC}"
        suggest_bucket_name $BUCKET_NAME
        exit 1
    fi
else
    # Intentar crear el bucket
    if aws s3 mb s3://$BUCKET_NAME --region $REGION 2>/dev/null; then
        echo -e "${GREEN}✅ Bucket creado exitosamente${NC}"
    else
        echo -e "${RED}❌ No se pudo crear el bucket '$BUCKET_NAME'${NC}"
        echo -e "${RED}Posibles causas:${NC}"
        echo -e "${RED}  • El nombre ya existe en otra cuenta${NC}"
        echo -e "${RED}  • Nombre inválido (solo minúsculas, números, guiones)${NC}"
        suggest_bucket_name $BUCKET_NAME
        exit 1
    fi
fi

# PASO 3: Configurar acceso público
show_step "3" "Configurando acceso público"

aws s3api delete-public-access-block --bucket $BUCKET_NAME 2>/dev/null || true
validate_step "Remover bloqueo público"

# PASO 4: Configurar website hosting
show_step "4" "Configurando website hosting"

aws s3 website s3://$BUCKET_NAME \
    --index-document index.html \
    --error-document error.html
validate_step "Configurar website hosting"

# PASO 5: Crear y aplicar política
show_step "5" "Configurando política de bucket"

cat > /tmp/bucket-policy-$BUCKET_NAME.json << EOF
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
    --policy file:///tmp/bucket-policy-$BUCKET_NAME.json
validate_step "Aplicar política de bucket"

# PASO 6: Subir archivos
show_step "6" "Subiendo archivos del sitio"

aws s3 sync $SITE_PATH s3://$BUCKET_NAME/ \
    --delete
validate_step "Subir archivos"

# PASO 7: Configurar tipos MIME
show_step "7" "Configurando tipos de archivo"

# HTML
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --metadata-directive REPLACE \
    --content-type "text/html" \
    --exclude "*" \
    --include "*.html" > /dev/null 2>&1

# CSS
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --metadata-directive REPLACE \
    --content-type "text/css" \
    --exclude "*" \
    --include "*.css" > /dev/null 2>&1

# JS
aws s3 cp s3://$BUCKET_NAME/ s3://$BUCKET_NAME/ \
    --recursive \
    --metadata-directive REPLACE \
    --content-type "application/javascript" \
    --exclude "*" \
    --include "*.js" > /dev/null 2>&1

validate_step "Configurar tipos MIME"

# PASO 8: Verificar deployment
show_step "8" "Verificando deployment"

WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

# Verificar que el bucket tenga archivos
FILE_COUNT=$(aws s3 ls s3://$BUCKET_NAME --recursive | wc -l)
if [ $FILE_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ $FILE_COUNT archivos subidos correctamente${NC}"
else
    echo -e "${RED}❌ No se encontraron archivos en el bucket${NC}"
    exit 1
fi

# Limpiar archivos temporales
rm -f /tmp/bucket-policy-$BUCKET_NAME.json

# RESULTADO FINAL
echo ""
echo -e "${GREEN}🎉 ¡DEPLOY COMPLETADO EXITOSAMENTE!${NC}"
echo ""
echo -e "${GREEN}🌐 URL de tu sitio: $WEBSITE_URL${NC}"
echo ""
echo -e "${YELLOW}⏰ Espera 2-3 minutos para que esté disponible${NC}"
echo ""
echo -e "${BLUE}📊 Resumen:${NC}"
echo -e "${BLUE}   • Bucket creado: $BUCKET_NAME${NC}"
echo -e "${BLUE}   • Archivos subidos: $FILE_COUNT${NC}"
echo -e "${BLUE}   • Región: $REGION${NC}"
echo ""
echo -e "${GREEN}🚀 ¡Tu sitio web está en la nube!${NC}"

# Verificar si responde (opcional)
echo -e "${YELLOW}🔍 Verificando disponibilidad...${NC}"
sleep 3

if curl -s --head --max-time 10 $WEBSITE_URL | head -n 1 | grep -q "200 OK"; then
    echo -e "${GREEN}✅ ¡El sitio ya está respondiendo!${NC}"
else
    echo -e "${YELLOW}⏳ El sitio aún se está propagando, prueba en unos minutos${NC}"
fi
