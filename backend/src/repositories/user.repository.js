const prisma = require('../config/prisma');

// Encapsula acceso a datos de usuarios con Prisma.
const userRepository = {
  async findByEmail(email) {
    return prisma.usuario.findUnique({
      where: { correo: email },
    });
  },

  async create(data) {
    return prisma.usuario.create({
      data: {
        nombre: data.nombre,
        correo: data.correo,
        telefono: data.telefono || null,
        contrasena: data.contrasena,
      },
    });
  },
};

module.exports = userRepository;
