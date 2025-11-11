# 🌎 CrazyTrip
**DEBUG**
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools
adb connect 192.168.100.4:45225  

**Descubre, Colecciona, Comparte** - La red social de viajes con gamificación estilo Pokémon GO

CrazyTrip es una aplicación móvil que transforma el turismo en una experiencia social, interactiva y gamificada. Los usuarios exploran destinos, coleccionan items únicos usando IA, comparten sus experiencias mediante reels, y descubren lugares mediante un mapa colaborativo al estilo Pokémon GO.

---

## 🎯 Visión

CrazyTrip democratiza el turismo combinando **social media + gamificación + IA**. A diferencia de Booking (solo grandes negocios) o Google Maps (información pasiva), CrazyTrip permite que cualquier negocio - desde food trucks hasta hoteles 5 estrellas - sea descubierto mediante una experiencia tipo Pokémon GO donde usuarios crean y comparten contenido directamente en sus redes sociales.

### Características Principales

- 🗺️ **Mapa Interactivo**: Pins generados por usuarios al descubrir items en ubicaciones reales
- 📸 **Escaneo con IA**: Identifica flora, fauna, comida y cultura mediante cámara
- 🎬 **Reels Sociales**: Comparte experiencias en formato vertical (TikTok-style)
- 🏆 **CrazyDex**: Colecciona items únicos vinculados a ubicaciones específicas
- 🎯 **Contenido Cercano**: Descubre qué hay cerca según tu ubicación actual
- 🤖 **Planificador IA**: Crea itinerarios personalizados con lenguaje natural
- 🎪 **Concursos**: Compite por coleccionar más items o visitar más lugares
- 💰 **Promociones**: Descuentos basados en ubicación de negocios locales

---

## 🗓️ Roadmap de Implementación

### **Fase 1: MVP - Fundamentos** (3 meses) ✅ EN PROGRESO
**Objetivo**: App funcional con captura de items, feed básico y mapa

**Semanas 1-4: Navegación y Estructura**
- ✅ Configuración de 5 tabs con navegación
- ✅ HomeScreen con layout de feed
- ⏳ NearbyScreen con detección de ubicación
- ⏳ Actualizar MainScreen con nuevo bottom nav
- ✅ Modelo Reel y Post
- ⏳ Modelo Promotion actualizado

**Semanas 5-8: Escaneo y CrazyDex**
- Integración de cámara (camera plugin)
- Detección de ubicación actual (geolocator)
- Mock de IA para identificación (futuro: Google Vision API)
- Guardar items escaneados en CrazyDex local
- Pantalla de confirmación post-escaneo

**Semanas 9-12: Mapa Interactivo**
- Mapa con Google Maps Flutter
- Renderizar pins según items en base de datos
- Tap en pin → Modal con info del item
- Filtros: Todos | Capturados | Disponibles
- Clustering de pins cercanos

**Entregables Fase 1**:
- ✅ Navegación de 5 tabs funcional
- ⏳ Escaneo con cámara y guardado local
- ⏳ Mapa con pins básicos
- ✅ Feed con datos mock estáticos
- ⏳ CrazyDex con progreso por categorías

---

### **Fase 2: Social** (2 meses)
**Objetivo**: Convertir en red social con reels, likes, comentarios, follows

**Semanas 13-16: Reels y Contenido**
- Creación de reels (grabación, trim, música)
- Player de video vertical (pageview)
- Sistema de likes y comentarios
- Compartir reels en otras plataformas
- Galería de mis reels en perfil

**Semanas 17-20: Interacción Social**
- Sistema de follows/followers
- Notificaciones (likes, comentarios, nuevos followers)
- Feed algorítmico (seguidos + recomendaciones)
- Perfiles de otros usuarios
- Búsqueda de usuarios y hashtags

**Entregables Fase 2**:
- Creación y reproducción de reels
- Sistema completo de likes/comentarios
- Follows y feed personalizado
- Notificaciones push básicas

---

### **Fase 3: IA y Gamificación** (3 meses)
**Objetivo**: Planificador de viajes IA, concursos, logros avanzados

**Semanas 21-24: Planificador IA**
- Integración con OpenAI/Claude API
- Input en lenguaje natural: "5 días en Costa Rica, aventura"
- Generación de itinerarios con lugares, actividades, items
- Guardar y compartir planes
- Exportar a Google Calendar

**Semanas 25-28: Sistema de Concursos**
- CRUD de concursos (admin)
- Leaderboards en tiempo real
- Tipos: Más items, más lugares, primero en capturar
- Premios y badges especiales
- Timeline de concursos activos

**Semanas 29-32: Logros y Progresión**
- Sistema de achievements expandido
- Niveles de usuario (1-50)
- Badges por hitos (100 items, 10 países, etc.)
- Racha de días activos
- Estadísticas avanzadas con gráficos

**Entregables Fase 3**:
- Planificador IA funcional con guardado
- Sistema de concursos con leaderboards
- Logros y niveles implementados
- Gamificación completa

---

### **Fase 4: Promociones y Monetización** (2 meses)
**Objetivo**: Sistema de promociones, subscripciones, ads

