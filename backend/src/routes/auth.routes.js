const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const validateRequest = require('../middlewares/validate.middleware');

const router = express.Router();

// Valida payload de registro antes de ejecutar el controlador.
const registerValidations = [
  body('correo')
    .notEmpty()
    .withMessage('El correo es obligatorio')
    .isEmail()
    .withMessage('El correo no es valido'),
  body('contrasena')
    .notEmpty()
    .withMessage('La contrasena es obligatoria')
    .isLength({ min: 8 })
    .withMessage('La contrasena debe tener minimo 8 caracteres'),
  body('nombre')
    .notEmpty()
    .withMessage('El nombre es obligatorio')
    .isLength({ min: 2 })
    .withMessage('El nombre debe tener minimo 2 caracteres'),
  body('telefono')
    .optional({ nullable: true, checkFalsy: true })
    .isLength({ min: 7, max: 15 })
    .withMessage('El telefono debe tener entre 7 y 15 digitos')
    .matches(/^\d+$/)
    .withMessage('El telefono solo debe contener digitos'),
];

const loginValidations = [
  body('correo')
    .notEmpty()
    .withMessage('El correo es obligatorio')
    .isEmail()
    .withMessage('El correo no es valido'),
  body('contrasena')
    .notEmpty()
    .withMessage('La contrasena es obligatoria'),
];

const forgotPasswordValidations = [
  body('correo')
    .notEmpty()
    .withMessage('El correo es obligatorio')
    .isEmail()
    .withMessage('El correo no es valido'),
];

const resetPasswordValidations = [
  body('correo')
    .notEmpty()
    .withMessage('El correo es obligatorio')
    .isEmail()
    .withMessage('El correo no es valido'),
  body('codigo')
    .notEmpty()
    .withMessage('El codigo es obligatorio')
    .isLength({ min: 6, max: 6 })
    .withMessage('El codigo debe tener 6 digitos')
    .matches(/^\d{6}$/)
    .withMessage('El codigo solo debe contener digitos'),
  body('nuevaContrasena')
    .notEmpty()
    .withMessage('La nueva contrasena es obligatoria')
    .isLength({ min: 8 })
    .withMessage('La contrasena debe tener minimo 8 caracteres'),
];

router.post('/register', registerValidations, validateRequest, authController.register);
router.post('/login', loginValidations, validateRequest, authController.login);
router.post('/forgot-password', forgotPasswordValidations, validateRequest, authController.forgotPassword);
router.post('/reset-password', resetPasswordValidations, validateRequest, authController.resetPassword);

module.exports = router;
