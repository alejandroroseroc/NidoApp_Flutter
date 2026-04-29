const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const app = express();

// Seguridad y parseo
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check — endpoint de prueba (CP-01 del plan de pruebas)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', app: 'NidoApp API', version: '1.0.0' });
});

// Rutas (se irán agregando en HU-03, HU-04, etc.)
// app.use('/api/auth', require('./src/routes/auth.routes'));

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Manejo de errores global
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Error interno del servidor' });
});

module.exports = app;