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
    .isISO8601()
    .withMessage('La fecha de ingreso no es valida'),
  body('duracionMeses')
    .optional()
    .isInt({ min: 1, max: 24 })
    .withMessage('La duracion debe estar entre 1 y 24 meses'),
  body('duracionDias')
    .optional()
    .isInt({ min: 1, max: 730 })
    .withMessage('La duracion debe estar entre 1 y 730 dias'),
];

router.post(
  '/',
  requireAuth,
  createSolicitudValidations,
  validateRequest,
  reservaController.createSolicitud,
);

module.exports = router;
