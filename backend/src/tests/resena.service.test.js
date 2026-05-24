const resenaService = require('../services/resena.service');
const alojamientoRepository = require('../repositories/alojamiento.repository');
const resenaRepository = require('../repositories/resena.repository');

jest.mock('../repositories/alojamiento.repository', () => ({
  findById: jest.fn(),
}));

jest.mock('../repositories/resena.repository', () => ({
  create: jest.fn(),
  findAcceptedReservation: jest.fn(),
  findByAlojamientoId: jest.fn(),
  findExisting: jest.fn(),
}));

describe('ResenaService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('lista reseñas con promedio', async () => {
    resenaRepository.findByAlojamientoId.mockResolvedValue([
      { id: 'r1', calificacion: 5, fecha: new Date(), autorId: 'u1', alojamientoId: 'a1', autor: {} },
      { id: 'r2', calificacion: 3, fecha: new Date(), autorId: 'u2', alojamientoId: 'a1', autor: {} },
    ]);

    const result = await resenaService.listByAlojamiento('a1');

    expect(result.resumen).toEqual({ promedio: 4, total: 2 });
    expect(result.resenas).toHaveLength(2);
  });

  test('crea reseña si existe reserva aceptada', async () => {
    alojamientoRepository.findById.mockResolvedValue({
      id: 'a1',
      estado: 'ACTIVO',
      anfitrionId: 'host-1',
    });
    resenaRepository.findAcceptedReservation.mockResolvedValue({ id: 'res-1' });
    resenaRepository.findExisting.mockResolvedValue(null);
    resenaRepository.create.mockResolvedValue({
      id: 'review-1',
      calificacion: 5,
      comentario: 'Excelente estadia',
      fecha: new Date(),
      autorId: 'guest-1',
      alojamientoId: 'a1',
      autor: { nombre: 'Juan' },
    });

    const result = await resenaService.createForAlojamiento('guest-1', 'a1', {
      calificacion: 5,
      comentario: 'Excelente estadia',
    });

    expect(resenaRepository.create).toHaveBeenCalledWith({
      calificacion: 5,
      comentario: 'Excelente estadia',
      autorId: 'guest-1',
      alojamientoId: 'a1',
    });
    expect(result.calificacion).toBe(5);
  });

  test('rechaza calificaciones fuera del rango', async () => {
    alojamientoRepository.findById.mockResolvedValue({
      id: 'a1',
      estado: 'ACTIVO',
      anfitrionId: 'host-1',
    });
    resenaRepository.findAcceptedReservation.mockResolvedValue({ id: 'res-1' });
    resenaRepository.findExisting.mockResolvedValue(null);

    await expect(
      resenaService.createForAlojamiento('guest-1', 'a1', {
        calificacion: 6,
        comentario: 'No valido',
      }),
    ).rejects.toMatchObject({
      statusCode: 400,
      message: 'La calificacion debe estar entre 1 y 5',
    });
  });
});
