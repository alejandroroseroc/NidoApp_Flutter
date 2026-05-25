const prisma = require('../config/prisma');

// Campos que se incluyen al consultar el invitado en contexto de host.
const invitadoSelect = {
  id: true,
  nombre: true,
  correo: true,
  telefono: true,
  fotoPerfil: true,
};

// Campos adicionales que se incluyen al crear la reserva.
const invitadoCreateSelect = {
  ...invitadoSelect,
  descripcion: true,
  modoActivo: true,
};

// Campos del alojamiento para respuestas de host (incluye anfitrionId para validar permisos).
const alojamientoHostSelect = {
  id: true,
  titulo: true,
  ubicacion: true,
  fotografias: true,
  anfitrionId: true,
};

// Campos del alojamiento para respuestas del invitado (incluye datos del anfitrión).
const alojamientoGuestSelect = {
  id: true,
  titulo: true,
  ubicacion: true,
  fotografias: true,
  anfitrion: {
    select: {
      nombre: true,
      telefono: true,
    },
  },
};

const reservaRepository = {
  async create(data) {
    return prisma.reserva.create({
      data: {
        fechaIngreso: data.fechaIngreso,
        duracionDias: data.duracionDias,
        precioNoche: data.precioNoche ?? null,
        precioTotal: data.precioTotal ?? null,
        invitadoId: data.invitadoId,
        alojamientoId: data.alojamientoId,
      },
      include: {
        invitado: { select: invitadoCreateSelect },
        alojamiento: true,
      },
    });
  },

  async findAlojamientoById(id) {
    return prisma.alojamiento.findUnique({ where: { id } });
  },

  async findPendingByGuestAndAlojamiento(invitadoId, alojamientoId) {
    return prisma.reserva.findFirst({
      where: {
        invitadoId,
        alojamientoId,
        estado: 'PENDIENTE',
      },
    });
  },

  async findByGuestId(guestId) {
    return prisma.reserva.findMany({
      where: { invitadoId: guestId },
      include: {
        alojamiento: {
          select: alojamientoGuestSelect,
        },
      },
      orderBy: { fechaSolicitud: 'desc' },
    });
  },

  async findByHostId(hostId) {
    return prisma.reserva.findMany({
      where: {
        alojamiento: {
          anfitrionId: hostId,
        },
      },
      include: {
        invitado: { select: invitadoSelect },
        alojamiento: {
          select: alojamientoHostSelect,
        },
      },
      orderBy: { fechaSolicitud: 'desc' },
    });
  },

  async findById(id) {
    return prisma.reserva.findUnique({
      where: { id },
      include: {
        invitado: { select: invitadoSelect },
        alojamiento: {
          select: alojamientoHostSelect,
        },
      },
    });
  },

  async updateStatus(id, status) {
    return prisma.reserva.update({
      where: { id },
      data: { estado: status },
      include: {
        invitado: { select: invitadoSelect },
        alojamiento: {
          select: alojamientoHostSelect,
        },
      },
    });
  },
};

module.exports = reservaRepository;
