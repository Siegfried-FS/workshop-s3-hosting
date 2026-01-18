# Método 3: Deployment Automático con GitHub Actions

## 🚀 Opción Rápida: Script Automático

**Si quieres ver el resultado inmediato:**

```bash
./setup-github.sh mi-sitio-github-2026
cd mi-sitio-web
git init
git add .
git commit -m "Initial commit"
# Crear repo en GitHub y hacer push
# Configurar secrets en GitHub
```

**¡Eso es todo!** El workflow hace todo automáticamente.

---

## 📚 Opción Educativa: Paso a Paso

### Concepto: CI/CD para Sitios Estáticos

**Flujo automático:**
1. Haces push a GitHub → 2. GitHub Actions se ejecuta → 3. Tu sitio se actualiza en S3

## Paso 1: Crear Proyecto Local

```bash
# Generar estructura del proyecto
./setup-github.sh mi-sitio-github-2026

# Estructura creada:
mi-sitio-web/
├── .github/workflows/deploy.yml  # ← Workflow automático
├── src/index.html               # ← Tu sitio
├── src/error.html
└── README.md
```

## Paso 2: Subir a GitHub

```bash
cd mi-sitio-web
git init
git add .
git commit -m "Initial commit"

# Crear repo en GitHub: https://github.com/new
# Nombre: mi-sitio-github-2026

git remote add origin https://github.com/TU-USUARIO/mi-sitio-github-2026.git
git branch -M main
git push -u origin main
```

## Paso 3: Configurar Secrets en GitHub

**Ve a:** `Settings > Secrets and variables > Actions`

**Agrega estos 4 secrets:**

| Name | Value |
|------|-------|
| `AWS_ACCESS_KEY_ID` | Tu access key de AWS |
| `AWS_SECRET_ACCESS_KEY` | Tu secret key de AWS |
| `AWS_REGION` | `us-east-1` |
| `S3_BUCKET` | `mi-sitio-github-2026` |

> **💡 Importante**: NO pongas comillas en los valores

## Paso 4: ¡Automático!

Una vez configurados los secrets:

1. **El workflow se ejecuta automáticamente** cada vez que hagas push
2. **Crea el bucket S3** si no existe
3. **Configura website hosting** automáticamente
4. **Sube tus archivos** desde `src/`
5. **Tu sitio queda disponible** en: `http://mi-sitio-github-2026.s3-website-us-east-1.amazonaws.com`

## Troubleshooting: Errores Comunes

### ❌ Error: "The specified bucket does not exist"
**Solución:** El workflow necesita crear el bucket primero.

### ❌ Error: "AccessControlListNotSupported"
**Solución:** Usar políticas de bucket en lugar de ACLs (ya corregido en el workflow).

### ❌ Error: "Access Denied"
**Solución:** Verificar que las credenciales AWS tengan permisos S3.

## Workflow Explicado

El archivo `.github/workflows/deploy.yml` hace esto:

```yaml
# 1. Se ejecuta en cada push a main
on:
  push:
    branches: [ main ]

# 2. Configura credenciales AWS
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4

# 3. Crea bucket y configura todo
- name: Create S3 bucket and deploy
  run: |
    # Crear bucket
    aws s3 mb s3://mi-sitio-github-2026 --region us-east-1 || true
    
    # Configurar acceso público
    aws s3api delete-public-access-block --bucket mi-sitio-github-2026
    
    # Configurar website hosting
    aws s3 website s3://mi-sitio-github-2026 --index-document index.html
    
    # Aplicar política pública
    aws s3api put-bucket-policy --bucket mi-sitio-github-2026 --policy '{...}'
    
    # Subir archivos
    aws s3 sync ./src s3://mi-sitio-github-2026 --delete
```

## Gestión del Sitio

### Actualizar contenido:
```bash
# Edita archivos en src/
nano src/index.html

# Commit y push
git add .
git commit -m "Update content"
git push

# ¡El sitio se actualiza automáticamente!
```

### Ver deployment:
- Ve a: `https://github.com/TU-USUARIO/mi-sitio-github-2026/actions`
- Click en el último workflow para ver logs

### Verificar en AWS:
```bash
# Ver buckets
aws s3 ls

# Ver archivos del sitio
aws s3 ls s3://mi-sitio-github-2026/ --recursive
```

## Ventajas vs CLI

| Aspecto | CLI | GitHub Actions |
|---------|-----|----------------|
| **Setup inicial** | Rápido | Requiere configuración |
| **Actualizaciones** | Manual cada vez | Automático con push |
| **Colaboración** | Individual | Todo el equipo |
| **Historial** | No | Sí, cada deployment |
| **Rollback** | Manual | Fácil (revert commit) |

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

## ¡Felicidades!

Has completado los 3 métodos para hosting en AWS S3. Ahora tienes las herramientas para crear y desplegar sitios web profesionales en la nube.
