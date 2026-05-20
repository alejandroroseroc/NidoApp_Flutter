const { alojamientoService } = require('../services/alojamiento.service');
const alojamientoRepository = require('../repositories/alojamiento.repository');

jest.mock('../repositories/alojamiento.repository', () => ({
  create: jest.fn(),
  findByAnfitrion: jest.fn(),
  findById: jest.fn(),
  update: jest.fn(),
  updateEstado: jest.fn(),
  delete: jest.fn(),
}));

describe('AlojamientoService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('rechaza crear alojamiento sin titulo', async () => {
    await expect(
      alojamientoService.create('host-1', {
        descripcion: 'Descripcion valida',
        tipoEspacio: 'HABITACION',
        tipoPrivacidad: 'PRIVADO',
        tipoAcceso: 'Independiente',
        precioMensual: 500000,
        ubicacion: 'Bogota',
      }),
    ).rejects.toMatchObject({
      statusCode: 400,
      message: 'El titulo es obligatorio',
    });
  });

  test('rechaza precio menor o igual a cero', async () => {
    await expect(
      alojamientoService.create('host-1', {
        titulo: 'Habitacion centro',
        descripcion: 'Descripcion valida',
        tipoEspacio: 'HABITACION',
        tipoPrivacidad: 'PRIVADO',
        tipoAcceso: 'Independiente',
        precioMensual: 0,
        ubicacion: 'Bogota',
      }),
    ).rejects.toMatchObject({
      statusCode: 400,
      message: 'El precio debe ser mayor a 0',
    });
  });

  test('crea alojamiento para anfitrion autenticado', async () => {
    alojamientoRepository.create.mockResolvedValue({
      id: 'alo-1',
      titulo: 'Habitacion centro',
      descripcion: 'Amplia y luminosa',
      tipoEspacio: 'HABITACION',
      tipoPrivacidad: 'PRIVADO',
      tipoAcceso: 'Independiente',
      reglas: null,
      precio: 850000,
      ubicacion: 'Bogota',
      fotografias: [],
      estado: 'ACTIVO',
      anfitrionId: 'host-1',
      creadoEn: new Date('2026-05-19'),
      servicios: [{ id: 's1', nombre: 'Agua', alojamientoId: 'alo-1' }],
    });

    const result = await alojamientoService.create('host-1', {
      titulo: 'Habitacion centro',
      descripcion: 'Amplia y luminosa',
      tipoEspacio: 'HABITACION',
      tipoPrivacidad: 'PRIVADO',
      tipoAcceso: 'Independiente',
      precioMensual: 850000,
      ubicacion: 'Bogota',
      servicios: ['Agua'],
    });

    expect(alojamientoRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        anfitrionId: 'host-1',
        precio: 850000,
      }),
    );
    expect(result.precioMensual).toBe(850000);
    expect(result.servicios).toEqual(['Agua']);
  });

  test('impide editar publicacion de otro usuario', async () => {
    alojamientoRepository.findById.mockResolvedValue({
      id: 'alo-1',
      anfitrionId: 'host-2',
      titulo: 'Otro',
      descripcion: 'Desc',
      tipoEspacio: 'HABITACION',
      tipoPrivacidad: 'PRIVADO',
      tipoAcceso: 'Compartido',
      precio: 500000,
      ubicacion: 'Medellin',
      fotografias: [],
      servicios: [],
    });

    await expect(
      alojamientoService.update('alo-1', 'host-1', { titulo: 'Nuevo titulo' }),
    ).rejects.toMatchObject({
      statusCode: 403,
    });
  });

  test('alterna estado activo/inactivo', async () => {
    alojamientoRepository.findById.mockResolvedValue({
      id: 'alo-1',
      anfitrionId: 'host-1',
      estado: 'ACTIVO',
    });
    alojamientoRepository.updateEstado.mockResolvedValue({
      id: 'alo-1',
      anfitrionId: 'host-1',
      titulo: 'Habitacion',
      descripcion: 'Desc',
      tipoEspacio: 'HABITACION',
      tipoPrivacidad: 'PRIVADO',
      tipoAcceso: 'Independiente',
      reglas: null,
      precio: 500000,
      ubicacion: 'Bogota',
      fotografias: [],
      estado: 'INACTIVO',
      creadoEn: new Date('2026-05-19'),
      servicios: [],
    });

    const result = await alojamientoService.updateEstado('alo-1', 'host-1', {});

    expect(alojamientoRepository.updateEstado).toHaveBeenCalledWith('alo-1', 'INACTIVO');
    expect(result.estado).toBe('INACTIVO');
  });
});
