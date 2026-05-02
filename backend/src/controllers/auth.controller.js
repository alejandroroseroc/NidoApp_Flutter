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

  async login(req, res, next) {
    try {
      const { correo, contrasena } = req.body;
      const result = await authService.loginUser({ correo, contrasena });

      res.status(200).json({
        message: 'Inicio de sesion exitoso',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  },

  async forgotPassword(req, res, next) {
    try {
      const { correo } = req.body;
      await authService.forgotPassword({ correo });

      // Siempre responder igual para no revelar si el correo existe.
      res.status(200).json({
        message: 'Si el correo existe, recibiras un codigo en tu bandeja.',
      });
    } catch (error) {
      next(error);
    }
  },

  async resetPassword(req, res, next) {
    try {
      const { correo, codigo, nuevaContrasena } = req.body;
      await authService.resetPassword({ correo, codigo, nuevaContrasena });

      res.status(200).json({
        message: 'Contrasena actualizada correctamente',
      });
    } catch (error) {
      next(error);
    }
  },
};

module.exports = authController;
