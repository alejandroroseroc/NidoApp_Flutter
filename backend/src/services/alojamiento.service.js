const alojamientoRepository = require('../repositories/alojamiento.repository');

const TIPOS_ESPACIO = ['HABITACION', 'APARTAESTUDIO', 'COMPARTIDO'];
const TIPOS_PRIVACIDAD = ['PRIVADO', 'COMPARTIDO'];
const ESTADOS = ['ACTIVO', 'INACTIVO'];

function parseServicios(value) {
  if (value === undefined || value === null || value === '') return [];
  if (Array.isArray(value)) {
    return value.map((item) => String(item).trim()).filter(Boolean);
  }
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      if (Array.isArray(parsed)) {
        return parsed.map((item) => String(item).trim()).filter(Boolean);
      }
    } catch (_) {
      // texto plano separado por comas
    }
    return value
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean);
  }
  return [];
}

function formatAlojamiento(alojamiento) {
  if (!alojamiento) return null;

  const { servicios, precio, creadoEn, ...rest } = alojamiento;

  return {
    ...rest,
    precioMensual: precio,
    precio,
    servicios: (servicios || []).map((servicio) => servicio.nombre),
    createdAt: creadoEn,
    updatedAt: creadoEn,
  };
}

function validatePayload(data, { isUpdate = false } = {}) {
  const errors = [];

  const isEmpty = (value) =>
    value === undefined || value === null || String(value).trim() === '';

  if (!isUpdate) {
    if (isEmpty(data.titulo)) errors.push('El titulo es obligatorio');
    if (isEmpty(data.descripcion)) errors.push('La descripcion es obligatoria');
    if (isEmpty(data.tipoEspacio)) errors.push('El tipo de espacio es obligatorio');
    if (isEmpty(data.tipoPrivacidad)) errors.push('El tipo de privacidad es obligatorio');
    if (isEmpty(data.tipoAcceso)) errors.push('El tipo de acceso es obligatorio');
    if (isEmpty(data.ubicacion)) errors.push('La ubicacion es obligatoria');
    if (isEmpty(data.precioMensual) && isEmpty(data.precio)) {
      errors.push('El precio mensual es obligatorio');
    }
  } else {
    if (data.titulo !== undefined && isEmpty(data.titulo)) {
      errors.push('El titulo es obligatorio');
    }
    if (data.descripcion !== undefined && isEmpty(data.descripcion)) {
      errors.push('La descripcion es obligatoria');
    }
    if (data.tipoEspacio !== undefined && isEmpty(data.tipoEspacio)) {
      errors.push('El tipo de espacio es obligatorio');
    }
    if (data.tipoPrivacidad !== undefined && isEmpty(data.tipoPrivacidad)) {
      errors.push('El tipo de privacidad es obligatorio');
    }
    if (data.tipoAcceso !== undefined && isEmpty(data.tipoAcceso)) {
      errors.push('El tipo de acceso es obligatorio');
    }
    if (data.ubicacion !== undefined && isEmpty(data.ubicacion)) {
      errors.push('La ubicacion es obligatoria');
    }
  }

  const precioValue =
    !isEmpty(data.precioMensual) ? data.precioMensual : data.precio;
  if (precioValue !== undefined && precioValue !== null && precioValue !== '') {
    const precio = Number(precioValue);
    if (Number.isNaN(precio) || precio <= 0) {
      errors.push('El precio debe ser mayor a 0');
    }
  }

  if (data.tipoEspacio && !TIPOS_ESPACIO.includes(data.tipoEspacio)) {
    errors.push('Tipo de espacio invalido');
  }

  if (data.tipoPrivacidad && !TIPOS_PRIVACIDAD.includes(data.tipoPrivacidad)) {
    errors.push('Tipo de privacidad invalido');
  }

  if (errors.length > 0) {
    const error = new Error(errors[0]);
    error.statusCode = 400;
    error.details = errors;
    throw error;
  }

  return {
    titulo: data.titulo?.trim(),
    descripcion: data.descripcion?.trim(),
    tipoEspacio: data.tipoEspacio,
    tipoPrivacidad: data.tipoPrivacidad,
    tipoAcceso: data.tipoAcceso?.trim(),
    reglas: data.reglas?.trim() || null,
    ubicacion: data.ubicacion?.trim(),
    precio:
      precioValue !== undefined && precioValue !== null && precioValue !== ''
        ? Number(precioValue)
        : undefined,
    servicios: data.servicios !== undefined ? parseServicios(data.servicios) : undefined,
    fotografias: data.fotografias,
  };
}

