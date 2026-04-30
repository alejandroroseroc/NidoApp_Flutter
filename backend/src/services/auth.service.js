const bcrypt = require('bcryptjs');
const userRepository = require('../repositories/user.repository');

// Implementa reglas de negocio de autenticacion.
const authService = {
  async registerUser({ nombre, correo, contrasena, telefono }) {
    const existingUser = await userRepository.findByEmail(correo);

    if (existingUser) {
      const error = new Error('El correo ya esta registrado');
      error.statusCode = 409;
      throw error;
    }

    const hashedPassword = await bcrypt.hash(contrasena, 12);

    const createdUser = await userRepository.create({
      nombre,
      correo,
      telefono,
      contrasena: hashedPassword,
    });

    const { contrasena: _omitPassword, ...safeUser } = createdUser;
    return safeUser;
  },
};

module.exports = authService;
