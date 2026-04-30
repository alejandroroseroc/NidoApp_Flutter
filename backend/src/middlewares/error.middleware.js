// Estandariza la respuesta de errores para toda la API.
function errorHandler(err, req, res, next) {
  const statusCode = err.statusCode || 500;
  const response = {
    error: err.message || 'Error interno del servidor',
  };

  if (process.env.NODE_ENV === 'development' && err.stack) {
    response.stack = err.stack;
  }

  res.status(statusCode).json(response);
}

module.exports = { errorHandler };
