# NidoApp — Documentación de la API REST

## Información general

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Base URL dev     | `http://localhost:3000`                  |
| Base URL prod    | `https://TU-APP.up.railway.app`          |
| Autenticación    | Bearer Token (JWT)                       |
| Formato          | JSON (`Content-Type: application/json`)  |
| Versión          | 1.0.0                                    |

## Autenticación

Todos los endpoints protegidos requieren el header:

```
Authorization: Bearer <token>
```

El token se obtiene al registrarse (`/api/auth/register`) o al iniciar sesión (`/api/auth/login`).
Expira en **30 días**.

---

## Endpoints

### Auth — `/api/auth`

#### POST /api/auth/register
Registra un nuevo usuario y retorna token JWT.

**Body:**
```json
{
  "nombre": "Diego Rosero",
  "correo": "diego@ejemplo.com",
  "contrasena": "ClaveSegura123!",
  "telefono": "3001234567"
}
```

**Respuesta exitosa (201):**
```json
{
  "message": "Usuario registrado exitosamente",
  "data": {
    "token": "eyJhbGci...",
    "usuario": {
      "id": "uuid",
      "nombre": "Diego Rosero",
      "correo": "diego@ejemplo.com",
      "telefono": "3001234567",
      "modoActivo": "INVITADO",
      "fechaRegistro": "2026-05-24T00:00:00.000Z"
    }
  }
}
```

**Errores posibles:**
- `400` — Datos de entrada inválidos (correo mal formado, contraseña < 8 caracteres)
- `409` — El correo ya está registrado

---

#### POST /api/auth/login
Inicia sesión y retorna token JWT.

**Body:**
```json
{
  "correo": "diego@ejemplo.com",
  "contrasena": "ClaveSegura123!"
}
```

**Respuesta exitosa (200):**
```json
{
  "message": "Inicio de sesion exitoso",
  "data": {
    "token": "eyJhbGci...",
    "usuario": { "id": "uuid", "nombre": "Diego Rosero", "modoActivo": "INVITADO" }
  }
}
```

**Errores posibles:**
- `401` — Credenciales incorrectas
- `400` — Campos requeridos vacíos

---

#### POST /api/auth/forgot-password
Envía código de recuperación al correo (respuesta igual si el correo no existe, por seguridad).

**Body:**
```json
{ "correo": "diego@ejemplo.com" }
```

**Respuesta exitosa (200):**
```json
{ "message": "Si el correo existe, recibiras un codigo en tu bandeja." }
```

---

#### POST /api/auth/reset-password
Restablece la contraseña usando el código enviado por correo.

**Body:**
```json
{
  "correo": "diego@ejemplo.com",
  "codigo": "123456",
  "nuevaContrasena": "NuevaClave123!"
}
```

**Respuesta exitosa (200):**
```json
{ "message": "Contrasena actualizada correctamente" }
```

**Errores posibles:**
- `400` — Código inválido, incorrecto o expirado

---

#### PATCH /api/auth/mode 🔒
Cambia el modo activo del usuario autenticado (INVITADO ↔ ANFITRION).

**Body:**
```json
{ "modoActivo": "ANFITRION" }
```

**Respuesta exitosa (200):**
```json
{
  "message": "Modo activo actualizado correctamente",
  "data": { "usuario": { "id": "uuid", "modoActivo": "ANFITRION" } }
}
```

**Errores posibles:**
- `401` — Token requerido o inválido
- `422` — Valor de modoActivo no es INVITADO ni ANFITRION

---

### Usuarios — `/api/users`

#### GET /api/users/me 🔒
Retorna el perfil del usuario autenticado.

**Respuesta exitosa (200):**
```json
{
  "data": {
    "id": "uuid",
    "nombre": "Diego Rosero",
    "correo": "diego@ejemplo.com",
    "telefono": "3001234567",
    "fotoPerfil": "/uploads/perfiles/foto.jpg",
    "descripcion": "Me gusta compartir espacios",
    "modoActivo": "INVITADO",
    "tieneMascotas": false,
    "esFumador": false,
    "nivelRuido": "Bajo"
  }
}
```

---

#### PUT /api/users/me 🔒
Actualiza el perfil del usuario autenticado.

**Body:**
```json
{
  "nombre": "Diego Alejandro",
  "telefono": "3009876543",
  "descripcion": "Actualizado"
}
```

**Respuesta exitosa (200):**
```json
{
  "message": "Perfil actualizado correctamente",
  "data": { "usuario": { ... } }
}
```

---

#### POST /api/users/me/photo 🔒
Sube foto de perfil. Enviar como `multipart/form-data` con campo `fotoPerfil`.

**Respuesta exitosa (200):**
```json
{
  "message": "Foto de perfil actualizada",
  "data": { "fotoPerfil": "/uploads/perfiles/uuid.jpg" }
}
```

---

