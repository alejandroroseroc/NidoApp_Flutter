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

  async findById(id) {
    return prisma.usuario.findUnique({
      where: { id },
    });
  },

  async saveResetCode(correo, codigo, expira) {
    return prisma.usuario.update({
      where: { correo },
      data: { codigoReset: codigo, codigoResetExpira: expira },
    });
  },

  async clearResetCode(id) {
    return prisma.usuario.update({
      where: { id },
      data: { codigoReset: null, codigoResetExpira: null },
    });
  },

  async updatePassword(id, hashedPassword) {
    return prisma.usuario.update({
      where: { id },
      data: { contrasena: hashedPassword },
    });
  },

  async updateProfile(id, data) {
    return prisma.usuario.update({
      where: { id },
      data: {
        nombre: data.nombre,
        telefono: data.telefono || null,
        descripcion: data.descripcion || null,
        tieneMascotas: data.tieneMascotas,
        esFumador: data.esFumador,
        nivelRuido: data.nivelRuido,
        genero: data.genero,
        otrasPreferencias: data.otrasPreferencias,
      },
    });
  },

  async updatePhoto(id, fotoPerfil) {
    return prisma.usuario.update({
      where: { id },
      data: { fotoPerfil },
    });
  },

  async updateModoActivo(id, modoActivo) {
    return prisma.usuario.update({
      where: { id },
      data: { modoActivo },
    });
  },
};

module.exports = userRepository;
