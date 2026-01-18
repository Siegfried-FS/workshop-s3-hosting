#!/bin/bash

# Script Rápido para Setup GitHub Actions
# Uso: ./setup-github.sh nombre-bucket

set -e

BUCKET_NAME=$1
REPO_NAME="mi-sitio-web"

if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Uso: $0 <nombre-bucket>"
    echo "Ejemplo: $0 mi-sitio-github-2026"
    exit 1
fi

echo "🚀 Configurando GitHub Actions para $BUCKET_NAME"

# Crear estructura de proyecto
mkdir -p $REPO_NAME/{.github/workflows,src}

# Copiar sitio de ejemplo
cp -r ../primer-sitio/* $REPO_NAME/src/

# Crear workflow de GitHub Actions
cat > $REPO_NAME/.github/workflows/deploy.yml << 'EOF'
name: Deploy to S3

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_REGION }}
    
    - name: Deploy to S3
      run: |
        aws s3 sync ./src s3://${{ secrets.S3_BUCKET }} --delete --acl public-read
        echo "🌐 Sitio desplegado: http://${{ secrets.S3_BUCKET }}.s3-website-${{ secrets.AWS_REGION }}.amazonaws.com"
EOF

# Crear README
cat > $REPO_NAME/README.md << EOF
# Mi Sitio Web

Sitio desplegado automáticamente en S3 con GitHub Actions.

## URL del sitio:
http://$BUCKET_NAME.s3-website-us-east-1.amazonaws.com

## Configuración:
1. Configura estos secrets en GitHub:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY  
   - AWS_REGION: us-east-1
   - S3_BUCKET: $BUCKET_NAME

2. Haz push a main y se despliega automáticamente
EOF

echo "✅ Proyecto creado en: $REPO_NAME/"
echo "📁 Estructura:"
echo "   ├── .github/workflows/deploy.yml"
echo "   ├── src/index.html"
echo "   ├── src/error.html"
echo "   └── README.md"
echo ""
echo "🔧 Próximos pasos:"
echo "1. cd $REPO_NAME"
echo "2. git init && git add . && git commit -m 'Initial commit'"
echo "3. Crear repo en GitHub y hacer push"
echo "4. Configurar secrets en GitHub"
