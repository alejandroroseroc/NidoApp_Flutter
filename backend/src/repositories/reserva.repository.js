const prisma = require('../config/prisma');

const reservaInclude = {
  alojamiento: true,
  invitado: {
    select: {
      id: true,
      nombre: true,
      correo: true,
      telefono: true,
      fotoPerfil: true,
      descripcion: true,
      modoActivo: true,
    },
  },
};

const reservaRepository = {
  async create(data) {
    return prisma.reserva.create({
      data: {
        fechaIngreso: data.fechaIngreso,
        duracionMeses: data.duracionMeses,
        duracionDias: data.duracionDias,
        invitadoId: data.invitadoId,
        alojamientoId: data.alojamientoId,
      },
      include: reservaInclude,
    });
  },

  async findAlojamientoById(id) {
    return prisma.alojamiento.findUnique({
      where: { id },
    });
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
};

module.exports = reservaRepository;
