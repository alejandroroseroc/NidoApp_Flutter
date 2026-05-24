const { validationResult } = require('express-validator');

// Centraliza errores de validacion del request.
function validateRequest(req, res, next) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const first = errors.array()[0];
    const message =
      typeof first?.msg === 'string' ? first.msg : 'Datos de solicitud invalidos';
    return res.status(400).json({
      error: message,
      errors: errors.array(),
    });
  }

  return next();
}

module.exports = validateRequest;
