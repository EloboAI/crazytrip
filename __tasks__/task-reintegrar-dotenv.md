**Parent:** #48

**Descripción:** Restaurar la carga del archivo `.env` en `main.dart` después de revertir cambios previos para que las variables (`GOOGLE_MAPS_API_KEY`, `GOOGLE_VISION_API_KEY`) estén disponibles.

**Tareas técnicas:**
- Verificar dependencia `flutter_dotenv` en `pubspec.yaml`
- Ejecutar `flutter pub get`
- Importar `package:flutter_dotenv/flutter_dotenv.dart` en `main.dart`
- Convertir `main()` a `Future<void> main()` con `await dotenv.load(fileName: '.env')`
- Manejo de excepción si `.env` falta (log y continuar)
- Validar que `Env` service siga funcional

**Criterios de aceptación:**
- [ ] App inicia sin excepción de FileNotFoundError cuando `.env` existe
- [ ] Si `.env` no existe, muestra log claro y no crashea
- [ ] Variables disponibles vía `dotenv.env` y `Env` class

**Notas:** No mover las keys a código. Mantener `.env` ignorado.
