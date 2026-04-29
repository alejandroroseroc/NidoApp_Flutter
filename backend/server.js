const https = require('https');
const fs = require('fs');
const app = require('./app');

const PORT = process.env.PORT || 3000;
const HTTPS_PORT = process.env.HTTPS_PORT || 3443;

// HTTP (solo en desarrollo)
app.listen(PORT, () => {
  console.log(`HTTP:  http://localhost:${PORT}/health`);
});

// HTTPS
if (process.env.NODE_ENV === 'development') {
  const sslOptions = {
    key: fs.readFileSync('./certs/localhost-key.pem'),
    cert: fs.readFileSync('./certs/localhost.pem'),
  };
  https.createServer(sslOptions, app).listen(HTTPS_PORT, () => {
    console.log(`HTTPS: https://localhost:${HTTPS_PORT}/health`);
  });
}