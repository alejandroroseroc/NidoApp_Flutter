const express = require('express');
const alojamientoController = require('../controllers/alojamiento.controller');
const requireAuth = require('../middlewares/auth.middleware');
const {
  handleUploadError,
  alojamientoPhotoUpload,
  optionalAlojamientoPhotos,
} = require('../middlewares/upload.middleware');

const router = express.Router();

router.post(
  '/',
  requireAuth,
  optionalAlojamientoPhotos,
  handleUploadError,
  alojamientoController.create,
);

router.get('/mis-publicaciones', requireAuth, alojamientoController.listMine);

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
