const userService = require('../services/user.service');

const userController = {
  async getMe(req, res, next) {
    try {
      const usuario = await userService.getMe(req.user.id);
      res.status(200).json({ data: { usuario } });
    } catch (error) {
      next(error);
    }
  },

  async updateMe(req, res, next) {
    try {
      const usuario = await userService.updateMe(req.user.id, req.body);
      res.status(200).json({
        message: 'Perfil actualizado correctamente',
        data: { usuario },
      });
    } catch (error) {
      next(error);
    }
  },

  // HU-12: perfil público del anfitrión
  async getById(req, res, next) {
    try {
      const usuario = await userService.getPublicProfile(req.params.id);
      res.status(200).json({ data: { usuario } });
    } catch (error) {
      next(error);
    }
  },

  async uploadPhoto(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({ error: 'La imagen es obligatoria' });
      }

      const fotoPerfil = `/uploads/profiles/${req.file.filename}`;
      const usuario = await userService.updatePhoto(req.user.id, fotoPerfil);

      return res.status(200).json({
        message: 'Foto de perfil actualizada correctamente',
        data: { usuario },
      });
    } catch (error) {
      return next(error);
    }
  },
};

module.exports = userController;
