const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/user.repository');
const emailService = require('./email.service');

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = '30d';

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

    const token = jwt.sign(
      { id: createdUser.id, correo: createdUser.correo },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN },
    );

    const { contrasena: _omitPassword, ...safeUser } = createdUser;
    return { token, usuario: safeUser };
  },

  async loginUser({ correo, contrasena }) {
    const usuario = await userRepository.findByEmail(correo);

    if (!usuario) {
      const error = new Error('Credenciales incorrectas');
      error.statusCode = 401;
      throw error;
    }

    const passwordMatch = await bcrypt.compare(contrasena, usuario.contrasena);

    if (!passwordMatch) {
      const error = new Error('Credenciales incorrectas');
      error.statusCode = 401;
      throw error;
    }

    const token = jwt.sign(
      { id: usuario.id, correo: usuario.correo },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN },
    );

    const { contrasena: _omitPassword, ...safeUser } = usuario;
    return { token, usuario: safeUser };
  },

  async forgotPassword({ correo }) {
    const usuario = await userRepository.findByEmail(correo);

    // Siempre responder igual para no revelar si el correo existe.
    if (!usuario) return;

    const codigo = Math.floor(100000 + Math.random() * 900000).toString();
    const expira = new Date(Date.now() + 15 * 60 * 1000); // 15 minutos

    await userRepository.saveResetCode(correo, codigo, expira);
    await emailService.sendPasswordResetCode(correo, codigo);
  },

  async resetPassword({ correo, codigo, nuevaContrasena }) {
    const usuario = await userRepository.findByEmail(correo);

    if (!usuario || !usuario.codigoReset || !usuario.codigoResetExpira) {
      const error = new Error('Codigo invalido o expirado');
      error.statusCode = 400;
      throw error;
    }

    if (usuario.codigoReset !== codigo) {
      const error = new Error('Codigo incorrecto');
      error.statusCode = 400;
      throw error;
    }

    if (new Date() > new Date(usuario.codigoResetExpira)) {
      const error = new Error('El codigo ha expirado');
      error.statusCode = 400;
      throw error;
    }

    const hashedPassword = await bcrypt.hash(nuevaContrasena, 12);
    await userRepository.updatePassword(usuario.id, hashedPassword);
    await userRepository.clearResetCode(usuario.id);
  },

  async updateActiveMode({ usuarioId, modoActivo }) {
    const allowedModes = ['INVITADO', 'ANFITRION'];

    if (!allowedModes.includes(modoActivo)) {
      const error = new Error('Modo activo invalido');
      error.statusCode = 400;
      throw error;
    }

    const updatedUser = await userRepository.updateModoActivo(usuarioId, modoActivo);
    const { contrasena: _omitPassword, ...safeUser } = updatedUser;
    return safeUser;
  },
};

module.exports = authService;
