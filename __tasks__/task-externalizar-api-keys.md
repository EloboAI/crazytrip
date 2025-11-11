**Parent:** #48

**Descripción:** Externalizar las API keys (Google Maps y Google Vision) a un archivo `.env` y crear un servicio de acceso seguro desde Dart, evitando que las llaves permanezcan hardcodeadas en el código fuente.

**Tareas técnicas:**
- Agregar dependencia `flutter_dotenv` en `pubspec.yaml`
- Crear archivo `.env` con variables: `GOOGLE_MAPS_API_KEY`, `GOOGLE_VISION_API_KEY`
- Agregar `.env` al `.gitignore`
- Inicializar dotenv antes de `runApp()` en `main.dart`
- Crear `lib/services/env.dart` con métodos de acceso tipados
- Reemplazar usos directos de la key de Maps en código Dart (si aplica)
- Preparar placeholders en Android/iOS para futura inyección (documentado)

**Criterios de aceptación:**
- [ ] Las llaves no aparecen en ningún archivo versionado
- [ ] `.env` está ignorado por git
- [ ] Acceso centralizado a las variables mediante `Env` class
- [ ] La app carga sin errores con `.env` presente
- [ ] Documentado cómo inyectar a Android Manifest e Info.plist

**Notas:** Para las plataformas nativas (Android/iOS) la sustitución dinámica se hará en un paso posterior con script o flavors. Esta tarea cubre la capa Flutter y preparación de placeholders.
