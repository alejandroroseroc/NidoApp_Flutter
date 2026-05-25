// Centraliza URLs base para los clientes HTTP.
// iOS simulator / macOS: usar kBaseUrlDevIOS
// Android emulator:       usar kBaseUrlDev
// Dispositivo físico:     usar kBaseUrlProd con la URL de Railway

const String kBaseUrlDev    = 'http://10.0.2.2:3000';                       // Emulador Android
const String kBaseUrlDevIOS = 'http://localhost:3000';                       // Simulador iOS / macOS
const String kBaseUrlProd   = 'https://nidoappflutter-production.up.railway.app';              // Railway — cambiar tras el deploy

// Cambia esta constante según dónde corras la ap
const String kBaseUrl = kBaseUrlProd;
