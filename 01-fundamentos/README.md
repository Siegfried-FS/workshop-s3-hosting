# Fundamentos de Sitios Estáticos

## ¿Qué es un Sitio Estático?

### Sitio Estático vs Dinámico

**Sitio Estático:**
- Archivos HTML, CSS, JS que no cambian
- No requiere servidor de aplicaciones
- Carga rápida y económica
- Ejemplos: portfolios, landing pages, documentación

**Sitio Dinámico:**
- Contenido generado en tiempo real
- Requiere base de datos y servidor
- Más complejo y costoso
- Ejemplos: e-commerce, redes sociales

## ¿Por qué S3 para Hosting Estático?

### Ventajas
- **Costo**: Desde $0.023 por GB/mes
- **Escalabilidad**: Maneja millones de requests
- **Disponibilidad**: 99.999999999% (11 9's)
- **Simplicidad**: No servidores que mantener
- **Integración**: Funciona con CloudFront, Route 53

### Casos de Uso Ideales
- Portfolios personales
- Landing pages de marketing
- Documentación técnica
- Sitios de eventos
- Prototipos y demos

## Conceptos Básicos de Seguridad

### URLs de S3
Cuando subes un sitio a S3, obtienes una URL como:
```
http://mi-bucket.s3-website-us-east-1.amazonaws.com
```

### ⚠️ Consideraciones de Seguridad
- **URL larga y sospechosa**: Los clientes pueden desconfiar
- **HTTP (no HTTPS)**: Sin certificado SSL por defecto
- **Dominio AWS**: No refleja tu marca

### Soluciones
1. **Dominio personalizado** con Route 53
2. **CloudFront** para HTTPS
3. **Certificado SSL** gratuito con ACM

## Próximos Pasos
Ahora que entiendes los fundamentos, vamos a ver los 3 métodos para subir tu sitio a S3.
