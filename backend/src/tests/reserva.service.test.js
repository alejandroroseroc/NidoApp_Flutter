const reservaService = require('../services/reserva.service');
const reservaRepository = require('../repositories/reserva.repository');
const userRepository = require('../repositories/user.repository');

jest.mock('../repositories/reserva.repository', () => ({
  create: jest.fn(),
  findAlojamientoById: jest.fn(),
  findPendingByGuestAndAlojamiento: jest.fn(),
}));

jest.mock('../repositories/user.repository', () => ({
  findById: jest.fn(),
}));

describe('ReservaService.createSolicitud', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('crea solicitud pendiente para alojamiento activo', async () => {
    const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
    userRepository.findById.mockResolvedValue({
      id: 'guest-1',
      modoActivo: 'INVITADO',
    });
    reservaRepository.findAlojamientoById.mockResolvedValue({
      id: 'home-1',
      estado: 'ACTIVO',
      anfitrionId: 'host-1',
    });
    reservaRepository.findPendingByGuestAndAlojamiento.mockResolvedValue(null);
    reservaRepository.create.mockResolvedValue({
      id: 'reserva-1',
      fechaIngreso: tomorrow,
      duracionMeses: 3,
      duracionDias: null,
      estado: 'PENDIENTE',
      fechaSolicitud: new Date(),
      invitadoId: 'guest-1',
      alojamientoId: 'home-1',
      alojamiento: { id: 'home-1' },
      invitado: { id: 'guest-1' },
    });

    const result = await reservaService.createSolicitud('guest-1', {
      alojamientoId: 'home-1',
      fechaIngreso: tomorrow.toISOString(),
      duracionMeses: 3,
    });

    expect(reservaRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        alojamientoId: 'home-1',
        invitadoId: 'guest-1',
        duracionMeses: 3,
      }),
    );
    expect(result.estado).toBe('PENDIENTE');
  });

  test('crea solicitud con duracion en dias', async () => {
    const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
    userRepository.findById.mockResolvedValue({
      id: 'guest-1',
      modoActivo: 'INVITADO',
    });
    reservaRepository.findAlojamientoById.mockResolvedValue({
      id: 'home-1',
      estado: 'ACTIVO',
      anfitrionId: 'host-1',
    });
    reservaRepository.findPendingByGuestAndAlojamiento.mockResolvedValue(null);
    reservaRepository.create.mockResolvedValue({
      id: 'reserva-2',
      fechaIngreso: tomorrow,
      duracionMeses: 1,
      duracionDias: 10,
      estado: 'PENDIENTE',
      fechaSolicitud: new Date(),
      invitadoId: 'guest-1',
      alojamientoId: 'home-1',
      alojamiento: { id: 'home-1' },
      invitado: { id: 'guest-1' },
    });

    const result = await reservaService.createSolicitud('guest-1', {
      alojamientoId: 'home-1',
      fechaIngreso: tomorrow.toISOString(),
      duracionDias: 10,
    });

    expect(reservaRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        duracionMeses: 1,
        duracionDias: 10,
      }),
    );
    expect(result.duracionDias).toBe(10);
  });

  test('rechaza solicitud si el usuario esta en modo anfitrion', async () => {
    userRepository.findById.mockResolvedValue({
      id: 'guest-1',
      modoActivo: 'ANFITRION',
    });

    await expect(
      reservaService.createSolicitud('guest-1', {
        alojamientoId: 'home-1',
        fechaIngreso: new Date().toISOString(),
        duracionMeses: 1,
      }),
    ).rejects.toMatchObject({
      statusCode: 403,
      message: 'Debes estar en modo invitado para solicitar una reserva',
    });
  });

  test('rechaza solicitudes duplicadas pendientes', async () => {
    userRepository.findById.mockResolvedValue({
      id: 'guest-1',
      modoActivo: 'INVITADO',
    });
    reservaRepository.findAlojamientoById.mockResolvedValue({
      id: 'home-1',
      estado: 'ACTIVO',
      anfitrionId: 'host-1',
    });
    reservaRepository.findPendingByGuestAndAlojamiento.mockResolvedValue({
      id: 'reserva-existente',
    });

    await expect(
      reservaService.createSolicitud('guest-1', {
        alojamientoId: 'home-1',
        fechaIngreso: new Date().toISOString(),
        duracionMeses: 1,
      }),
    ).rejects.toMatchObject({
      statusCode: 409,
      message: 'Ya tienes una solicitud pendiente para este alojamiento',
    });
  });
});
