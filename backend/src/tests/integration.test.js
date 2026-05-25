/**
 * Pruebas de integración de NidoApp — HU-18
 *
 * Requieren una base de datos PostgreSQL real configurada en DATABASE_URL.
 * Ejecutar con: npm test -- --testPathPattern=integration
 *
 * Para correr TODAS las pruebas (unitarias + integración): npm test
 */

require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

process.env.JWT_SECRET = process.env.JWT_SECRET || 'test_secret_integracion_nidoapp';
process.env.NODE_ENV = 'test';

const request = require('supertest');
const app = require('../../app');

// ─── Datos únicos por ejecución para no colisionar con datos existentes ───────
const ts = Date.now();
const ANFITRION = {
  nombre: 'Anfitrion Test',
  correo: `anfitrion_${ts}@test.com`,
  contrasena: 'ClaveSegura123!',
};
const INVITADO = {
  nombre: 'Invitado Test',
  correo: `invitado_${ts}@test.com`,
  contrasena: 'ClaveSegura123!',
};

// Tokens y IDs compartidos entre describes
let tokenAnfitrion;
let tokenInvitado;
let alojamientoId;
let reservaId;

// ─── Helpers ──────────────────────────────────────────────────────────────────

async function registrarYLogin(datos) {
  const res = await request(app)
    .post('/api/auth/register')
    .send(datos);
  return res.body.data?.token;
}

// ─── Setup global ─────────────────────────────────────────────────────────────

beforeAll(async () => {
  // Registrar anfitrión e invitado
  tokenAnfitrion = await registrarYLogin(ANFITRION);
  tokenInvitado  = await registrarYLogin(INVITADO);

  // Cambiar anfitrión a modo ANFITRION
  await request(app)
    .patch('/api/auth/mode')
    .set('Authorization', `Bearer ${tokenAnfitrion}`)
    .send({ modoActivo: 'ANFITRION' });

  // Crear alojamiento como anfitrión
  const resAlo = await request(app)
    .post('/api/alojamientos')
    .set('Authorization', `Bearer ${tokenAnfitrion}`)
    .send({
      titulo: 'Habitación de prueba integración',
      descripcion: 'Habitación cómoda para pruebas automatizadas',
      tipoEspacio: 'HABITACION',
      tipoPrivacidad: 'PRIVADO',
      tipoAcceso: 'Llave física',
      precio: 500000,
      ubicacion: 'Pasto, Nariño',
      fotografias: [],
      servicios: [],
    });
  alojamientoId = resAlo.body.data?.alojamiento?.id;

  // Crear reserva como invitado
  const fechaFutura = new Date();
  fechaFutura.setDate(fechaFutura.getDate() + 5);

  const resReserva = await request(app)
    .post('/api/reservas')
    .set('Authorization', `Bearer ${tokenInvitado}`)
    .send({
      alojamientoId,
      fechaIngreso: fechaFutura.toISOString(),
      duracionDias: 3,
    });
  reservaId = resReserva.body.data?.reserva?.id;
}, 30000);

// ─── Limpieza: eliminar datos de prueba al finalizar ─────────────────────────

afterAll(async () => {
  const { PrismaClient } = require('@prisma/client');
  const prisma = new PrismaClient();
  try {
    await prisma.resena.deleteMany({
      where: { autor: { correo: { contains: '@test.com' } } },
    });
    await prisma.reserva.deleteMany({
      where: { invitado: { correo: { contains: '@test.com' } } },
    });
    await prisma.alojamiento.deleteMany({
      where: { anfitrion: { correo: { contains: '@test.com' } } },
    });
    await prisma.usuario.deleteMany({
      where: { correo: { contains: '@test.com' } },
    });
  } finally {
    await prisma.$disconnect();
  }
}, 20000);

// ═══════════════════════════════════════════════════════════════════════════════
// AUTH
// ═══════════════════════════════════════════════════════════════════════════════

