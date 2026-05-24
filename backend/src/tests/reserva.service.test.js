const reservaService = require('../services/reserva.service');
const reservaRepository = require('../repositories/reserva.repository');
const userRepository = require('../repositories/user.repository');

jest.mock('../repositories/reserva.repository', () => ({
  create: jest.fn(),
  findAlojamientoById: jest.fn(),
  findPendingByGuestAndAlojamiento: jest.fn(),
  findByHostId: jest.fn(),
  findById: jest.fn(),
  updateStatus: jest.fn(),
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
      duracionDias: 30,
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
      duracionDias: 30,
    });

    expect(reservaRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        alojamientoId: 'home-1',
        invitadoId: 'guest-1',
        duracionDias: 30,
      }),
    );
    expect(result.estado).toBe('PENDIENTE');
  });

  test('crea solicitud con duracion de 5 dias', async () => {
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
      duracionDias: 5,
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
      duracionDias: 5,
    });

    expect(reservaRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({
        duracionDias: 5,
        invitadoId: 'guest-1',
        alojamientoId: 'home-1',
      }),
    );
    expect(result.duracionDias).toBe(5);
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
        duracionDias: 7,
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
        duracionDias: 7,
      }),
    ).rejects.toMatchObject({
      statusCode: 409,
      message: 'Ya tienes una solicitud pendiente para este alojamiento',
    });
  });
});

describe('ReservaService.getHostReservations', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('retorna reservas del anfitrion en modo anfitrion', async () => {
    userRepository.findById.mockResolvedValue({
      id: 'host-1',
      modoActivo: 'ANFITRION',
    });
    reservaRepository.findByHostId.mockResolvedValue([
      {
        id: 'reserva-1',
        estado: 'PENDIENTE',
        fechaIngreso: new Date(),
        duracionDias: 15,
        fechaSolicitud: new Date(),
        invitado: {
          id: 'guest-1',
          nombre: 'Ana',
          correo: 'ana@test.com',
          telefono: '300',
          fotoPerfil: null,
        },
        alojamiento: {
          id: 'home-1',
          titulo: 'Habitacion',
          ubicacion: 'Bogota',
          fotografias: [],
          anfitrionId: 'host-1',
        },
      },
    ]);

    const result = await reservaService.getHostReservations('host-1');

    expect(reservaRepository.findByHostId).toHaveBeenCalledWith('host-1');
    expect(result).toHaveLength(1);
    expect(result[0].invitado.nombre).toBe('Ana');
  });

  test('rechaza si el usuario no esta en modo anfitrion', async () => {
    userRepository.findById.mockResolvedValue({
      id: 'host-1',
      modoActivo: 'INVITADO',
    });

    await expect(reservaService.getHostReservations('host-1')).rejects.toMatchObject({
      statusCode: 403,
    });
  });
});

describe('ReservaService.updateReservationStatus', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('acepta reserva pendiente del anfitrion', async () => {
    reservaRepository.findById.mockResolvedValue({
      id: 'reserva-1',
      estado: 'PENDIENTE',
      fechaIngreso: new Date(),
      duracionDias: 10,
      fechaSolicitud: new Date(),
      invitado: {
        id: 'guest-1',
        nombre: 'Ana',
        correo: 'a@t.com',
        telefono: null,
        fotoPerfil: null,
      },
      alojamiento: {
        id: 'home-1',
        titulo: 'Casa',
        ubicacion: 'Med',
        fotografias: [],
        anfitrionId: 'host-1',
      },
    });
    reservaRepository.updateStatus.mockResolvedValue({
      id: 'reserva-1',
      estado: 'ACEPTADA',
      fechaIngreso: new Date(),
      duracionDias: 10,
      fechaSolicitud: new Date(),
      invitado: {
        id: 'guest-1',
        nombre: 'Ana',
        correo: 'a@t.com',
        telefono: null,
        fotoPerfil: null,
      },
      alojamiento: {
        id: 'home-1',
        titulo: 'Casa',
        ubicacion: 'Med',
        fotografias: [],
        anfitrionId: 'host-1',
      },
    });

    const result = await reservaService.updateReservationStatus(
      'reserva-1',
      'ACEPTADA',
      'host-1',
    );

    expect(reservaRepository.updateStatus).toHaveBeenCalledWith('reserva-1', 'ACEPTADA');
    expect(result.estado).toBe('ACEPTADA');
  });

  test('rechaza si la reserva no es del anfitrion', async () => {
    reservaRepository.findById.mockResolvedValue({
      id: 'reserva-1',
      estado: 'PENDIENTE',
      alojamiento: { anfitrionId: 'otro-host' },
    });

    await expect(
      reservaService.updateReservationStatus('reserva-1', 'ACEPTADA', 'host-1'),
    ).rejects.toMatchObject({
      statusCode: 403,
      message: 'No tienes permiso para gestionar esta reserva',
    });
  });

  test('rechaza si la reserva ya fue procesada', async () => {
    reservaRepository.findById.mockResolvedValue({
      id: 'reserva-1',
      estado: 'ACEPTADA',
      alojamiento: { anfitrionId: 'host-1' },
    });

    await expect(
      reservaService.updateReservationStatus('reserva-1', 'RECHAZADA', 'host-1'),
    ).rejects.toMatchObject({
      statusCode: 400,
      message: 'Solo puedes gestionar reservas en estado pendiente',
    });
  });
});
