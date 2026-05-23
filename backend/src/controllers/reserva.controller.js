const reservaService = require('../services/reserva.service');

const reservaController = {
  async createSolicitud(req, res, next) {
    try {
      const reserva = await reservaService.createSolicitud(req.user.id, req.body);
      return res.status(201).json({
        message: 'Solicitud de reserva enviada correctamente',
        data: { reserva },
      });
    } catch (error) {
      return next(error);
    }
  },
};

module.exports = reservaController;
