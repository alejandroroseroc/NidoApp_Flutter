# Guía de despliegue NidoApp en Railway

## Prerequisitos

- Cuenta en [railway.app](https://railway.app) (el plan Starter es gratuito)
- Repositorio en GitHub con el código del proyecto
- Git instalado en tu computador

---

## Pasos

### 1. Subir el código a GitHub

Asegúrate de que tu repositorio tenga los últimos cambios:

```bash
git add .
git commit -m "HU-18: preparar proyecto para Railway"
git push origin main
```

> **Importante:** el archivo `.env` **no debe estar** en el repositorio
> (está en `.gitignore`). Las variables de entorno se configuran directamente en Railway.

---

### 2. Crear proyecto en Railway

1. Ir a [railway.app](https://railway.app) e iniciar sesión con GitHub.
2. Clic en **"New Project"**.
3. Seleccionar **"Deploy from GitHub repo"**.
4. Seleccionar el repositorio `NidoApp_Flutter` (o el nombre de tu repo).
5. Railway detecta automáticamente que es Node.js y muestra un preview del deploy.

---

### 3. Agregar base de datos PostgreSQL

1. En el proyecto de Railway, clic en **"+ New"**.
2. Seleccionar **"Database"** → **"PostgreSQL"**.
3. Railway crea la base de datos automáticamente.
4. Clic en la base de datos → pestaña **"Variables"** → copiar el valor de `DATABASE_URL`.

---

### 4. Configurar variables de entorno del backend

En el **servicio del backend** ir a **"Variables"** y agregar:

| Variable       | Valor                                                   |
|----------------|---------------------------------------------------------|
| `DATABASE_URL` | (copiar de la BD de Railway, paso anterior)             |
| `JWT_SECRET`   | String aleatorio largo, mínimo 32 caracteres. Ejemplo: `nidoapp_prod_2026_secreto_muy_largo_y_seguro_xyz` |
| `NODE_ENV`     | `production`                                            |
| `EMAIL_USER`   | Tu correo de Gmail (para notificaciones de reserva)     |
| `EMAIL_PASS`   | Contraseña de aplicación de Gmail (no tu contraseña normal) |

> **Nota:** `PORT` **no lo agregues** — Railway lo asigna automáticamente.

---

### 5. Configurar el directorio raíz (Root Directory)

1. En el servicio del backend ir a **"Settings"**.
2. Buscar la sección **"Root Directory"** y escribir: `backend`
3. Esto le indica a Railway que el código del servidor está dentro de la carpeta `backend/`.

---

### 6. Verificar el deploy

Railway ejecuta automáticamente al desplegar:
```
npx prisma migrate deploy && node server.js
```

1. Ir a la pestaña **"Deployments"** para ver los logs en tiempo real.
2. Cuando aparezca `"HTTP: http://localhost:PORT/health"` el deploy fue exitoso.
3. Railway genera una URL pública con formato:
   ```
   https://algo-production.up.railway.app
   ```
4. Copiar esa URL — la necesitarás en el siguiente paso.

---

### 7. Probar el backend desplegado

Abrir en el navegador:

```
https://TU-URL.up.railway.app/health
```

Debe responder:

```json
{ "status": "OK", "app": "NidoApp API", "version": "1.0.0" }
```

Si responde correctamente, ¡el backend está en producción! 🎉

---

### 8. Actualizar el frontend con la URL de producción

1. Abrir `frontend/lib/core/constants/api_constants.dart`.
2. Cambiar `kBaseUrlProd` por la URL real de Railway:

   ```dart
   const String kBaseUrlProd = 'https://TU-URL-REAL.up.railway.app';
   ```

3. Cambiar `kBaseUrl` para que apunte a producción:

   ```dart
   const String kBaseUrl = kBaseUrlProd;
   ```

4. Guardar y generar el APK:

   ```bash
   flutter build apk --release
   ```

5. El APK queda en:

   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

---

## Troubleshooting

| Problema                        | Solución                                                                    |
|---------------------------------|-----------------------------------------------------------------------------|
| Falla la migración de Prisma    | Verificar que `DATABASE_URL` es correcta en las variables de entorno        |
| Error "Cannot find module"      | Verificar que `Root Directory` está configurado como `backend` en Settings  |
| Error 502 Bad Gateway           | Revisar logs en Railway → Deployments para ver el error real                |
| Prisma no encuentra el schema   | Verificar que `backend/prisma/schema.prisma` existe en el repositorio       |
| Email no llega al invitado      | Verificar `EMAIL_USER` y `EMAIL_PASS` — usar contraseña de app de Gmail, no la normal |
| CORS bloqueado en la app        | Verificar que `NODE_ENV=production` en Railway — activa CORS abierto (`*`)  |

---

## Generar contraseña de aplicación de Gmail

Para que NidoApp pueda enviar correos de notificación de reserva:

1. Ir a [myaccount.google.com/security](https://myaccount.google.com/security)
2. Activar **"Verificación en dos pasos"** si no está activa
3. Buscar **"Contraseñas de aplicación"**
4. Crear una contraseña para "Correo" → copiar las 16 letras generadas
5. Pegar esas 16 letras como valor de `EMAIL_PASS` en Railway

---

## Resumen de archivos de configuración Railway

| Archivo                    | Propósito                                          |
|----------------------------|----------------------------------------------------|
| `backend/railway.json`     | Comando de inicio y política de reinicios          |
| `backend/Procfile`         | Proceso web para Railway                           |
| `backend/.railwayignore`   | Archivos que Railway no debe subir                 |
| `backend/package.json`     | Script `build` (genera Prisma Client) y engines    |
