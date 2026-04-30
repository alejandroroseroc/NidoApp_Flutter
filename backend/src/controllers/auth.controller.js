const authService = require('../services/auth.service');

// Controlador HTTP para endpoints de autenticacion.
const authController = {
  async register(req, res, next) {
    try {
      const { nombre, correo, contrasena, telefono } = req.body;
      const usuario = await authService.registerUser({
        nombre,
        correo,
        contrasena,
        telefono,
      });

      res.status(201).json({
        message: 'Usuario registrado exitosamente',
        data: usuario,
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = authController;
