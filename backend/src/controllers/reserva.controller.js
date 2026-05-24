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

  async getGuestReservations(req, res, next) {
    try {
      const reservas = await reservaService.getGuestReservations(req.user.id);
      return res.status(200).json({ data: { reservas } });
    } catch (error) {
      return next(error);
    }
  },

  async getHostReservations(req, res, next) {
    try {
      const reservas = await reservaService.getHostReservations(req.user.id);
      return res.status(200).json({ data: { reservas } });
    } catch (error) {
      return next(error);
    }
  },

  async updateReservationStatus(req, res, next) {
    try {
      const reserva = await reservaService.updateReservationStatus(
        req.params.id,
        req.body.estado,
        req.user.id,
      );
      return res.status(200).json({
        message: 'Estado de la reserva actualizado',
        data: { reserva },
      });
    } catch (error) {
      return next(error);
    }
  },
};

module.exports = reservaController;
