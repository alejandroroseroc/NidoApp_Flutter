const alojamientoRepository = require('../repositories/alojamiento.repository');
const resenaRepository = require('../repositories/resena.repository');

function formatResena(resena) {
  return {
    id: resena.id,
    calificacion: resena.calificacion,
    comentario: resena.comentario,
    fecha: resena.fecha,
    autorId: resena.autorId,
    alojamientoId: resena.alojamientoId,
    autor: resena.autor,
  };
}

function buildSummary(resenas) {
  if (resenas.length === 0) return { promedio: 0, total: 0 };

  const totalPuntos = resenas.reduce(
    (sum, resena) => sum + resena.calificacion,
    0,
  );
  return {
    promedio: Number((totalPuntos / resenas.length).toFixed(1)),
    total: resenas.length,
  };
}

function validatePayload(data) {
  const calificacion = Number(data.calificacion);
  if (!Number.isInteger(calificacion) || calificacion < 1 || calificacion > 5) {
    const error = new Error('La calificacion debe estar entre 1 y 5');
    error.statusCode = 400;
    throw error;
  }

  const comentario = data.comentario?.trim() || null;
  if (comentario && comentario.length > 500) {
    const error = new Error('El comentario debe tener maximo 500 caracteres');
    error.statusCode = 400;
    throw error;
  }

  return { calificacion, comentario };
}

const resenaService = {
  async listByAlojamiento(alojamientoId) {
    const resenas = await resenaRepository.findByAlojamientoId(alojamientoId);
    return {
      resumen: buildSummary(resenas),
      resenas: resenas.map(formatResena),
    };
  },

  async createForAlojamiento(usuarioId, alojamientoId, data) {
    const alojamiento = await alojamientoRepository.findById(alojamientoId);
    if (!alojamiento || alojamiento.estado !== 'ACTIVO') {
      const error = new Error('Alojamiento no disponible');
      error.statusCode = 404;
      throw error;
    }

    if (alojamiento.anfitrionId === usuarioId) {
      const error = new Error('No puedes reseñar tu propio alojamiento');
      error.statusCode = 400;
      throw error;
    }

    const reserva = await resenaRepository.findAcceptedReservation(
      usuarioId,
      alojamientoId,
    );
    if (!reserva) {
      const error = new Error('Solo puedes reseñar alojamientos con estadia aceptada');
      error.statusCode = 403;
      throw error;
    }

    const existing = await resenaRepository.findExisting(usuarioId, alojamientoId);
    if (existing) {
      const error = new Error('Ya dejaste una reseña para este alojamiento');
      error.statusCode = 409;
      throw error;
    }

    const payload = validatePayload(data);
    const resena = await resenaRepository.create({
      ...payload,
      autorId: usuarioId,
      alojamientoId,
    });
    return formatResena(resena);
  },
};

module.exports = resenaService;
