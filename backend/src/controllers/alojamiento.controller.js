const { alojamientoService, parseServicios } = require('../services/alojamiento.service');

function mapUploadedPhotos(files = []) {
  return files.map((file) => `/uploads/alojamientos/${file.filename}`);
}

function buildBodyFromRequest(req) {
  const body = { ...req.body };

  if (req.files?.length) {
    const uploaded = mapUploadedPhotos(req.files);
    const existing = Array.isArray(body.fotografias) ? body.fotografias : [];
    body.fotografias = [...existing, ...uploaded];
  }

  if (body.fotografias && typeof body.fotografias === 'string') {
    try {
      body.fotografias = JSON.parse(body.fotografias);
    } catch (_) {
      body.fotografias = [body.fotografias];
    }
  }

  body.servicios = parseServicios(body.servicios);
  return body;
}

const alojamientoController = {
  // HU-11 + HU-13: listado público de alojamientos activos con filtros opcionales
  async listDisponibles(req, res, next) {
    try {
      const page  = Math.max(1, parseInt(req.query.page)  || 1);
      const limit = Math.min(50, Math.max(1, parseInt(req.query.limit) || 20));

      // HU-13: construir objeto de filtros a partir de query params
      const filters = {};

      const TIPOS_ESPACIO_VALIDOS = ['HABITACION', 'APARTAESTUDIO', 'COMPARTIDO'];
      if (req.query.tipoEspacio && TIPOS_ESPACIO_VALIDOS.includes(req.query.tipoEspacio)) {
        filters.tipoEspacio = req.query.tipoEspacio;
      }

      const precioMin = parseFloat(req.query.precioMin);
      const precioMax = parseFloat(req.query.precioMax);
      if (!isNaN(precioMin) && precioMin >= 0) filters.precioMin = precioMin;
      if (!isNaN(precioMax) && precioMax >  0) filters.precioMax = precioMax;

      if (req.query.ubicacion && req.query.ubicacion.trim()) {
        filters.ubicacion = req.query.ubicacion.trim();
      }

      if (req.query.servicios) {
        const lista = Array.isArray(req.query.servicios)
          ? req.query.servicios
          : req.query.servicios.split(',');
        filters.servicios = lista.map((s) => s.trim()).filter(Boolean);
      }

      const alojamientos = await alojamientoService.listDisponibles({ page, limit, filters });
      return res.status(200).json({ data: { alojamientos, page, limit, filters } });
    } catch (error) {
      return next(error);
    }
  },

  async create(req, res, next) {
    try {
      const body = buildBodyFromRequest(req);
      const alojamiento = await alojamientoService.create(req.user.id, body);

      return res.status(201).json({
        message: 'Publicacion creada correctamente',
        data: { alojamiento },
      });
    } catch (error) {
      return next(error);
    }
  },

  async listMine(req, res, next) {
    try {
      const alojamientos = await alojamientoService.listMine(req.user.id);
      return res.status(200).json({ data: { alojamientos } });
    } catch (error) {
      return next(error);
    }
  },

  async getById(req, res, next) {
    try {
      const alojamiento = await alojamientoService.getById(req.params.id, req.user.id);
      return res.status(200).json({ data: { alojamiento } });
    } catch (error) {
      return next(error);
    }
  },

  async update(req, res, next) {
    try {
      const body = buildBodyFromRequest(req);
      const alojamiento = await alojamientoService.update(
        req.params.id,
        req.user.id,
        body,
      );

      return res.status(200).json({
        message: 'Publicacion actualizada correctamente',
        data: { alojamiento },
      });
    } catch (error) {
      return next(error);
    }
  },

  async updateEstado(req, res, next) {
    try {
      const alojamiento = await alojamientoService.updateEstado(
        req.params.id,
        req.user.id,
        req.body || {},
      );

      return res.status(200).json({
        message: 'Estado de publicacion actualizado correctamente',
        data: { alojamiento },
      });
    } catch (error) {
      return next(error);
    }
  },

  async remove(req, res, next) {
    try {
      await alojamientoService.remove(req.params.id, req.user.id);
      return res.status(200).json({
        message: 'Publicacion eliminada correctamente',
      });
    } catch (error) {
      return next(error);
    }
  },
};

module.exports = alojamientoController;
