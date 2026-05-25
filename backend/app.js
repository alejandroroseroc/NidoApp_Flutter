const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const path = require('path');
require('dotenv').config();
const { errorHandler } = require('./src/middlewares/error.middleware');

const app = express();

// Seguridad y parseo
app.use(helmet());

const corsOptions = {
  origin: process.env.NODE_ENV === 'production'
    ? '*'
    : ['http://localhost:3000', 'http://10.0.2.2:3000'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};
app.use(cors(corsOptions));

app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health check — endpoint de prueba (CP-01 del plan de pruebas)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', app: 'NidoApp API', version: '1.0.0' });
});

// Registra las rutas de autenticacion.
app.use('/api/auth', require('./src/routes/auth.routes'));
app.use('/api/users', require('./src/routes/user.routes'));
app.use('/api/alojamientos', require('./src/routes/alojamiento.routes'));
app.use('/api/reservas', require('./src/routes/reserva.routes'));

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Manejo de errores global en formato uniforme.
app.use(errorHandler);

module.exports = app;
