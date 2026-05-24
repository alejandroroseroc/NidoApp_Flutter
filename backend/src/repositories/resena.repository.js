const prisma = require('../config/prisma');

const autorSelect = {
  id: true,
  nombre: true,
  fotoPerfil: true,
};

const resenaRepository = {
  async findByAlojamientoId(alojamientoId) {
    return prisma.resena.findMany({
      where: { alojamientoId },
      include: { autor: { select: autorSelect } },
      orderBy: { fecha: 'desc' },
    });
  },

  async findExisting(autorId, alojamientoId) {
    return prisma.resena.findUnique({
      where: {
        autorId_alojamientoId: { autorId, alojamientoId },
      },
    });
  },

  async findAcceptedReservation(autorId, alojamientoId) {
    return prisma.reserva.findFirst({
      where: {
        invitadoId: autorId,
        alojamientoId,
        estado: 'ACEPTADA',
        fechaIngreso: { lte: new Date() },
      },
    });
  },

  async create(data) {
    return prisma.resena.create({
      data: {
        calificacion: data.calificacion,
        comentario: data.comentario,
        autorId: data.autorId,
        alojamientoId: data.alojamientoId,
      },
      include: { autor: { select: autorSelect } },
    });
  },
};

module.exports = resenaRepository;
