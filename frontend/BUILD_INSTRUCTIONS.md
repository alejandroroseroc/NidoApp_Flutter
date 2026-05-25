# Cómo generar el APK de NidoApp

## Desarrollo (emulador)

```bash
flutter run
```

## APK para instalar en celular físico

1. Cambiar `kBaseUrl` en `lib/core/constants/api_constants.dart`
   por `kBaseUrlProd` con la URL real de Railway:

   ```dart
   const String kBaseUrl = kBaseUrlProd;
   ```

2. Ejecutar:

   ```bash
   flutter build apk --release
   ```

3. El APK queda en:

   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

4. Instalar en el celular por USB o compartir el archivo.

---

## Notas importantes

- Antes de generar el APK asegúrate de que el backend esté desplegado en Railway
  y que `kBaseUrlProd` tenga la URL correcta.
- Para probar en emulador Android, usa `kBaseUrlDev` (`http://10.0.2.2:3000`).
- Para probar en simulador iOS o macOS, usa `kBaseUrlDevIOS` (`http://localhost:3000`).
