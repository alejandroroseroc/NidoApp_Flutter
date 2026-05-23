const reservaRepository = require('../repositories/reserva.repository');
const userRepository = require('../repositories/user.repository');

function formatReserva(reserva) {
  return {
    id: reserva.id,
    fechaIngreso: reserva.fechaIngreso,
    duracionMeses: reserva.duracionMeses,
    duracionDias: reserva.duracionDias,
    estado: reserva.estado,
    fechaSolicitud: reserva.fechaSolicitud,
    invitadoId: reserva.invitadoId,
    alojamientoId: reserva.alojamientoId,
    alojamiento: reserva.alojamiento,
    invitado: reserva.invitado,
  };
}

function validateSolicitud({ fechaIngreso, duracionMeses, duracionDias }) {
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

  const tieneDias = duracionDias !== undefined && duracionDias !== null && duracionDias !== '';
  const tieneMeses =
    duracionMeses !== undefined && duracionMeses !== null && duracionMeses !== '';

  if (tieneDias && tieneMeses) {
    const error = new Error('Indica la duracion en dias o meses, no ambas');
    error.statusCode = 400;
    throw error;
  }

  if (!tieneDias && !tieneMeses) {
    const error = new Error('La duracion es obligatoria');
    error.statusCode = 400;
    throw error;
  }

  const dias = tieneDias ? Number(duracionDias) : null;
  if (tieneDias && (!Number.isInteger(dias) || dias < 1 || dias > 730)) {
    const error = new Error('La duracion debe estar entre 1 y 730 dias');
    error.statusCode = 400;
    throw error;
  }

  const meses = tieneMeses ? Number(duracionMeses) : null;
  if (tieneMeses && (!Number.isInteger(meses) || meses < 1 || meses > 24)) {
    const error = new Error('La duracion debe estar entre 1 y 24 meses');
    error.statusCode = 400;
    throw error;
  }

  return { ingreso, dias, meses };
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

    const { ingreso, dias, meses } = validateSolicitud(data);
    const reserva = await reservaRepository.create({
      alojamientoId: data.alojamientoId,
      invitadoId: usuarioId,
      fechaIngreso: ingreso,
      duracionMeses: meses ?? 1,
      duracionDias: dias,
    });

    return formatReserva(reserva);
  },
};

module.exports = reservaService;
