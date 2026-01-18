# Método 2: Subir Sitio via AWS CLI

## 🚀 Opción Rápida: Script Automático

**Si quieres ver el resultado inmediato:**

```bash
./auto-deploy.sh tu-nombre-sitio-cli-2026 ../primer-sitio
```

**¡Eso es todo!** El script hace todo automáticamente.

---

## 📚 Opción Educativa: Paso a Paso

**Para aprender cada comando individualmente, sigue estos pasos:**

### Paso 0: Configurar AWS CLI

1. **Configurar tus credenciales**:
```bash
aws configure
# AWS Access Key ID: [Tu Access Key de AWS Academy/Cuenta]
# AWS Secret Access Key: [Tu Secret Key]
# Default region: us-east-1
# Default output format: json
```

2. **Verificar configuración**:
```bash
aws sts get-caller-identity
```

---

## 📚 Pasos del Despliegue

Si quieres entender qué hace cada paso, aquí está la explicación completa:

## Prerrequisitos

1. **Instalar AWS CLI**:
```bash
# Linux/Mac
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Descargar desde: https://awscli.amazonaws.com/AWSCLIV2.msi
```

2. **Configurar credenciales**:
```bash
aws configure
# AWS Access Key ID: [Tu Access Key]
# AWS Secret Access Key: [Tu Secret Key]
# Default region: us-east-1
# Default output format: json
```

### Paso 1: Crear Bucket

```bash
# Crear bucket (usa un nombre único)
aws s3 mb s3://tu-nombre-sitio-cli-2026 --region us-east-1

# Verificar que se creó
aws s3 ls
```

> **💡 Importante**: Cambia `tu-nombre-sitio-cli-2026` por un nombre único. Los buckets de S3 deben tener nombres únicos globalmente.

### Paso 2: Subir Archivos

```bash
# Subir toda la carpeta de tu sitio
aws s3 sync ../primer-sitio/ s3://tu-nombre-sitio-cli-2026/ --delete
```

> **💡 Nota**: Reemplaza `tu-nombre-sitio-cli-2026` con el nombre que usaste en el Paso 1.

### Paso 3: Configurar Website Hosting

```bash
aws s3 website s3://tu-nombre-sitio-cli-2026 \
    --index-document index.html \
    --error-document error.html
```

### Paso 4: Remover Block Public Access

```bash
aws s3api delete-public-access-block \
    --bucket tu-nombre-sitio-cli-2026
```

### Paso 5: Configurar Política de Bucket

1. **Crear archivo `bucket-policy.json`**:

```bash
# Crear el archivo con el contenido de la política
cat > bucket-policy.json << 'EOF'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::tu-nombre-sitio-cli-2026/*"
        }
    ]
}
EOF
```

> **💡 Importante**: Cambia `tu-nombre-sitio-cli-2026` por tu nombre de bucket en el comando de arriba.

2. **Aplicar la política**:
```bash
aws s3api put-bucket-policy \
    --bucket tu-nombre-sitio-cli-2026 \
    --policy file://bucket-policy.json
```

### Paso 6: Obtener URL del Sitio

```bash
echo "🌐 Tu sitio está disponible en:"
echo "http://tu-nombre-sitio-cli-2026.s3-website-us-east-1.amazonaws.com"
```

## Comandos Útiles para Gestión

### Verificar tu configuración
```bash
# Ver qué cuenta estás usando
aws sts get-caller-identity

# Ver perfiles configurados
aws configure list-profiles

# Usar un perfil específico
aws s3 ls --profile mi-perfil
```

### Sincronización Inteligente
```bash
# Solo subir archivos modificados
aws s3 sync ../primer-sitio/ s3://tu-nombre-sitio-cli-2026/ \
    --delete \
    --size-only

# Con compresión gzip
aws s3 sync ../primer-sitio/ s3://tu-nombre-sitio-cli-2026/ \
    --content-encoding gzip
```

### Gestión de Cache
```bash
# Configurar cache headers
aws s3 cp ../primer-sitio/ s3://tu-nombre-sitio-cli-2026/ \
    --recursive \
    --cache-control "max-age=86400" \
    --metadata-directive REPLACE
```

### Monitoreo
```bash
# Ver contenido del bucket
aws s3 ls s3://tu-nombre-sitio-cli-2026/ --recursive

# Ver tamaño total del bucket
aws s3 ls s3://tu-nombre-sitio-cli-2026/ --recursive --human-readable --summarize
```

## Ventajas del CLI
- **Automatización**: Un comando hace todo
- **Velocidad**: Más rápido que la consola
- **Repetible**: Mismo resultado siempre
- **Profesional**: Así trabajan los developers

## 🎯 Para el Workshop
**Sigue los pasos 1-6 en orden** - cada comando está explicado para que entiendas qué hace.

## 🏆 Reto AWS Builder Center

**¡Ahora que dominas este método, participa en nuestro reto!**

**Deadline: 20 de Enero 2026**

Practica el **hosting en AWS S3** usando este método. **No importa tu nivel de experiencia**:

- **Usa los ejemplos** incluidos en el repositorio y personalízalos
- **Crea tu propio sitio** único si ya sabes HTML/CSS
- **Experimenta y sé curioso** - lo importante es que practiques el hosting

**Requisitos:**
- Sitio desplegado en S3 usando este método
- Contenido original y creativo (puede ser basado en ejemplos)
- URL funcional
- Compartir en AWS Builder Center

*"La curiosidad es el combustible del aprendizaje, y la creatividad es donde ese aprendizaje cobra vida."*

## Próximo Paso
En el siguiente método veremos cómo automatizar completamente este proceso con GitHub Actions.