describe('Auth', () => {
  test('POST /api/auth/register — registro exitoso con datos válidos', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        nombre: 'Usuario Nuevo',
        correo: `nuevo_${ts}@test.com`,
        contrasena: 'ClaveSegura123!',
      });

    expect(res.status).toBe(201);
    expect(res.body.data).toHaveProperty('token');
    expect(res.body.data.usuario).not.toHaveProperty('contrasena');
  });

  test('POST /api/auth/register — error 409 con correo duplicado', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        nombre: ANFITRION.nombre,
        correo: ANFITRION.correo,
        contrasena: ANFITRION.contrasena,
      });

    expect(res.status).toBe(409);
  });

  test('POST /api/auth/register — error 400 con contraseña débil (menos de 8 caracteres)', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        nombre: 'Usuario Prueba',
        correo: `debil_${ts}@test.com`,
        contrasena: '123',
      });

    expect(res.status).toBe(400);
  });

  test('POST /api/auth/login — login exitoso retorna token', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ correo: INVITADO.correo, contrasena: INVITADO.contrasena });

    expect(res.status).toBe(200);
    expect(res.body.data).toHaveProperty('token');
    expect(res.body.data.usuario.correo).toBe(INVITADO.correo);
  });

  test('POST /api/auth/login — error 401 con credenciales incorrectas', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ correo: INVITADO.correo, contrasena: 'ContraseñaWrong99!' });

    expect(res.status).toBe(401);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// ALOJAMIENTOS
// ═══════════════════════════════════════════════════════════════════════════════

