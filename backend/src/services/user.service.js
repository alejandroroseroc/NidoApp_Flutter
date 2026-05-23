const userRepository = require('../repositories/user.repository');

function sanitizeUser(usuario) {
  const { contrasena: _omitPassword, ...safeUser } = usuario;
  return safeUser;
}

// Perfil público del anfitrión para invitados autenticados.
// El endpoint ya requiere JWT, así que exponer correo es aceptable para facilitar contacto.
function sanitizePublicProfile(usuario) {
  return {
    id: usuario.id,
    nombre: usuario.nombre,
    correo: usuario.correo,
    fotoPerfil: usuario.fotoPerfil || null,
    descripcion: usuario.descripcion || null,
    telefono: usuario.telefono || null,
    modoActivo: usuario.modoActivo,
  };
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
      tieneMascotas: data.tieneMascotas,
      esFumador: data.esFumador,
      nivelRuido: data.nivelRuido,
      genero: data.genero,
      otrasPreferencias: data.otrasPreferencias,
    });

    return sanitizeUser(usuario);
  },

  async updatePhoto(usuarioId, fotoPerfil) {
    const usuario = await userRepository.updatePhoto(usuarioId, fotoPerfil);
    return sanitizeUser(usuario);
  },

  // HU-12: perfil público de un anfitrión para invitados
  async getPublicProfile(id) {
    const usuario = await userRepository.findById(id);

    if (!usuario) {
      const error = new Error('Usuario no encontrado');
      error.statusCode = 404;
      throw error;
    }

    return sanitizePublicProfile(usuario);
  },
};

module.exports = userService;
