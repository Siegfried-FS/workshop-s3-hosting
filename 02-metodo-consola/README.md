# Método 1: Subir Sitio via Consola Web AWS

## Paso 1: Crear el Bucket S3

1. Ve a la consola de AWS S3
2. Haz clic en "Create bucket"
3. **Bucket name**: `mi-sitio-estatico-2026` (debe ser único globalmente)
4. **Region**: Selecciona la más cercana a tus usuarios
5. **Block Public Access**: DESMARCAR todas las opciones
6. Haz clic en "Create bucket"


## Paso 2: Subir Archivos

1. Entra al bucket creado
2. Haz clic en "Upload"
3. Arrastra tus archivos HTML, CSS, JS
4. **Importante**: Tu archivo principal debe llamarse `index.html`
5. Haz clic en "Upload"


## Paso 3: Configurar Hosting Estático

1. Ve a la pestaña "Properties"
2. Busca "Static website hosting"
3. Haz clic en "Edit"
4. Selecciona "Enable"
5. **Index document**: `index.html`
6. **Error document**: `error.html` (opcional pero recomendado)
7. Guarda los cambios


## Paso 4: Configurar Permisos Públicos

1. Ve a la pestaña "Permissions"
2. Busca "Bucket policy"
3. Haz clic en "Edit"
4. Pega esta política (reemplaza `TU-BUCKET-NAME` por el nombre de tu bucket):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::TU-BUCKET-NAME/*"
        }
    ]
}
```

### 🤔 ¿Qué significa esto?
Esta política le dice a AWS: **"Permite que cualquier persona en internet pueda VER los archivos de mi bucket"**

**Explicación línea por línea:**
- `"Version": "2012-10-17"` → Versión estándar de AWS (siempre usa esta, aunque parezca antigua)
- `"Effect": "Allow"` → **PERMITIR** esta acción
- `"Principal": "*"` → A **CUALQUIER PERSONA** (el * significa "todos")
- `"Action": "s3:GetObject"` → La acción de **LEER/DESCARGAR** archivos
- `"Resource": "arn:aws:s3:::TU-BUCKET-NAME/*"` → En **TODOS LOS ARCHIVOS** de tu bucket

**En palabras simples:** "Deja que cualquiera pueda ver mi sitio web"

⚠️ **Importante:** Solo permite VER archivos, no modificarlos o borrarlos.

## Paso 5: Acceder a tu Sitio

1. Ve a "Properties" > "Static website hosting"
2. Copia la URL del endpoint
3. Ábrela en tu navegador

Tu URL será algo como:
```
http://mi-sitio-estatico-2026.s3-website-us-east-1.amazonaws.com
```

## Archivo error.html

Crea un archivo `error.html` para manejar páginas no encontradas:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Página No Encontrada</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #e74c3c; }
    </style>
</head>
<body>
    <h1>404 - Página No Encontrada</h1>
    <p>La página que buscas no existe.</p>
    <a href="/">Volver al inicio</a>
</body>
</html>
```

## Troubleshooting Común

### Error: "Access Denied"
- Verifica que la bucket policy esté configurada
- Asegúrate de que el bucket no tenga "Block Public Access"

### Error: "NoSuchKey"
- Verifica que tu archivo se llame exactamente `index.html`
- Revisa que esté en la raíz del bucket

### El sitio no carga
- Espera 5-10 minutos para propagación
- Verifica la URL del endpoint en Properties

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
Ahora que dominas la consola, aprende el [Método 2: AWS CLI](../03-metodo-cli/README.md) para automatizar el proceso.
