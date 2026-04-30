const authService = require('../services/auth.service');
const userRepository = require('../repositories/user.repository');

jest.mock('../repositories/user.repository', () => ({
  findByEmail: jest.fn(),
  create: jest.fn(),
}));

describe('AuthService.registerUser', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('crea usuario y retorna sin contrasena', async () => {
    userRepository.findByEmail.mockResolvedValue(null);
    userRepository.create.mockImplementation(async (data) => ({
      id: 'user-1',
      nombre: data.nombre,
      correo: data.correo,
      telefono: data.telefono,
      modoActivo: 'INVITADO',
      contrasena: data.contrasena,
    }));

    const result = await authService.registerUser({
      nombre: 'Diego Rosero',
      correo: 'diego@nidoapp.com',
      contrasena: 'ClaveSegura123',
      telefono: '3001234567',
    });

    expect(result).toEqual({
      id: 'user-1',
      nombre: 'Diego Rosero',
      correo: 'diego@nidoapp.com',
      telefono: '3001234567',
      modoActivo: 'INVITADO',
    });
    expect(result.contrasena).toBeUndefined();
  });

  test('lanza error 409 si el correo ya existe', async () => {
    userRepository.findByEmail.mockResolvedValue({ id: 'existente' });

    await expect(
      authService.registerUser({
        nombre: 'Diego Rosero',
        correo: 'diego@nidoapp.com',
        contrasena: 'ClaveSegura123',
        telefono: '3001234567',
      }),
    ).rejects.toMatchObject({
      statusCode: 409,
      message: 'El correo ya esta registrado',
    });
  });

  test('hashea la contrasena antes de crear usuario', async () => {
    userRepository.findByEmail.mockResolvedValue(null);
    userRepository.create.mockImplementation(async (data) => ({
      id: 'user-2',
      nombre: data.nombre,
      correo: data.correo,
      telefono: data.telefono,
      modoActivo: 'INVITADO',
      contrasena: data.contrasena,
    }));

    const plainPassword = 'ClaveSegura123';
    await authService.registerUser({
      nombre: 'Ana Lopez',
      correo: 'ana@nidoapp.com',
      contrasena: plainPassword,
      telefono: '3000000000',
    });

    const sentData = userRepository.create.mock.calls[0][0];
    expect(sentData.contrasena).toBeDefined();
    expect(sentData.contrasena).not.toBe(plainPassword);
  });
});