#### GET /api/users/:id 🔒
Retorna el perfil público de un anfitrión por ID.

**Respuesta exitosa (200):**
```json
{
  "data": {
    "id": "uuid",
    "nombre": "Anfitrión",
    "fotoPerfil": "/uploads/perfiles/foto.jpg",
    "descripcion": "Descripción pública"
  }
}
```

---

### Alojamientos — `/api/alojamientos`

#### GET /api/alojamientos 🔒
Lista todos los alojamientos ACTIVOS con filtros opcionales y paginación.

**Query params opcionales:**
| Param         | Tipo   | Ejemplo           |
|---------------|--------|-------------------|
| page          | number | `?page=1`         |
| limit         | number | `?limit=20`       |
| tipoEspacio   | string | `?tipoEspacio=HABITACION` |
| precioMin     | number | `?precioMin=200000` |
| precioMax     | number | `?precioMax=800000` |
| ubicacion     | string | `?ubicacion=Pasto` |
| servicios     | string | `?servicios=WiFi,Cocina` |

**Tipos de espacio válidos:** `HABITACION`, `APARTAESTUDIO`, `COMPARTIDO`

**Respuesta exitosa (200):**
```json
{
  "data": {
    "alojamientos": [ { "id": "uuid", "titulo": "...", "precio": 500000, ... } ],
    "page": 1,
    "limit": 20,
    "filters": {}
  }
}
```

---

#### POST /api/alojamientos 🔒
Crea un nuevo alojamiento. Requiere modo ANFITRION.
Enviar como `multipart/form-data` si se incluyen fotos, o JSON si no.

**Body (JSON):**
```json
{
  "titulo": "Habitación cerca a la universidad",
  "descripcion": "Habitación acogedora con baño privado",
  "tipoEspacio": "HABITACION",
  "tipoPrivacidad": "PRIVADO",
  "tipoAcceso": "Llave física",
  "reglas": "No mascotas, silencio después de las 10pm",
  "precio": 550000,
  "ubicacion": "Pasto, Nariño",
  "fotografias": [],
  "servicios": [
    { "nombre": "WiFi", "descripcion": "Internet de alta velocidad" },
    { "nombre": "Cocina", "descripcion": "Uso compartido" }
  ]
}
```

**Tipos de privacidad válidos:** `PRIVADO`, `COMPARTIDO`

**Respuesta exitosa (201):**
```json
{
  "message": "Publicacion creada correctamente",
  "data": { "alojamiento": { "id": "uuid", ... } }
}
```

**Errores posibles:**
- `401` — Token requerido
- `403` — Usuario no está en modo ANFITRION

---

#### GET /api/alojamientos/mis-publicaciones 🔒
Lista los alojamientos del anfitrión autenticado (todos los estados).

**Respuesta exitosa (200):**
```json
{
  "data": { "alojamientos": [ { "id": "uuid", "estado": "ACTIVO", ... } ] }
}
```

---

#### GET /api/alojamientos/:id 🔒
Retorna el detalle de un alojamiento.

**Respuesta exitosa (200):**
```json
{
  "data": {
    "alojamiento": {
      "id": "uuid",
      "titulo": "Habitación cerca a la universidad",
      "precio": 550000,
      "ubicacion": "Pasto, Nariño",
      "servicios": [ { "nombre": "WiFi" } ],
      "anfitrion": { "id": "uuid", "nombre": "Anfitrión" }
    }
  }
}
```

**Errores posibles:**
- `404` — Alojamiento no encontrado o no disponible

---

#### PUT /api/alojamientos/:id 🔒
Actualiza un alojamiento. Solo el anfitrión propietario puede hacerlo.

**Respuesta exitosa (200):**
```json
{ "message": "Publicacion actualizada correctamente", "data": { "alojamiento": { ... } } }
```

---

#### PATCH /api/alojamientos/:id/estado 🔒
Cambia el estado del alojamiento (ACTIVO ↔ INACTIVO).

**Body:**
```json
{ "estado": "INACTIVO" }
```

**Respuesta exitosa (200):**
```json
{ "message": "Estado de publicacion actualizado correctamente", "data": { "alojamiento": { ... } } }
```

---

#### DELETE /api/alojamientos/:id 🔒
Elimina un alojamiento. Solo el anfitrión propietario puede hacerlo.

**Respuesta exitosa (200):**
```json
{ "message": "Publicacion eliminada correctamente" }
```

---

### Reservas — `/api/reservas`

#### POST /api/reservas 🔒
Crea una solicitud de reserva. Requiere modo INVITADO.

**Body:**
```json
{
  "alojamientoId": "uuid-del-alojamiento",
  "fechaIngreso": "2026-06-15T00:00:00.000Z",
  "duracionDias": 5
}
```

