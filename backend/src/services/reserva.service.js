const reservaRepository = require('../repositories/reserva.repository');
const userRepository = require('../repositories/user.repository');

function formatReserva(reserva) {
  return {
    id: reserva.id,
    fechaIngreso: reserva.fechaIngreso,
    duracionDias: reserva.duracionDias,
    estado: reserva.estado,
    fechaSolicitud: reserva.fechaSolicitud,
    invitadoId: reserva.invitadoId,
    alojamientoId: reserva.alojamientoId,
    alojamiento: reserva.alojamiento,
    invitado: reserva.invitado,
  };
}

function formatGuestReserva(reserva) {
  return {
    id: reserva.id,
    estado: reserva.estado,
    fechaIngreso: reserva.fechaIngreso,
    duracionDias: reserva.duracionDias,
    fechaSolicitud: reserva.fechaSolicitud,
    alojamiento: {
      id: reserva.alojamiento.id,
      titulo: reserva.alojamiento.titulo,
      ubicacion: reserva.alojamiento.ubicacion,
      fotografias: reserva.alojamiento.fotografias,
      anfitrion: {
        nombre: reserva.alojamiento.anfitrion.nombre,
        telefono: reserva.alojamiento.anfitrion.telefono,
      },
    },
  };
}

function formatHostReserva(reserva) {
  return {
    id: reserva.id,
    estado: reserva.estado,
    fechaIngreso: reserva.fechaIngreso,
    duracionDias: reserva.duracionDias,
    fechaSolicitud: reserva.fechaSolicitud,
    invitado: reserva.invitado,
    alojamiento: {
      id: reserva.alojamiento.id,
      titulo: reserva.alojamiento.titulo,
      ubicacion: reserva.alojamiento.ubicacion,
      fotografias: reserva.alojamiento.fotografias,
    },
  };
}

const ESTADOS_ACTUALIZABLES = ['ACEPTADA', 'RECHAZADA'];

function validateSolicitud({ fechaIngreso, duracionDias }) {
  const ingreso = new Date(fechaIngreso);
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  if (!fechaIngreso || Number.isNaN(ingreso.getTime())) {
    const error = new Error('La fecha de ingreso no es valida');
    error.statusCode = 400;
    throw error;
  }

  if (ingreso < today) {
    const error = new Error('La fecha de ingreso no puede ser anterior a hoy');
    error.statusCode = 400;
    throw error;
  }

  const tieneDias =
    duracionDias !== undefined && duracionDias !== null && duracionDias !== '';

  if (!tieneDias) {
    const error = new Error('La duracion en dias es obligatoria');
    error.statusCode = 400;
    throw error;
  }

  const dias = Number(duracionDias);
  if (!Number.isInteger(dias) || dias < 1 || dias > 365) {
    const error = new Error('La duracion debe estar entre 1 y 365 dias');
    error.statusCode = 400;
    throw error;
  }

  return { ingreso, dias };
}

const reservaService = {
  async createSolicitud(usuarioId, data) {
    const usuario = await userRepository.findById(usuarioId);
    if (!usuario) {
      const error = new Error('Usuario no encontrado');
      error.statusCode = 404;
      throw error;
    }

    if (usuario.modoActivo !== 'INVITADO') {
      const error = new Error('Debes estar en modo invitado para solicitar una reserva');
      error.statusCode = 403;
      throw error;
    }

    const alojamiento = await reservaRepository.findAlojamientoById(data.alojamientoId);
    if (!alojamiento || alojamiento.estado !== 'ACTIVO') {
      const error = new Error('Alojamiento no disponible');
      error.statusCode = 404;
      throw error;
    }

    if (alojamiento.anfitrionId === usuarioId) {
      const error = new Error('No puedes solicitar una reserva de tu propio alojamiento');
      error.statusCode = 400;
      throw error;
    }

    const existing = await reservaRepository.findPendingByGuestAndAlojamiento(
      usuarioId,
      data.alojamientoId,
    );
    if (existing) {
      const error = new Error('Ya tienes una solicitud pendiente para este alojamiento');
      error.statusCode = 409;
      throw error;
    }

    const { ingreso, dias } = validateSolicitud(data);
    const reserva = await reservaRepository.create({
      alojamientoId: data.alojamientoId,
      invitadoId: usuarioId,
      fechaIngreso: ingreso,
      duracionDias: dias,
    });

    return formatReserva(reserva);
  },

  async getGuestReservations(guestId) {
    const usuario = await userRepository.findById(guestId);
    if (!usuario) {
      const error = new Error('Usuario no encontrado');
      error.statusCode = 404;
      throw error;
    }

    const reservas = await reservaRepository.findByGuestId(guestId);
    return reservas.map(formatGuestReserva);
  },

  async getHostReservations(hostId) {
    const usuario = await userRepository.findById(hostId);
    if (!usuario) {
      const error = new Error('Usuario no encontrado');
      error.statusCode = 404;
      throw error;
    }

    if (usuario.modoActivo !== 'ANFITRION') {
      const error = new Error('Debes estar en modo anfitrion para ver solicitudes de reserva');
      error.statusCode = 403;
      throw error;
    }

    const reservas = await reservaRepository.findByHostId(hostId);
    return reservas.map(formatHostReserva);
  },

  async updateReservationStatus(reservationId, newStatus, hostId) {
    if (!ESTADOS_ACTUALIZABLES.includes(newStatus)) {
      const error = new Error('El estado debe ser ACEPTADA o RECHAZADA');
      error.statusCode = 400;
      throw error;
    }

    const reserva = await reservaRepository.findById(reservationId);
    if (!reserva) {
      const error = new Error('Reserva no encontrada');
      error.statusCode = 404;
      throw error;
    }

    if (reserva.alojamiento.anfitrionId !== hostId) {
      const error = new Error('No tienes permiso para gestionar esta reserva');
      error.statusCode = 403;
      throw error;
    }

    if (reserva.estado !== 'PENDIENTE') {
      const error = new Error('Solo puedes gestionar reservas en estado pendiente');
      error.statusCode = 400;
      throw error;
    }

    const updated = await reservaRepository.updateStatus(reservationId, newStatus);
    return formatHostReserva(updated);
  },
};

module.exports = reservaService;
