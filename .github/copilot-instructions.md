# Copilot Instructions for Taller Alex Cliente App

## Contexto del Proyecto
- **Aplicación Cliente** de Taller Alex: red de talleres automotrices multi-sucursal
- App Flutter especializada para **clientes** (una de tres apps: Cliente, Técnico, Jefe de Taller)
- Enfoque: transparencia, control y confianza del cliente en el proceso de servicio
- **Demo Mode**: Datos hardcodeados/simulados, excepto login que conecta a BD real

## Arquitectura y Base de Datos
- Schema de BD: `taller_alex` (cambió de `nethive`)
- Organization FK: `11` (cambió de `10`)
- Usar `supabaseLU` configurado para schema `taller_alex` desde `lib/helpers/globals.dart`
- Tablas principales: `citas`, `ordenes_servicio`, `clientes`, `vehiculos`, `adjuntos_orden`
- Vistas clave: `vw_estado_vehiculo`, `vw_historial_vehiculo`, `vw_citas_resumen`

## Flujos Críticos de Cliente
- **Gestión de citas**: crear, cancelar, reagendar
- **Seguimiento en tiempo real**: estado del vehículo y progreso de orden
- **Aprobaciones informadas**: servicios sugeridos con evidencia visual (fotos/videos)
- **Historial y facturas**: acceso completo al historial de servicios
- **Notificaciones push**: updates críticos del proceso

## Diseño Neumórfico y Tema
- **Paleta principal**: Fucsia/Rosa con efectos neumórficos
- **Archivo principal**: `lib/theme/taller_alex_theme.dart` con `TallerAlexColors` y `TallerAlexTheme`
- **Efectos visuales**: Sombras suaves, backgrounds blancos, gradientes fucsia
- **Componentes**: `NeumorphicContainer`, `NeumorphicCard`, `NeumorphicButton` para consistencia
- **Paquetes**: flutter_neumorphic, animate_do, glassmorphism, shimmer para efectos

## Estructura de Archivos Específica
```
lib/
├── models/taller_alex/          # Modelos del negocio
│   ├── cliente.dart
│   ├── vehiculo.dart
│   ├── cita.dart
│   ├── orden_servicio.dart
│   └── models.dart             # Archivo barril
├── pages/taller_alex/          # Pantallas específicas
│   ├── splash_page.dart        # Splash con animaciones
│   ├── auth/                   # Login/Registro
│   ├── dashboard_page.dart     # Hub principal
│   └── ...
├── theme/
│   └── taller_alex_theme.dart  # Tema neumórfico completo
```

## Modelos Implementados
- **Cliente**: id, nombre, correo, telefono, direccion, rfc
- **Vehiculo**: marca, modelo, anio, placa, vin, color, combustible
- **Cita**: cliente, vehiculo, sucursal, inicio/fin, estado, fuente
- **OrdenServicio**: numero, estado, fechas, empleado responsable
- **Enums**: EstadoCita, FuenteCita, EstadoOrdenServicio, CombustibleTipo

## Pantallas Principales (Flujo UX)
1. **Splash**: Logo animado con efectos neumórficos
2. **Login/Registro**: Autenticación (solo login conecta a BD real)
3. **Dashboard**: Hub central con tarjetas de acceso rápido
4. **Agendar Cita**: Seleccionar vehículo → sucursal → servicios → fecha
5. **Mis Vehículos**: CRUD de vehículos con fotos
6. **Mis Órdenes**: Estado en tiempo real + evidencia multimedia
7. **Historial**: Servicios pasados + facturas descargables
8. **Promociones**: Cupones activos + wallet de descuentos
9. **Notificaciones**: Centro de mensajes push
10. **Perfil**: Datos personales + configuraciones

## Modo Demo y Datos
- **Solo login real**: conecta a `taller_alex` schema con organization_fk = 11
- **Simulación temporal**: datos persisten en memoria durante sesión
- **No persistencia**: reiniciar app restaura datos hardcodeados
- **Interactividad funcional**: agregar/editar elementos funciona temporalmente

## Patrones de Código (Heredados + Nuevos)
- **Registro de Providers**: siempre en `providers.dart` Y `main.dart`
- **Variables globales**: usar `supabaseLU` de `globals.dart` para BD
- **Router**: GoRouter con protección de rutas basada en `supabase.auth.currentUser`
- **Organización**: models/, providers/, pages/, widgets/ con archivos de barril
- **Tema**: Usar `TallerAlexColors` y componentes `Neumorphic*` para consistencia visual

## Dependencias Clave
```yaml
dependencies:
  flutter_neumorphic: ^3.2.0    # Efectos neumórficos
  animate_do: ^4.2.0            # Animaciones suaves
  glassmorphism: ^3.0.0         # Efectos de cristal
  shimmer: ^3.0.0               # Efectos de carga
  google_fonts: ^6.3.0          # Tipografía Poppins
```

## Flujos de Desarrollo
```bash
flutter clean                   # Limpiar después de cambios grandes
flutter pub get                 # Instalar dependencias
flutter run --hot               # Desarrollo con hot reload
flutter build apk              # Build para Android
```

## Archivos Clave
- `lib/main.dart`: App neumórfica con `TallerAlexApp` y schema `taller_alex`
- `lib/helpers/globals.dart`: `supabaseLU` configurado para `taller_alex`
- `lib/theme/taller_alex_theme.dart`: Sistema de diseño completo
- `lib/models/taller_alex/models.dart`: Todos los modelos del negocio
- `assets/referencia/`: Tablas, vistas y funciones de referencia

## Roles y Permisos Cliente
- Acceso solo a: sus vehículos, citas/órdenes, pagos/facturas, aprobaciones
- NO acceso a: costos internos, asignaciones técnicas, gestión operativa
- Enfoque en transparencia y control de decisiones

---
**CRÍTICO para Demo**: Mantener funcionalidad temporal sin persistencia real, excepto login.
**CRÍTICO para BD**: Usar schema `taller_alex` con organization_fk = 11 via `supabaseLU`.
**CRÍTICO para UI**: Usar componentes neumórficos y paleta TallerAlexColors para consistencia.