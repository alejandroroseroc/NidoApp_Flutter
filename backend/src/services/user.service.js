const userRepository = require('../repositories/user.repository');

function sanitizeUser(usuario) {
  const { contrasena: _omitPassword, ...safeUser } = usuario;
  return safeUser;
}

const userService = {
  async getMe(usuarioId) {
    const usuario = await userRepository.findById(usuarioId);

    if (!usuario) {
      const error = new Error('Usuario no encontrado');
      error.statusCode = 404;
      throw error;
    }

    return sanitizeUser(usuario);
  },

  async updateMe(usuarioId, data) {
    const usuario = await userRepository.updateProfile(usuarioId, {
      nombre: data.nombre,
      telefono: data.telefono,
      descripcion: data.descripcion,
    });

    return sanitizeUser(usuario);
  },

  async updatePhoto(usuarioId, fotoPerfil) {
    const usuario = await userRepository.updatePhoto(usuarioId, fotoPerfil);
    return sanitizeUser(usuario);
  },
};

module.exports = userService;
