const express = require('express');
const alojamientoController = require('../controllers/alojamiento.controller');
const resenaController = require('../controllers/resena.controller');
const requireAuth = require('../middlewares/auth.middleware');
const {
  handleUploadError,
  alojamientoPhotoUpload,
  optionalAlojamientoPhotos,
} = require('../middlewares/upload.middleware');

const router = express.Router();

// HU-11: listado público de alojamientos activos (invitado)
router.get('/', requireAuth, alojamientoController.listDisponibles);

router.post(
  '/',
  requireAuth,
  optionalAlojamientoPhotos,
  handleUploadError,
  alojamientoController.create,
);

// HU-11 requiere que mis-publicaciones esté ANTES de /:id para no ser capturada como id
router.get('/mis-publicaciones', requireAuth, alojamientoController.listMine);
router.get('/:id/resenas', requireAuth, resenaController.listByAlojamiento);
router.post('/:id/resenas', requireAuth, resenaController.createForAlojamiento);

// HU-12: detalle público (invitado ve ACTIVOS; anfitrión ve los suyos en cualquier estado)
router.get('/:id', requireAuth, alojamientoController.getById);

router.put(
  '/:id',
  requireAuth,
  optionalAlojamientoPhotos,
  handleUploadError,
  alojamientoController.update,
);

router.patch('/:id/estado', requireAuth, alojamientoController.updateEstado);

router.delete('/:id', requireAuth, alojamientoController.remove);

module.exports = router;