function assertOwner(alojamiento, usuarioId) {
  if (!alojamiento) {
    const error = new Error('Publicacion no encontrada');
    error.statusCode = 404;
    throw error;
  }

  if (alojamiento.anfitrionId !== usuarioId) {
    const error = new Error('No tienes permiso para modificar esta publicacion');
    error.statusCode = 403;
    throw error;
  }
}

const alojamientoService = {
  async create(anfitrionId, data) {
    const payload = validatePayload(data);
    const alojamiento = await alojamientoRepository.create({
      ...payload,
      anfitrionId,
    });
    return formatAlojamiento(alojamiento);
  },

  async listMine(anfitrionId) {
    const alojamientos = await alojamientoRepository.findByAnfitrion(anfitrionId);
    return alojamientos.map(formatAlojamiento);
  },

  async getById(id, usuarioId) {
    const alojamiento = await alojamientoRepository.findById(id);

    if (!alojamiento) {
      const error = new Error('Publicacion no encontrada');
      error.statusCode = 404;
      throw error;
    }

    const isOwner = alojamiento.anfitrionId === usuarioId;
    if (!isOwner && alojamiento.estado !== 'ACTIVO') {
      const error = new Error('Publicacion no encontrada');
      error.statusCode = 404;
      throw error;
    }

    return formatAlojamiento(alojamiento);
  },

  async update(id, usuarioId, data) {
    const existing = await alojamientoRepository.findById(id);
    assertOwner(existing, usuarioId);

    const payload = validatePayload(data, { isUpdate: true });

    const updateData = {
      titulo: payload.titulo ?? existing.titulo,
      descripcion: payload.descripcion ?? existing.descripcion,
      tipoEspacio: payload.tipoEspacio ?? existing.tipoEspacio,
      tipoPrivacidad: payload.tipoPrivacidad ?? existing.tipoPrivacidad,
      tipoAcceso: payload.tipoAcceso ?? existing.tipoAcceso,
      reglas: payload.reglas !== undefined ? payload.reglas : existing.reglas,
      ubicacion: payload.ubicacion ?? existing.ubicacion,
      precio: payload.precio ?? existing.precio,
      servicios: payload.servicios ?? existing.servicios.map((s) => s.nombre),
      fotografias:
        payload.fotografias !== undefined ? payload.fotografias : existing.fotografias,
    };

    const updated = await alojamientoRepository.update(id, updateData);
    return formatAlojamiento(updated);
  },

  async updateEstado(id, usuarioId, body) {
    const existing = await alojamientoRepository.findById(id);
    assertOwner(existing, usuarioId);

    let estado;
    if (body.estado) {
      estado = String(body.estado).toUpperCase();
    } else if (body.activo !== undefined) {
      estado = body.activo ? 'ACTIVO' : 'INACTIVO';
    } else {
      estado = existing.estado === 'ACTIVO' ? 'INACTIVO' : 'ACTIVO';
    }

    if (!ESTADOS.includes(estado)) {
      const error = new Error('Estado invalido');
      error.statusCode = 400;
      throw error;
    }

    const updated = await alojamientoRepository.updateEstado(id, estado);
    return formatAlojamiento(updated);
  },

  async remove(id, usuarioId) {
    const existing = await alojamientoRepository.findById(id);
    assertOwner(existing, usuarioId);

    try {
      await alojamientoRepository.delete(id);
    } catch (_) {
      const error = new Error(
        'No se pudo eliminar la publicacion. Puede tener reservas asociadas.',
      );
      error.statusCode = 400;
      throw error;
    }
  },
};

module.exports = {
  alojamientoService,
  formatAlojamiento,
  parseServicios,
};
