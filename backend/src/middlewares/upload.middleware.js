const fs = require('fs');
const path = require('path');
const multer = require('multer');

const uploadDir = path.join(__dirname, '..', '..', 'uploads', 'profiles');
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const extension = path.extname(file.originalname).toLowerCase();
    cb(null, `${req.user.id}-${Date.now()}${extension}`);
  },
});

const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];

const profilePhotoUpload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!allowedMimeTypes.includes(file.mimetype)) {
      return cb(new Error('La imagen debe ser JPG, PNG o WEBP'));
    }
    return cb(null, true);
  },
});

function handleUploadError(error, _req, res, next) {
  if (!error) return next();

  if (error instanceof multer.MulterError && error.code === 'LIMIT_FILE_SIZE') {
    return res.status(400).json({
      error: 'La imagen debe pesar maximo 2 MB',
    });
  }

  return res.status(400).json({
    error: error.message || 'No se pudo subir la imagen',
  });
}

module.exports = { handleUploadError, profilePhotoUpload };
