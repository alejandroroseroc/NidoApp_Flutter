const express = require('express');
const { body } = require('express-validator');
const userController = require('../controllers/user.controller');
const requireAuth = require('../middlewares/auth.middleware');
const {
  handleUploadError,
  profilePhotoUpload,
} = require('../middlewares/upload.middleware');
const validateRequest = require('../middlewares/validate.middleware');

const router = express.Router();

const updateProfileValidations = [
  body('nombre')
    .notEmpty()
    .withMessage('El nombre es obligatorio')
    .isLength({ min: 2, max: 80 })
    .withMessage('El nombre debe tener entre 2 y 80 caracteres'),
  body('telefono')
    .optional({ nullable: true, checkFalsy: true })
    .isLength({ min: 7, max: 15 })
    .withMessage('El telefono debe tener entre 7 y 15 digitos')
    .matches(/^\d+$/)
    .withMessage('El telefono solo debe contener digitos'),
  body('descripcion')
    .optional({ nullable: true, checkFalsy: true })
    .isLength({ max: 300 })
    .withMessage('La descripcion debe tener maximo 300 caracteres'),
];

router.get('/me', requireAuth, userController.getMe);
router.put('/me', requireAuth, updateProfileValidations, validateRequest, userController.updateMe);
router.post(
  '/me/photo',
  requireAuth,
  profilePhotoUpload.single('fotoPerfil'),
  handleUploadError,
  userController.uploadPhoto,
);

// HU-12: perfil público del anfitrión — debe ir DESPUÉS de /me para no colisionar
router.get('/:id', requireAuth, userController.getById);

module.exports = router;