**Semanas 33-36: Promociones Geolocalizadas**
- Dashboard para negocios (crear promociones)
- Pins azules en mapa para promos activas
- Códigos QR o códigos únicos
- Analytics para negocios (views, claims)
- Notificaciones de promos cercanas

**Semanas 37-40: Monetización**
- Suscripción Premium (sin ads, features exclusivos)
- Ads entre reels (Google AdMob)
- Comisiones por promociones canjeadas
- Items exclusivos de pago
- Sistema de referidos con rewards

**Entregables Fase 4**:
- Promociones geolocalizadas activas
- Dashboard para negocios
- Sistema de suscripción Premium
- Ads integrados (AdMob)

---

### **Fase 5: Reservas y Expansión** (1 mes)
**Objetivo**: Integración con booking, tours, multi-idioma

**Semanas 41-44: Booking**
- API de Booking.com / Expedia
- Búsqueda de hoteles, tours, vuelos
- Afiliación con comisión
- Guardado de favoritos
- Integración con planes del IA

**Entregables Fase 5**:
- Sistema de reservas integrado
- Multi-idioma (ES, EN, PT)
- Onboarding mejorado
- App lista para escalar

---

## 🎨 Principios de UX (Nielsen Norman Group)

Basado en [Complex Application Design](https://www.nngroup.com/articles/complex-application-design/):

1. **Learning by Doing**: No tutoriales largos, los usuarios aprenden usando la app
   - Primera experiencia: Abrir → Scan → Identificar algo inmediatamente
   - Tooltips contextuales al visitar secciones por primera vez

2. **Flexible Pathways**: Múltiples caminos para lograr objetivos
   - Capturar item: Scan tab, desde mapa, desde CrazyDex, desde Cerca
   - Ver reels: Home feed, perfil de usuario, pin en mapa, búsqueda

3. **Reduce Clutter**: Esconder complejidad sin perder funcionalidad
   - Filtros en modals/bottom sheets, no siempre visibles
   - Staged disclosure: Ver más detalles → tap en card

4. **Visual Salience**: Info importante es visualmente prominente
   - Progress bars de CrazyDex con colores vibrantes
   - Badges de XP y logros con animaciones
   - Pins en mapa con iconos claros

5. **Track Progress**: Usuarios ven su avance constantemente
   - "Has capturado 45/200 items"
   - Historial de lugares visitados con fechas
   - Planes de viaje guardados con checkboxes

---

## 🏗️ Arquitectura

### Navegación Principal (5 Tabs)

```
┌─────────────────────────────────────────────┐
│  🏠 Inicio  🗺️ Mapa  📸 Scan  🎯 Cerca  👤 Yo │
└─────────────────────────────────────────────┘
```

#### 🏠 Inicio (Home)
Feed principal con reels de viajes, promociones destacadas y contenido de seguidos
- Scroll vertical infinito
- Mix de reels, posts de texto, promociones
- Filtros: Todos | Seguidos | Tendencias

#### 🗺️ Mapa
Mapa interactivo con pins de usuarios, similar a Pokémon GO
- Pins verdes: Items que ya capturaste
- Pins naranjas: Items disponibles para capturar
- Pins azules: Lugares con promociones activas
- Tap en pin → Ver detalles del item + galería de reels de otros usuarios

#### 📸 Scan
Cámara con IA para identificar y coleccionar items
- Modo IDENTIFY: Escanea y agrega a CrazyDex
- Modo REEL: Graba video corto (15-60s)
- Modo STORY: Foto/video efímero 24h
- Detección automática de ubicación y tags

#### 🎯 Cerca (Nearby)
Contenido basado en tu ubicación actual
- Promociones activas en la zona
- Items disponibles para capturar
- Eventos y concursos locales
- "Escaneado por otros aquí" (social proof)

#### 👤 Yo (Profile)
Perfil, estadísticas, configuración
- Mi CrazyDex con progreso
- Mis reels y posts
- Logros y badges
- Planificador de viajes IA
- Historial de lugares visitados

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
│   ├── social_post.dart         # Modelo de contenido social ⭐ NUEVO
│   └── user_profile.dart        # Modelos de usuario y leaderboard + datos mock
├── screens/                     # Vistas de pantalla completa
│   ├── main_screen.dart         # Bottom nav + IndexedStack
│   ├── explore_screen.dart      # Feed de descubrimientos/inicio
│   ├── map_screen.dart          # Mapa interactivo
│   ├── ar_scanner_screen.dart   # Vista de cámara AR
│   ├── achievements_screen.dart # Logros + leaderboard + estadísticas
│   ├── promotions_screen.dart   # Promociones y concursos
│   ├── create_content_screen.dart # Creador de reels sociales ⭐ NUEVO
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
- [ ] **Integración OAuth con redes sociales** (Instagram, TikTok, Facebook) ⭐
- [ ] **API de publicación de reels/videos** en múltiples plataformas ⭐
- [ ] Integración de mapa real (Google Maps/Mapbox)
- [ ] Servicios de GPS/Ubicación
- [ ] Autenticación de usuarios
- [ ] Base de datos (local con Hive/Drift o remota)
- [ ] **Sistema de procesamiento de video in-app** ⭐

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
