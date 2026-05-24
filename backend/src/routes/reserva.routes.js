const express = require('express');
const { body } = require('express-validator');
const reservaController = require('../controllers/reserva.controller');
const requireAuth = require('../middlewares/auth.middleware');
const validateRequest = require('../middlewares/validate.middleware');

const router = express.Router();

const createSolicitudValidations = [
  body('alojamientoId')
    .notEmpty()
    .withMessage('El alojamiento es obligatorio'),
  body('fechaIngreso')
    .notEmpty()
    .withMessage('La fecha de ingreso es obligatoria')
    .custom((value) => {
      const date = new Date(value);
      if (Number.isNaN(date.getTime())) {
        throw new Error('La fecha de ingreso no es valida');
      }
      return true;
    }),
  body('duracionDias')
    .notEmpty()
    .withMessage('La duracion en dias es obligatoria')
    .isInt({ min: 1, max: 365 })
    .withMessage('La duracion debe estar entre 1 y 365 dias'),
];

router.post(
  '/',
  requireAuth,
  createSolicitudValidations,
  validateRequest,
  reservaController.createSolicitud,
);

const updateStatusValidations = [
  body('estado')
    .notEmpty()
    .withMessage('El estado es obligatorio')
    .isIn(['ACEPTADA', 'RECHAZADA'])
    .withMessage('El estado debe ser ACEPTADA o RECHAZADA'),
];

router.get('/invitado', requireAuth, reservaController.getGuestReservations);

router.get('/host', requireAuth, reservaController.getHostReservations);

router.patch(
  '/:id/status',
  requireAuth,
  updateStatusValidations,
  validateRequest,
  reservaController.updateReservationStatus,
);

module.exports = router;
