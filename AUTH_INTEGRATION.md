# Crazy Trip - Authentication Integration

Esta documentación describe la integración de autenticación entre la app Flutter y el servidor Rust.

## 🔐 Características Implementadas

### Backend (Rust/Actix)
- ✅ Registro de usuarios con validación de email/username
- ✅ Login con email y contraseña
- ✅ JWT tokens (access + refresh)
- ✅ Refresh automático de tokens
- ✅ Logout con invalidación de sesión
- ✅ Obtención de perfil de usuario
- ✅ Almacenamiento seguro de contraseñas (bcrypt)
- ✅ Protección contra replay de refresh tokens
- ✅ Rate limiting y middleware de seguridad

### Frontend (Flutter)
- ✅ Pantalla de login con validación
- ✅ Pantalla de registro con validación robusta
- ✅ State management con Provider
- ✅ Almacenamiento seguro de tokens (SharedPreferences)
- ✅ Refresh automático de tokens expirados
- ✅ Manejo de errores de red y autenticación
- ✅ Logout con confirmación
- ✅ Perfil de usuario con datos reales

## 📁 Archivos Creados/Modificados

### Nuevos Archivos
```
lib/
├── models/
│   └── auth_models.dart          # Modelos de auth (User, AuthResponse, etc.)
├── services/
│   └── auth_service.dart         # Cliente HTTP para APIs de auth
├── providers/
│   └── auth_provider.dart        # State management de autenticación
└── screens/
    ├── login_screen.dart         # Pantalla de inicio de sesión
    └── register_screen.dart      # Pantalla de registro
```

### Archivos Modificados
```
lib/
├── main.dart                     # Integración de AuthProvider y navegación
├── screens/
│   └── profile_screen.dart       # Mostrar datos de usuario autenticado
└── .env.example                  # Variable AUTH_SERVER_URL añadida
```

## 🚀 Configuración

### 1. Variables de Entorno

Copia `.env.example` a `.env` y configura:

```bash
# Backend server URL
AUTH_SERVER_URL=http://127.0.0.1:8080/api/v1

# Otras keys existentes...
GOOGLE_MAPS_API_KEY=your_key_here
GOOGLE_VISION_API_KEY=your_key_here
```

### 2. Iniciar el Servidor

```bash
cd crazytrip_server_users
cargo run --bin crazytrip-user-service
```

El servidor escuchará en `http://127.0.0.1:8080`.

### 3. Ejecutar la App

```bash
cd crazytrip
flutter run
```

## 🔧 Uso

### Flujo de Autenticación

1. **Primera vez**: App muestra pantalla de login
2. **Registro**: Usuario crea cuenta con email, username y contraseña
3. **Login**: Usuario ingresa credenciales
4. **Tokens**: Servidor envía access_token y refresh_token
5. **Almacenamiento**: Tokens se guardan en SharedPreferences
6. **Navegación**: App muestra MainScreen si autenticado
7. **Sesión**: Tokens se refrescan automáticamente antes de expirar
8. **Logout**: Usuario cierra sesión y tokens se invalidan

### Validaciones de Registro

**Email:**
- Requerido
- Formato válido (contiene @)
- Máximo 254 caracteres

**Username:**
- Requerido
- 3-50 caracteres
- Solo letras, números, guiones y guiones bajos

**Contraseña:**
- Requerida
- Mínimo 8 caracteres, máximo 128
- Al menos una mayúscula
- Al menos una minúscula
- Al menos un número

### APIs Consumidas

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/v1/auth/register` | POST | Registro de nuevo usuario |
| `/api/v1/auth/login` | POST | Inicio de sesión |
| `/api/v1/auth/logout` | POST | Cierre de sesión |
| `/api/v1/auth/refresh` | POST | Renovar access token |
| `/api/v1/user/profile` | GET | Obtener perfil de usuario |

## 🔄 Refresh Automático de Tokens

El `AuthService` maneja automáticamente:
- Detecta tokens expirados antes de hacer requests
- Refresca tokens usando refresh_token
- Reintenta el request original con nuevo token
- Redirige a login si refresh falla

## 🛡️ Seguridad

### Cliente (Flutter)
- Tokens almacenados en SharedPreferences
- No se exponen contraseñas en logs
- Validación de entrada robusta
- HTTPS en producción (configurar AUTH_SERVER_URL)

### Servidor (Rust)
- Contraseñas hasheadas con bcrypt
- JWT firmados con secret seguro
- Refresh tokens de un solo uso
- Rate limiting por IP
- CORS configurado
- Headers de seguridad (HSTS, CSP, etc.)

## 📱 Testing

### Test de Registro
1. Abre la app
2. Toca "Regístrate"
3. Completa el formulario
4. Toca "Crear Cuenta"
5. Verifica que navega a MainScreen

### Test de Login
1. Abre la app
2. Ingresa email y contraseña
3. Toca "Iniciar Sesión"
4. Verifica que navega a MainScreen
5. Ve a Profile para ver tus datos

### Test de Logout
1. En MainScreen, ve a Profile
2. Scroll hasta el botón "Cerrar Sesión"
3. Toca el botón
4. Confirma en el diálogo
5. Verifica que vuelve a LoginScreen

## 🔍 Troubleshooting

### "Network error" al intentar login/registro

**Problema**: La app no puede conectarse al servidor.

**Soluciones**:
- Verifica que el servidor esté corriendo (`cargo run`)
- En iOS Simulator: usa `http://127.0.0.1:8080`
- En Android Emulator: usa `http://10.0.2.2:8080` (configura en .env)
- En dispositivo físico: usa la IP local de tu Mac (ej. `http://192.168.1.100:8080`)

### "Invalid email or password"

**Problema**: Credenciales incorrectas o usuario no existe.

**Soluciones**:
- Verifica que el email esté registrado
- Asegúrate de que la contraseña sea correcta
- Intenta registrarte primero si es la primera vez

### Tokens expirados

**Problema**: Access token expiró y refresh falló.

**Solución**: La app redirigirá automáticamente a login. Vuelve a iniciar sesión.

## 🚧 Próximos Pasos

- [ ] Verificación de email
- [ ] Recuperación de contraseña
- [ ] Login social (Google, Apple)
- [ ] Almacenamiento más seguro (flutter_secure_storage)
- [ ] Biometría (Face ID/Touch ID)
- [ ] Edición de perfil
- [ ] Cambio de contraseña
- [ ] Gestión de sesiones múltiples
- [ ] Notificaciones push

## 📚 Referencias

- [Servidor Rust - README](../crazytrip_server_users/README.md)
- [Documentación del servidor](../crazytrip_server_users/UPGRADE_JSONWEBTOKEN_10.md)
- [Flutter Provider](https://pub.dev/packages/provider)
- [HTTP package](https://pub.dev/packages/http)