describe('Alojamientos', () => {
  test('GET /api/alojamientos — retorna lista de alojamientos', async () => {
    const res = await request(app)
      .get('/api/alojamientos')
      .set('Authorization', `Bearer ${tokenInvitado}`);

    expect(res.status).toBe(200);
    expect(res.body.data).toHaveProperty('alojamientos');
    expect(Array.isArray(res.body.data.alojamientos)).toBe(true);
  });

  test('GET /api/alojamientos/:id — retorna detalle de un alojamiento', async () => {
    const res = await request(app)
      .get(`/api/alojamientos/${alojamientoId}`)
      .set('Authorization', `Bearer ${tokenInvitado}`);

    expect(res.status).toBe(200);
    expect(res.body.data.alojamiento.id).toBe(alojamientoId);
  });

  test('POST /api/alojamientos — crea alojamiento con token válido de anfitrión', async () => {
    const fechaFutura = new Date();
    fechaFutura.setDate(fechaFutura.getDate() + 10);

    const res = await request(app)
      .post('/api/alojamientos')
      .set('Authorization', `Bearer ${tokenAnfitrion}`)
      .send({
        titulo: 'Alojamiento creado en test',
        descripcion: 'Creado durante prueba de integración',
        tipoEspacio: 'APARTAESTUDIO',
        tipoPrivacidad: 'PRIVADO',
        tipoAcceso: 'Código digital',
        precio: 800000,
        ubicacion: 'Bogotá, Colombia',
        fotografias: [],
        servicios: [],
      });

    expect(res.status).toBe(201);
    expect(res.body.data.alojamiento).toHaveProperty('id');
  });

  test('POST /api/alojamientos — error 401 sin token', async () => {
    const res = await request(app)
      .post('/api/alojamientos')
      .send({
        titulo: 'Sin token',
        descripcion: 'No debería crearse',
        tipoEspacio: 'HABITACION',
        tipoPrivacidad: 'PRIVADO',
        tipoAcceso: 'Llave',
        precio: 300000,
        ubicacion: 'Pasto',
        fotografias: [],
        servicios: [],
      });

    expect(res.status).toBe(401);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// RESERVAS
// ═══════════════════════════════════════════════════════════════════════════════

describe('Reservas', () => {
  test('POST /api/reservas — crea reserva con token válido de invitado', async () => {
    // Crear otro alojamiento para no colisionar con el de reservaId
    const resAlo = await request(app)
      .post('/api/alojamientos')
      .set('Authorization', `Bearer ${tokenAnfitrion}`)
      .send({
        titulo: 'Alojamiento para segunda reserva',
        descripcion: 'Para prueba de creación',
        tipoEspacio: 'COMPARTIDO',
        tipoPrivacidad: 'COMPARTIDO',
        tipoAcceso: 'Portero',
        precio: 350000,
        ubicacion: 'Medellín, Colombia',
        fotografias: [],
        servicios: [],
      });

    const nuevoAlojamientoId = resAlo.body.data?.alojamiento?.id;
    const fechaFutura = new Date();
    fechaFutura.setDate(fechaFutura.getDate() + 7);

    const res = await request(app)
      .post('/api/reservas')
      .set('Authorization', `Bearer ${tokenInvitado}`)
      .send({
        alojamientoId: nuevoAlojamientoId,
        fechaIngreso: fechaFutura.toISOString(),
        duracionDias: 2,
      });

    expect(res.status).toBe(201);
    expect(res.body.data.reserva).toHaveProperty('id');
    expect(res.body.data.reserva.estado).toBe('PENDIENTE');
  });

  test('GET /api/reservas/invitado — retorna reservas del invitado', async () => {
    const res = await request(app)
      .get('/api/reservas/invitado')
      .set('Authorization', `Bearer ${tokenInvitado}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data.reservas)).toBe(true);
    expect(res.body.data.reservas.length).toBeGreaterThan(0);
  });

  test('GET /api/reservas/host — retorna reservas del anfitrión', async () => {
    const res = await request(app)
      .get('/api/reservas/host')
      .set('Authorization', `Bearer ${tokenAnfitrion}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body.data.reservas)).toBe(true);
  });

  test('PATCH /api/reservas/:id/status — anfitrión acepta reserva pendiente', async () => {
    expect(reservaId).toBeDefined();

    const res = await request(app)
      .patch(`/api/reservas/${reservaId}/status`)
      .set('Authorization', `Bearer ${tokenAnfitrion}`)
      .send({ estado: 'ACEPTADA' });

    expect(res.status).toBe(200);
    expect(res.body.data.reserva.estado).toBe('ACEPTADA');
  });

  test('PATCH /api/reservas/:id/status — error 400 en reserva ya procesada', async () => {
    expect(reservaId).toBeDefined();

    // Intentar cambiar estado de una reserva que ya fue aceptada
    const res = await request(app)
      .patch(`/api/reservas/${reservaId}/status`)
      .set('Authorization', `Bearer ${tokenAnfitrion}`)
      .send({ estado: 'RECHAZADA' });

    expect(res.status).toBe(400);
  });
});

// ═══════════════════════════════════════════════════════════════════════════════
// SEGURIDAD
// ═══════════════════════════════════════════════════════════════════════════════

describe('Seguridad', () => {
  test('Endpoints protegidos retornan 401 sin token', async () => {
    const endpoints = [
      { method: 'get',   url: '/api/alojamientos' },
      { method: 'get',   url: '/api/reservas/invitado' },
      { method: 'get',   url: '/api/reservas/host' },
      { method: 'get',   url: '/api/users/me' },
    ];

    for (const ep of endpoints) {
      const res = await request(app)[ep.method](ep.url);
      expect(res.status).toBe(401);
    }
  });

  test('Contraseña almacenada como hash bcrypt en BD (no en texto plano)', async () => {
    const { PrismaClient } = require('@prisma/client');
    const prisma = new PrismaClient();

    try {
      const usuario = await prisma.usuario.findUnique({
        where: { correo: INVITADO.correo },
      });

      expect(usuario).not.toBeNull();
      expect(usuario.contrasena).not.toBe(INVITADO.contrasena);
      // Los hashes bcrypt empiezan con $2b$ o $2a$
      expect(usuario.contrasena).toMatch(/^\$2[ab]\$/);
    } finally {
      await prisma.$disconnect();
    }
  });

  test('Health check retorna 200 con estado OK', async () => {
    const res = await request(app).get('/health');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('OK');
    expect(res.body.app).toBe('NidoApp API');
  });
});
