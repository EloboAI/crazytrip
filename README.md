# 🌍 Crazy Trip

**Crazy Trip** es una aplicación móvil de exploración y descubrimiento gamificada que transforma el turismo en una aventura interactiva. Usa escaneo AR, colecciona logros, gana XP y compite en tablas de clasificación mientras descubres lugares turísticos increíbles.

<div align="center">
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.7.0+-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.7.0+-0175C2?logo=dart)](https://dart.dev)
  [![Material Design 3](https://img.shields.io/badge/Material%20Design-3-757575?logo=material-design)](https://m3.material.io)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 ¿Qué es Crazy Trip?

Crazy Trip combina la exploración del mundo real con mecánicas de juego inmersivas. Piensa en Pokémon GO meets Foursquare con elementos de aventura. Escanea lugares turísticos con realidad aumentada, desbloquea descubrimientos, completa desafíos y compite con otros exploradores.

### 🎯 Características Principales

#### 🔍 **Exploración**
- **Feed de descubrimientos** con lugares visitados recientemente
- **Lugares cercanos sin explorar** en diseño de cuadrícula
- **Sistema de categorías** (Naturaleza, Histórico, Arte, Gastronomía, etc.)
- **Recompensas de XP** por cada descubrimiento (50-600 XP)

#### 🗺️ **Mapa Interactivo**
- Vista de mapa con marcadores de ubicación
- Búsqueda de lugares por nombre
- Filtros por categoría
- Hoja inferior mostrando descubrimientos cercanos (radio de 2km)
- Botón "Mi Ubicación" flotante

#### 📸 **Escáner AR (Realidad Aumentada)**
- Experiencia de escaneo de cámara en pantalla completa
- Retículo de escaneo animado
- Indicadores de estado en tiempo real
- Estadísticas rápidas (escaneos totales, XP ganado, racha actual)
- Interfaz glassmorphic para overlay AR
- Identifica y desbloquea descubrimientos mediante AR

#### 🏆 **Logros y Gamificación**
- **Sistema de logros** con múltiples categorías:
  - 🌱 Principiante (Primeros Pasos)
  - 📈 Progreso (Hitos de explorador)
  - 🌲 Específicos de categoría (Amante de la Naturaleza, Urbanita, Historiador)
  - 🔥 Rachas (Guerrero Semanal)
  - 👥 Social (Mariposa Social)
  - 🎖️ Hitos (Explorador Maestro)
  - 🤖 Tecnología (Pionero AR)
  - ✈️ Viajes (Trotamundos)
- **Seguimiento de progreso** con barras visuales
- Recompensas de XP por cada logro (50-1000 XP)
- Distinción entre desbloqueados y en progreso

#### 📊 **Sistema de Clasificación (Leaderboard)**
- Ranking global de jugadores
- Muestra: rango, nombre de usuario, avatar emoji, XP total, cantidad de descubrimientos
- Colores especiales para el top 3 (Oro 🥇, Plata 🥈, Bronce 🥉)
- Resaltado de posición del usuario actual

#### 👤 **Perfil de Usuario**
- Panel de estadísticas personales
- **Sistema de niveles** con seguimiento de XP
- **Contador de rachas** con ícono de fuego 🔥
- Estadísticas rápidas: descubrimientos, XP total, racha
- Etiquetas de categorías favoritas
- Fecha de registro
- Menú de configuración (Editar Perfil, Notificaciones, Descubrimientos Guardados, Invitar Amigos)
- Toggle de modo oscuro
- Funcionalidad de cierre de sesión

#### 🎁 **Promociones y Concursos**
- **Promociones activas** de lugares turísticos
- **Concursos limitados** con premios especiales
- **Descuentos exclusivos** para ubicaciones
- Temporizador de cuenta regresiva para eventos
- Integración con sistema de logros
- Categorías: Concursos, Descuentos, Eventos, Desafíos

---

## 🎮 Sistema de Gamificación

### 💎 Sistema de XP
- Ganado al descubrir ubicaciones (50-600 XP por descubrimiento)
- Ganado al desbloquear logros (50-1000 XP)
- Niveles basados en XP acumulativo
- Barra de progreso mostrando avance de nivel

### 🔥 Sistema de Rachas
- Contador de racha diaria
- Representación con ícono de fuego
- Mantiene el engagement del usuario con visitas consecutivas

### 🏅 Sistema de Logros
- 10+ logros únicos con seguimiento de progreso
- Múltiples categorías (Principiante, Progreso, Categoría, Racha, Social, Hito, Tech, Viajes)
- Indicadores visuales de progresión
- Íconos basados en emojis para cada logro

### 🏆 Competencia en Leaderboard
- Sistema basado en rangos
- Colores de trofeo para el top 3
- Elemento de comparación social

### 🗂️ Categorías de Descubrimientos
- 🌳 **Parque**
- 🏛️ **Histórico**
- 🌲 **Naturaleza**
- 🏖️ **Playa**
- 🎨 **Arte**
- ☕ **Gastronomía**
- 🏢 **Moderno**

---

## 🛠️ Stack Tecnológico

### Framework & Lenguaje
- **Flutter SDK:** ^3.7.0
- **Dart SDK:** ^3.7.0
- **Material Design 3** (useMaterial3: true)

### Dependencias
- `flutter` (SDK oficial)
- `cupertino_icons: ^1.0.8` (íconos estilo iOS)

### Dependencias de Desarrollo
- `flutter_test` (SDK para testing)
- `flutter_lints: ^5.0.0` (Calidad de código)

### Plataformas Soportadas
- ✅ Android (Gradle Kotlin DSL)
- ✅ iOS (Xcode project)
- ✅ Web
- ✅ Linux (CMake)
- ✅ macOS
- ✅ Windows (CMake)

---

## 🎨 Sistema de Diseño

### Tema
- **Material Design 3 Expressive**
- Soporte para tema claro y oscuro
- Colores compatibles con WCAG AA (accesibilidad)
- Paleta amigable para daltónicos

### Paleta de Colores

#### Colores Principales
- **Primary:** Deep Purple `#5E35B1` - Color de marca
- **Secondary:** Deep Orange `#D84315` - Acento
- **Tertiary:** Teal `#00897B` - Destacados
- **Error:** Dark Red `#C62828`

#### Colores de Gamificación
- **Gold:** `#F9A825` (1er lugar 🥇)
- **Silver:** `#757575` (2do lugar 🥈)
- **Bronze:** `#8D6E63` (3er lugar 🥉)
- **XP:** Blue `#0277BD`
- **Streak:** Deep Orange `#E65100` 🔥
- **Achievement:** Deep Purple `#6A1B9A`

#### Gradientes
- **Primary Gradient:** Deep Purple → Medium Purple
- **Discovery Gradient:** Deep Orange → Light Orange-Red
- **Achievement Gradient:** Teal → Light Teal

### Tipografía
- Sistema de tipografía Material Design 3
- 15 variantes de estilos de texto (Display, Headline, Title, Body, Label)
- Estilos personalizados de gamificación (xpCounter, levelBadge, streakCounter)
- Pesos de fuente: 400 (normal), 500 (medium), 600 (semi-bold), 700 (bold)

### Sistema de Espaciado
- **Grid de 8pt** (estándar Material Design)
- Unidades base: 2, 4, 8, 12, 16, 24, 32, 48, 64
- Objetivo táctil mínimo: 48dp (accesibilidad)

### Border Radius
- Small: 8dp
- Medium: 12dp
- Large: 16dp
- XLarge: 20dp
- Pill: 24dp

### Elevación
- Low: 1dp
- Medium: 4dp
- High: 8dp
- FAB: 6dp

---

## 📐 Arquitectura

### Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la app
├── models/                      # Modelos de datos
│   ├── achievement.dart         # Modelo de logros + datos mock
│   ├── discovery.dart           # Modelo de descubrimientos POI + datos mock
│   ├── promotion.dart           # Modelo de promociones + datos mock
│   └── user_profile.dart        # Modelos de usuario y leaderboard + datos mock
├── screens/                     # Vistas de pantalla completa
│   ├── main_screen.dart         # Bottom nav + IndexedStack
│   ├── explore_screen.dart      # Feed de descubrimientos/inicio
│   ├── map_screen.dart          # Mapa interactivo
│   ├── ar_scanner_screen.dart   # Vista de cámara AR
│   ├── achievements_screen.dart # Logros + leaderboard + estadísticas
│   ├── promotions_screen.dart   # Promociones y concursos
│   └── profile_screen.dart      # Perfil de usuario + configuración
├── theme/                       # Sistema de diseño
│   ├── app_theme.dart           # Configuración de tema claro/oscuro
│   ├── app_colors.dart          # Paleta de colores
│   ├── app_spacing.dart         # Constantes de espaciado
│   └── app_text_styles.dart     # Tipografía
└── widgets/                     # Componentes reutilizables
    ├── discovery_card.dart      # Variantes de tarjetas para descubrimientos
    ├── promotion_card.dart      # Tarjetas de promociones
    ├── stat_card.dart           # Tarjetas de estadísticas
    ├── menu_item_card.dart      # Items del menú de perfil
    ├── section_header.dart      # Títulos de sección con íconos
    ├── empty_state.dart         # Placeholders de estado vacío
    ├── progress_widgets.dart    # Indicadores de progreso
    └── shimmer_loading.dart     # Skeletons de carga
```

### Patrón de Arquitectura
- **Gestión de Estado:** StatefulWidget con estado local
- **Navegación:** MaterialPageRoute con Navigator.push
- **Patrón:** MVC simple con screens, models, widgets

### Estructura de Navegación
```
MainScreen (BottomNavigationBar con FAB)
├── Explore Screen (Tab 1) - IndexedStack índice 0
├── Map Screen (Tab 2) - IndexedStack índice 1
├── AR Scanner Screen (FAB) - Navegación push pantalla completa
├── Achievements Screen (Tab 3) - IndexedStack índice 2
└── Profile Screen (Tab 4) - IndexedStack índice 3
    └── Promotions Screen - Push desde menú de perfil
```

---

## 🚀 Instalación y Configuración

### Prerequisitos

- Flutter SDK 3.7.0 o superior
- Dart SDK 3.7.0 o superior
- Android Studio / Xcode (para desarrollo móvil)
- VS Code con extensión de Flutter (recomendado)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/EloboAI/crazytrip.git
   cd crazytrip
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Verificar configuración de Flutter**
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación**
   ```bash
   # Para desarrollo
   flutter run

   # Para plataforma específica
   flutter run -d chrome        # Web
   flutter run -d macos          # macOS
   flutter run -d android        # Android
   flutter run -d ios            # iOS
   ```

5. **Generar build de producción**
   ```bash
   # Android APK
   flutter build apk --release

   # Android App Bundle
   flutter build appbundle --release

   # iOS
   flutter build ios --release

   # Web
   flutter build web --release
   ```

---

## 📱 Capturas de Pantalla

> 🚧 **Próximamente:** Capturas de pantalla de las principales funcionalidades

<div align="center">

| Explorar | Mapa | Escáner AR | Logros |
|:---:|:---:|:---:|:---:|
| _Próximamente_ | _Próximamente_ | _Próximamente_ | _Próximamente_ |

| Perfil | Promociones | Leaderboard | Tema Oscuro |
|:---:|:---:|:---:|:---:|
| _Próximamente_ | _Próximamente_ | _Próximamente_ | _Próximamente_ |

</div>

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🗺️ Roadmap

### ✅ Fase 1: UI/UX Foundation (Completado)
- [x] Sistema de navegación completo
- [x] Todas las pantallas principales con UI pulida
- [x] Sistema de diseño completo (tema, colores, espaciado, tipografía)
- [x] Biblioteca de widgets reutilizables
- [x] Modelos de datos con datos mock
- [x] Soporte de tema oscuro (preparado)

### 🚧 Fase 2: Backend & Funcionalidad (En Progreso)
- [ ] Integración de API/Backend
- [ ] Funcionalidad real de AR/Cámara
- [ ] Integración de mapa real (Google Maps/Mapbox)
- [ ] Servicios de GPS/Ubicación
- [ ] Autenticación de usuarios
- [ ] Base de datos (local con Hive/Drift o remota)

### 📋 Fase 3: Estado & Lógica (Planeado)
- [ ] Gestión de estado (Provider/Riverpod/Bloc)
- [ ] Networking (Dio/HTTP)
- [ ] Almacenamiento local (SharedPreferences/Hive)
- [ ] Manejo de errores y logging
- [ ] Validación y sanitización de datos

### 🔔 Fase 4: Funciones Avanzadas (Planeado)
- [ ] Notificaciones push
- [ ] Compartir en redes sociales
- [ ] Sistema de mensajería in-app
- [ ] Logros con desafíos en tiempo real
- [ ] Integración de análisis
- [ ] Sincronización offline
- [ ] Sistema de recompensas con partners reales

### 🎨 Fase 5: Pulido & Lanzamiento (Futuro)
- [ ] Animaciones y transiciones avanzadas
- [ ] Onboarding interactivo
- [ ] Tests E2E
- [ ] Optimización de rendimiento
- [ ] Accesibilidad mejorada
- [ ] Internacionalización (i18n)
- [ ] App Store / Play Store submission

---

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Por favor, sigue estos pasos:

1. Fork el proyecto
2. Crea tu rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Guías de Contribución
- Sigue las convenciones de código de Dart/Flutter
- Ejecuta `flutter analyze` antes de hacer commit
- Ejecuta `flutter test` para verificar que todos los tests pasen
- Actualiza la documentación según sea necesario
- Usa commits descriptivos siguiendo [Conventional Commits](https://www.conventionalcommits.org/)

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 👨‍💻 Autor

**EloboAI Team**

- GitHub: [@EloboAI](https://github.com/EloboAI)

---

## 🙏 Agradecimientos

- Flutter Team por el increíble framework
- Material Design Team por las guías de diseño
- La comunidad de Flutter por los paquetes y recursos

---

## 📧 Contacto

¿Tienes preguntas o sugerencias? No dudes en:
- Abrir un [Issue](https://github.com/EloboAI/crazytrip/issues)
- Iniciar una [Discussion](https://github.com/EloboAI/crazytrip/discussions)

---

<div align="center">

**Hecho con ❤️ y Flutter**

[⬆ Volver arriba](#-crazy-trip)

</div>
