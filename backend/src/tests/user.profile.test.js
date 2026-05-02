const userService = require('../services/user.service');
const userRepository = require('../repositories/user.repository');

jest.mock('../repositories/user.repository', () => ({
  findById: jest.fn(),
  updateProfile: jest.fn(),
  updatePhoto: jest.fn(),
}));

describe('UserService profile', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('actualiza nombre telefono y descripcion sin exponer contrasena', async () => {
    userRepository.updateProfile.mockResolvedValue({
      id: 'user-1',
      nombre: 'Ana Lopez',
      correo: 'ana@nidoapp.com',
      telefono: '3001234567',
      descripcion: 'Busco alojamiento tranquilo.',
      fotoPerfil: null,
      modoActivo: 'INVITADO',
      contrasena: 'hash',
    });

    const result = await userService.updateMe('user-1', {
      nombre: 'Ana Lopez',
      telefono: '3001234567',
      descripcion: 'Busco alojamiento tranquilo.',
    });

    expect(userRepository.updateProfile).toHaveBeenCalledWith('user-1', {
      nombre: 'Ana Lopez',
      telefono: '3001234567',
      descripcion: 'Busco alojamiento tranquilo.',
    });
    expect(result.contrasena).toBeUndefined();
    expect(result.descripcion).toBe('Busco alojamiento tranquilo.');
  });

  test('actualiza foto de perfil y persiste ruta de imagen', async () => {
    userRepository.updatePhoto.mockResolvedValue({
      id: 'user-1',
      nombre: 'Ana Lopez',
      correo: 'ana@nidoapp.com',
      telefono: '3001234567',
      descripcion: null,
      fotoPerfil: '/uploads/profiles/user-1.png',
      modoActivo: 'INVITADO',
      contrasena: 'hash',
    });

    const result = await userService.updatePhoto(
      'user-1',
      '/uploads/profiles/user-1.png',
    );

    expect(userRepository.updatePhoto).toHaveBeenCalledWith(
      'user-1',
      '/uploads/profiles/user-1.png',
    );
    expect(result.fotoPerfil).toBe('/uploads/profiles/user-1.png');
    expect(result.contrasena).toBeUndefined();
  });
});
