const resenaService = require('../services/resena.service');

const resenaController = {
  async listByAlojamiento(req, res, next) {
    try {
      const result = await resenaService.listByAlojamiento(req.params.id);
      return res.status(200).json({ data: result });
    } catch (error) {
      return next(error);
    }
  },

  async createForAlojamiento(req, res, next) {
    try {
      const resena = await resenaService.createForAlojamiento(
        req.user.id,
        req.params.id,
        req.body,
      );
      return res.status(201).json({
        message: 'Reseña publicada correctamente',
        data: { resena },
      });
    } catch (error) {
      return next(error);
    }
  },
};

module.exports = resenaController;
