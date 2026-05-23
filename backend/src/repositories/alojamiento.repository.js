const prisma = require('../config/prisma');

const alojamientoInclude = {
  servicios: true,
};

const alojamientoIncludeConAnfitrion = {
  servicios: true,
  anfitrion: {
    select: {
      id: true,
      nombre: true,
      fotoPerfil: true,
    },
  },
};

const alojamientoRepository = {
  async create(data) {
    return prisma.alojamiento.create({
      data: {
        titulo: data.titulo,
        descripcion: data.descripcion,
        tipoEspacio: data.tipoEspacio,
        tipoPrivacidad: data.tipoPrivacidad,
        tipoAcceso: data.tipoAcceso,
        reglas: data.reglas || null,
        precio: data.precio,
        ubicacion: data.ubicacion,
        fotografias: data.fotografias || [],
        anfitrionId: data.anfitrionId,
        estado: data.estado || 'ACTIVO',
        servicios: data.servicios?.length
          ? {
              create: data.servicios.map((nombre) => ({ nombre })),
            }
          : undefined,
      },
      include: alojamientoInclude,
    });
  },

  async findDisponibles({ page = 1, limit = 20, filters = {} } = {}) {
    const skip = (page - 1) * limit;

    const where = { estado: 'ACTIVO' };

    if (filters.tipoEspacio) {
      where.tipoEspacio = filters.tipoEspacio;
    }

    if (filters.precioMin != null || filters.precioMax != null) {
      where.precio = {};
      if (filters.precioMin != null) where.precio.gte = filters.precioMin;
      if (filters.precioMax != null) where.precio.lte = filters.precioMax;
    }

    if (filters.ubicacion) {
      where.ubicacion = { contains: filters.ubicacion, mode: 'insensitive' };
    }

    if (filters.servicios && filters.servicios.length > 0) {
      // Debe tener TODOS los servicios solicitados
      where.AND = filters.servicios.map((nombre) => ({
        servicios: { some: { nombre } },
      }));
    }

    return prisma.alojamiento.findMany({
      where,
      include: alojamientoIncludeConAnfitrion,
      orderBy: { creadoEn: 'desc' },
      skip,
      take: limit,
    });
  },

  async findByIdPublico(id) {
    return prisma.alojamiento.findUnique({
      where: { id },
      include: alojamientoIncludeConAnfitrion,
    });
  },

  async findByAnfitrion(anfitrionId) {
    return prisma.alojamiento.findMany({
      where: { anfitrionId },
      include: alojamientoInclude,
      orderBy: { creadoEn: 'desc' },
    });
  },

  async findById(id) {
    return prisma.alojamiento.findUnique({
      where: { id },
      include: alojamientoInclude,
    });
  },

  async update(id, data) {
    return prisma.$transaction(async (tx) => {
      if (data.servicios !== undefined) {
        await tx.servicio.deleteMany({ where: { alojamientoId: id } });
        if (data.servicios.length > 0) {
          await tx.servicio.createMany({
            data: data.servicios.map((nombre) => ({
              nombre,
              alojamientoId: id,
            })),
          });
        }
      }

      return tx.alojamiento.update({
        where: { id },
        data: {
          titulo: data.titulo,
          descripcion: data.descripcion,
          tipoEspacio: data.tipoEspacio,
          tipoPrivacidad: data.tipoPrivacidad,
          tipoAcceso: data.tipoAcceso,
          reglas: data.reglas,
          precio: data.precio,
          ubicacion: data.ubicacion,
          fotografias: data.fotografias,
          estado: data.estado,
        },
        include: alojamientoInclude,
      });
    });
  },

  async updateEstado(id, estado) {
    return prisma.alojamiento.update({
      where: { id },
      data: { estado },
      include: alojamientoInclude,
    });
  },

  async delete(id) {
    await prisma.servicio.deleteMany({ where: { alojamientoId: id } });
    return prisma.alojamiento.delete({
      where: { id },
      include: alojamientoInclude,
    });
  },
};

module.exports = alojamientoRepository;
