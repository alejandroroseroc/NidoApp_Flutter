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
        req.body,
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