**Respuesta exitosa (201):**
```json
{
  "message": "Solicitud de reserva enviada correctamente",
  "data": {
    "reserva": {
      "id": "uuid",
      "estado": "PENDIENTE",
      "fechaIngreso": "2026-06-15T00:00:00.000Z",
      "duracionDias": 5
    }
  }
}
```

**Errores posibles:**
- `400` — Fecha inválida, duración fuera de rango, o reserva propia
- `403` — Usuario en modo ANFITRION
- `404` — Alojamiento no encontrado
- `409` — Ya existe una solicitud pendiente para ese alojamiento

---

#### GET /api/reservas/invitado 🔒
Lista las reservas del usuario autenticado como invitado.

**Respuesta exitosa (200):**
```json
{
  "data": {
    "reservas": [
      {
        "id": "uuid",
        "estado": "PENDIENTE",
        "fechaIngreso": "2026-06-15T00:00:00.000Z",
        "duracionDias": 5,
        "alojamiento": { "id": "uuid", "titulo": "...", "ubicacion": "...", "anfitrion": { "nombre": "...", "telefono": "..." } }
      }
    ]
  }
}
```

---

#### GET /api/reservas/host 🔒
Lista las solicitudes de reserva recibidas por el anfitrión autenticado.
Requiere modo ANFITRION.

**Respuesta exitosa (200):**
```json
{
  "data": {
    "reservas": [
      {
        "id": "uuid",
        "estado": "PENDIENTE",
        "invitado": { "id": "uuid", "nombre": "...", "correo": "..." },
        "alojamiento": { "id": "uuid", "titulo": "..." }
      }
    ]
  }
}
```

**Errores posibles:**
- `403` — Usuario no está en modo ANFITRION

---

#### PATCH /api/reservas/:id/status 🔒
Acepta o rechaza una reserva pendiente. Solo el anfitrión del alojamiento puede hacerlo.
Al aceptar o rechazar se envía un correo de notificación al invitado (HU-16).

**Body:**
```json
{ "estado": "ACEPTADA" }
```

**Valores válidos:** `ACEPTADA`, `RECHAZADA`

**Respuesta exitosa (200):**
```json
{
  "message": "Estado de la reserva actualizado",
  "data": { "reserva": { "id": "uuid", "estado": "ACEPTADA", ... } }
}
```

**Errores posibles:**
- `400` — Reserva no está en estado PENDIENTE
- `403` — El usuario no es el anfitrión del alojamiento
- `404` — Reserva no encontrada

---

### Reseñas — `/api/alojamientos/:id/resenas`

#### GET /api/alojamientos/:id/resenas 🔒
Lista las reseñas de un alojamiento con resumen de calificación.

**Respuesta exitosa (200):**
```json
{
  "data": {
    "resumen": { "promedio": 4.5, "total": 12 },
    "resenas": [
      {
        "id": "uuid",
        "calificacion": 5,
        "comentario": "Excelente lugar, muy limpio",
        "fecha": "2026-05-20T00:00:00.000Z",
        "autor": { "id": "uuid", "nombre": "Juan", "fotoPerfil": null }
      }
    ]
  }
}
```

---

#### POST /api/alojamientos/:id/resenas 🔒
Crea una reseña para un alojamiento.
Requisitos: haber tenido una reserva **aceptada** en ese alojamiento, y no haber reseñado antes.

**Body:**
```json
{
  "calificacion": 5,
  "comentario": "Excelente anfitrión, muy limpio"
}
```

**Respuesta exitosa (201):**
```json
{
  "message": "Reseña publicada correctamente",
  "data": { "resena": { "id": "uuid", "calificacion": 5, "comentario": "...", "fecha": "..." } }
}
```

**Errores posibles:**
- `400` — Calificación fuera de rango (debe ser 1-5) o comentario > 500 caracteres
- `400` — No puedes reseñar tu propio alojamiento
- `403` — No tienes una estadía aceptada en este alojamiento
- `404` — Alojamiento no disponible
- `409` — Ya dejaste una reseña para este alojamiento

---

## Códigos de estado HTTP usados en el proyecto

| Código | Significado                                              |
|--------|----------------------------------------------------------|
| 200    | Éxito                                                    |
| 201    | Recurso creado exitosamente                              |
| 401    | No autenticado (token ausente o inválido)                |
| 403    | Prohibido (autenticado pero sin permiso)                 |
| 404    | Recurso no encontrado                                    |
| 409    | Conflicto (recurso duplicado)                            |
| 400    | Error de validación (datos del body malformados o lógica de negocio) |
| 500    | Error interno del servidor                               |

## Estructura de error

Todos los errores retornan:
```json
{ "error": "Descripción del error" }
```

Los errores de validación (422) retornan:
```json
{
  "errors": [
    { "field": "correo", "message": "El correo no es valido" }
  ]
}
```

## Health check

```
GET /health
```

```json
{ "status": "OK", "app": "NidoApp API", "version": "1.0.0" }
```
