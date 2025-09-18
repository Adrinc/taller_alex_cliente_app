import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/taller_alex/notificaciones_provider.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  String _selectedFilter = 'todas';
  String _selectedCategory = 'todas';
  bool _showFilters = false;

  // Configuraciones de notificaciones
  bool _notificacionesActivas = true;
  bool _notificacionesServicio = true;
  bool _notificacionesPromocion = true;
  bool _notificacionesRecordatorio = true;
  bool _notificacionesSistema = false;

  // Eliminamos la lista hardcodeada para usar el provider
  /* final List<Map<String, dynamic>> _notifications = [
    // Notificación coherente con ORD-2025-001 de mis_ordenes_page.dart
    {
      'id': 'NOT-001',
      'type': 'aprobacion',
      'category': 'Servicios',
      'title': 'Aprobación requerida - Frenos',
      'message':
          'Se detectó desgaste excesivo en balatas delanteras y discos traseros de tu Honda Civic (ABC-123). Requiere tu aprobación para proceder. Costo estimado: \$2,500',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': false,
      'priority': 'urgente',
      'orderId': 'ORD-2025-001',
      'vehiculo': 'Honda Civic 2020 - ABC-123',
      'tecnico': 'Juan Pérez',
      'actions': ['Aprobar', 'Rechazar', 'Ver evidencia', 'Ver orden'],
    },
    {
      'id': 'NOT-002',
      'type': 'servicio',
      'category': 'Servicios',
      'title': 'Diagnóstico en progreso',
      'message':
          'Hemos iniciado el diagnóstico general de tu Honda Civic. El técnico Juan Pérez te mantendrá informado del progreso.',
      'date': DateTime.now().subtract(const Duration(hours: 6)),
      'isRead': false,
      'priority': 'media',
      'orderId': 'ORD-2025-001',
      'vehiculo': 'Honda Civic 2020 - ABC-123',
      'tecnico': 'Juan Pérez',
      'actions': ['Ver progreso', 'Ver orden', 'Contactar técnico'],
    },
    // Notificaciones de promociones coherentes con promociones_page.dart
    {
      'id': 'NOT-003',
      'type': 'promocion',
      'category': 'Promociones',
      'title': 'Nueva promoción: Cambio de Aceite + Filtros',
      'message':
          '¡2x1 en cambio de aceite! Incluye filtro de aceite y aire gratis. Válida hasta el 31 de diciembre.',
      'date': DateTime.now().subtract(const Duration(hours: 12)),
      'isRead': true,
      'priority': 'media',
      'promoId': 'PROMO-001',
      'descuento': '50% OFF',
      'validoHasta': '31 Dic 2024',
      'actions': ['Ver promoción', 'Agregar a wallet', 'Agendar cita'],
    },
    {
      'id': 'NOT-004',
      'type': 'promocion',
      'category': 'Promociones',
      'title': 'Diagnóstico Gratis disponible',
      'message':
          'Diagnóstico computarizado gratuito en servicios mayores a \$1,500. ¡Ahorra \$350!',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'priority': 'media',
      'promoId': 'PROMO-003',
      'descuento': '\$350 OFF',
      'validoHasta': '31 Oct 2024',
      'actions': ['Ver promoción', 'Agregar a wallet'],
    },
    // Notificación de cita confirmada (para cuando se creen nuevas)
    {
      'id': 'NOT-005',
      'type': 'confirmacion',
      'category': 'Citas',
      'title': 'Cita confirmada exitosamente',
      'message':
          'Tu cita para el Honda Civic ha sido confirmada para el 25 Sep 2025 a las 10:00 AM en Sucursal Centro.',
      'date': DateTime.now().subtract(const Duration(hours: 18)),
      'isRead': true,
      'priority': 'alta',
      'citaId': 1,
      'fechaCita': '25 Sep 2025',
      'horaCita': '10:00 AM',
      'sucursal': 'Sucursal Centro',
      'vehiculo': 'Honda Civic 2020 - ABC-123',
      'actions': ['Ver cita', 'Reagendar', 'Cancelar'],
    },
    // Recordatorio de cita próxima
    {
      'id': 'NOT-006',
      'type': 'recordatorio',
      'category': 'Recordatorios',
      'title': 'Recordatorio: Cita mañana',
      'message':
          'No olvides tu cita mañana 25 Sep a las 10:00 AM en Sucursal Centro. Lleva tu vehículo con combustible suficiente.',
      'date': DateTime.now().subtract(const Duration(hours: 20)),
      'isRead': true,
      'priority': 'alta',
      'citaId': 1,
      'fechaCita': '25 Sep 2025',
      'horaCita': '10:00 AM',
      'sucursal': 'Sucursal Centro',
      'vehiculo': 'Honda Civic 2020 - ABC-123',
      'actions': ['Ver cita', 'Reagendar', 'Llegar ubicación'],
    },
    // Notificación de orden completada histórica
    {
      'id': 'NOT-007',
      'type': 'completado',
      'category': 'Servicios',
      'title': 'Servicio completado - Toyota Corolla',
      'message':
          'Tu Toyota Corolla (XYZ-789) ya está listo para recoger. Servicios: Cambio de aceite y Afinación menor. Total: \$1,850',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'priority': 'alta',
      'orderId': 'ORD-2025-002',
      'vehiculo': 'Toyota Corolla 2019 - XYZ-789',
      'tecnico': 'María García',
      'total': '\$1,850',
      'actions': ['Ver orden', 'Calificar servicio', 'Descargar factura'],
    },
    // Notificación de sistema
    {
      'id': 'NOT-008',
      'type': 'sistema',
      'category': 'Sistema',
      'title': 'Bienvenido a Taller Alex',
      'message':
          'Gracias por elegir Taller Alex. Explora nuestras promociones y agenda tu primera cita.',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'priority': 'baja',
      'actions': ['Ver promociones', 'Agendar cita'],
    },
  ]; */

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    final notificacionesProvider =
        Provider.of<NotificacionesProvider>(context, listen: false);
    // Crear una copia mutable de la lista
    var notifications =
        List<Map<String, dynamic>>.from(notificacionesProvider.notificaciones);

    // Filtrar por tipo
    if (_selectedFilter != 'todas') {
      notifications = notifications
          .where((notif) => notif['type'] == _selectedFilter)
          .toList();
    }

    // Filtrar por categoría
    if (_selectedCategory != 'todas') {
      notifications = notifications
          .where((notif) => notif['category'] == _selectedCategory)
          .toList();
    }

    // Ordenar por fecha (más reciente primero)
    notifications.sort((a, b) => b['date'].compareTo(a['date']));
    return notifications;
  }

  // Obtener categorías disponibles
  List<String> get _availableCategories {
    final notificacionesProvider =
        Provider.of<NotificacionesProvider>(context, listen: false);
    final categories = notificacionesProvider.notificaciones
        .map((notif) => notif['category'] as String)
        .toSet()
        .toList();
    // Crear una copia mutable antes de insertar
    final result = List<String>.from(categories);
    result.insert(0, 'todas');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificacionesProvider>(
      builder: (context, notificacionesProvider, child) {
        return Scaffold(
          backgroundColor: TallerAlexColors.neumorphicBackground,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TallerAlexColors.neumorphicBackground,
                  TallerAlexColors.paleRose.withOpacity(0.1),
                  TallerAlexColors.neumorphicBackground,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          NeumorphicButton(
                            onPressed: () => context.go('/dashboard'),
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            child: Icon(
                              Icons.arrow_back,
                              color: TallerAlexColors.primaryFuchsia,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  'Notificaciones',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: TallerAlexColors.textPrimary,
                                  ),
                                ),
                                if (notificacionesProvider
                                        .notificacionesNoLeidas >
                                    0) ...[
                                  const SizedBox(width: 8),
                                  Badge(
                                    backgroundColor:
                                        TallerAlexColors.primaryFuchsia,
                                    label: Text(
                                        '${notificacionesProvider.notificacionesNoLeidas}'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          NeumorphicButton(
                            onPressed: _toggleFilters,
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            child: Icon(
                              Icons.filter_list,
                              color: TallerAlexColors.primaryFuchsia,
                            ),
                          ),
                          const SizedBox(width: 8),
                          NeumorphicButton(
                            onPressed: _markAllAsRead,
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            child: Icon(
                              Icons.done_all,
                              color: TallerAlexColors.primaryFuchsia,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filtros
                  if (_showFilters)
                    FadeIn(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildFilters(),
                      ),
                    ),

                  // Tabs
                  FadeIn(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: NeumorphicCard(
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            gradient: TallerAlexColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: TallerAlexColors.textSecondary,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: [
                            Tab(
                                text:
                                    'Notificaciones (${_filteredNotifications.length})'),
                            Tab(text: 'Configuración'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildNotificationsList(),
                        _buildSettings(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return NeumorphicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filtro por categoría
          Row(
            children: [
              Icon(
                Icons.category,
                color: TallerAlexColors.primaryFuchsia,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrar por categoría',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableCategories
                .map((category) => _buildCategoryChip(
                    category, _getCategoryDisplayName(category)))
                .toList(),
          ),

          const SizedBox(height: 20),

          // Filtro por tipo
          Row(
            children: [
              Icon(
                Icons.filter_list,
                color: TallerAlexColors.primaryFuchsia,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filtrar por tipo',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('todas', 'Todas'),
              _buildFilterChip('servicio', 'En progreso'),
              _buildFilterChip('aprobacion', 'Requieren acción'),
              _buildFilterChip('promocion', 'Ofertas'),
              _buildFilterChip('confirmacion', 'Confirmaciones'),
              _buildFilterChip('recordatorio', 'Recordatorios'),
              _buildFilterChip('completado', 'Completados'),
              _buildFilterChip('sistema', 'Sistema'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? TallerAlexColors.primaryGradient : null,
          color: !isSelected ? TallerAlexColors.neumorphicBase : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : TallerAlexColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [
                  TallerAlexColors.lightRose,
                  TallerAlexColors.paleRose
                ])
              : null,
          color: !isSelected ? TallerAlexColors.neumorphicBase : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: TallerAlexColors.primaryFuchsia,
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? TallerAlexColors.primaryFuchsia
                : TallerAlexColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'todas':
        return 'Todas';
      case 'Servicios':
        return '🔧 Servicios';
      case 'Promociones':
        return '🎁 Promociones';
      case 'Citas':
        return '📅 Citas';
      case 'Recordatorios':
        return '⏰ Recordatorios';
      case 'Sistema':
        return '⚙️ Sistema';
      default:
        return category;
    }
  }

  Widget _buildNotificationsList() {
    final filteredNotifications = _filteredNotifications;

    if (filteredNotifications.isEmpty) {
      return FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: TallerAlexColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No hay notificaciones',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilter == 'todas'
                      ? 'No tienes notificaciones pendientes'
                      : 'No hay notificaciones de este tipo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final bool isUnread = !notification['isRead'];

    return GestureDetector(
      onTap: () => _markAsRead(notification['id']),
      child: NeumorphicCard(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isUnread
                ? LinearGradient(
                    colors: [
                      TallerAlexColors.lightRose.withOpacity(0.3),
                      TallerAlexColors.paleRose.withOpacity(0.2),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient:
                            _getNotificationTypeGradient(notification['type']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getNotificationIcon(notification['type']),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: isUnread
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: TallerAlexColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (notification['priority'] == 'urgente')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'URGENTE',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            _getTimeAgo(notification['date']),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: TallerAlexColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: TallerAlexColors.primaryFuchsia,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Mensaje
                Text(
                  notification['message'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                // Acciones
                if (notification['actions'] != null &&
                    notification['actions'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: notification['actions'].map<Widget>((action) {
                      return NeumorphicButton(
                        onPressed: () =>
                            _handleNotificationAction(notification, action),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        backgroundColor:
                            action == 'Aprobar' || action == 'Ver orden'
                                ? TallerAlexColors.primaryFuchsia
                                : null,
                        child: Text(
                          action,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: action == 'Aprobar' || action == 'Ver orden'
                                ? Colors.white
                                : TallerAlexColors.primaryFuchsia,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuración general
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de notificaciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSwitch(
                    'Notificaciones activas',
                    'Recibir todas las notificaciones de la app',
                    _notificacionesActivas,
                    (value) => setState(() => _notificacionesActivas = value),
                    Icons.notifications_active,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tipos de notificaciones
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipos de notificaciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSwitch(
                    'Servicio y órdenes',
                    'Actualizaciones sobre el progreso de tus vehículos',
                    _notificacionesServicio,
                    _notificacionesActivas
                        ? (value) =>
                            setState(() => _notificacionesServicio = value)
                        : null,
                    Icons.build,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingSwitch(
                    'Promociones y ofertas',
                    'Descuentos especiales y promociones exclusivas',
                    _notificacionesPromocion,
                    _notificacionesActivas
                        ? (value) =>
                            setState(() => _notificacionesPromocion = value)
                        : null,
                    Icons.local_offer,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingSwitch(
                    'Recordatorios',
                    'Recordatorios de citas y mantenimientos',
                    _notificacionesRecordatorio,
                    _notificacionesActivas
                        ? (value) =>
                            setState(() => _notificacionesRecordatorio = value)
                        : null,
                    Icons.schedule,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingSwitch(
                    'Actualizaciones del sistema',
                    'Información sobre actualizaciones y mantenimiento',
                    _notificacionesSistema,
                    _notificacionesActivas
                        ? (value) =>
                            setState(() => _notificacionesSistema = value)
                        : null,
                    Icons.system_update,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Horarios
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios de notificación',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No molestar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Define un horario en el que no deseas recibir notificaciones',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: TallerAlexColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: _notificacionesActivas
                              ? () => _selectTime('inicio')
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bedtime,
                                color: TallerAlexColors.primaryFuchsia,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Desde 22:00',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: TallerAlexColors.primaryFuchsia,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: _notificacionesActivas
                              ? () => _selectTime('fin')
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                color: TallerAlexColors.primaryFuchsia,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Hasta 07:00',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: TallerAlexColors.primaryFuchsia,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Acciones
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: _clearAllNotifications,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_sweep,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Limpiar todas las notificaciones',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool)? onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: onChanged != null
                ? TallerAlexColors.primaryGradient
                : LinearGradient(
                    colors: [
                      TallerAlexColors.textLight,
                      TallerAlexColors.textLight.withOpacity(0.7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: onChanged != null
                      ? TallerAlexColors.textPrimary
                      : TallerAlexColors.textLight,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: TallerAlexColors.primaryFuchsia,
          activeTrackColor: TallerAlexColors.primaryFuchsia.withOpacity(0.3),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'servicio':
        return Icons.build;
      case 'aprobacion':
        return Icons.warning;
      case 'promocion':
        return Icons.local_offer;
      case 'recordatorio':
        return Icons.schedule;
      case 'sistema':
        return Icons.system_update;
      default:
        return Icons.notifications;
    }
  }

  LinearGradient _getNotificationTypeGradient(String type) {
    switch (type) {
      case 'servicio':
        return TallerAlexColors.primaryGradient;
      case 'aprobacion':
        return LinearGradient(colors: [Colors.orange, Colors.deepOrange]);
      case 'promocion':
        return LinearGradient(colors: [Colors.green, Colors.teal]);
      case 'recordatorio':
        return LinearGradient(colors: [Colors.blue, Colors.indigo]);
      case 'sistema':
        return LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
      default:
        return TallerAlexColors.primaryGradient;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora';
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  void _markAllAsRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Marcar todas como leídas',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Deseas marcar todas las notificaciones como leídas?',
          style: GoogleFonts.poppins(
            color: TallerAlexColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              final notificacionesProvider =
                  Provider.of<NotificacionesProvider>(context, listen: false);
              notificacionesProvider.marcarTodasComoLeidas();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Todas las notificaciones marcadas como leídas'),
                ),
              );
            },
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'Confirmar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAsRead(String notificationId) {
    final notificacionesProvider =
        Provider.of<NotificacionesProvider>(context, listen: false);
    notificacionesProvider.marcarComoLeida(notificationId);
  }

  void _handleNotificationAction(
      Map<String, dynamic> notification, String action) {
    // Marcar como leída al interactuar
    _markAsRead(notification['id']);

    switch (action) {
      case 'Ver orden':
      case 'Ver progreso':
        context.go('/ordenes');
        break;
      case 'Ver promoción':
      case 'Agregar a wallet':
        context.go('/promociones');
        break;
      case 'Ver cita':
        context.go('/mis-citas');
        break;
      case 'Agendar cita':
        context.go('/agendar-cita');
        break;
      case 'Reagendar':
        context.go('/mis-citas');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Función de reagendar en desarrollo')),
        );
        break;
      case 'Cancelar':
        _showCancelCitaDialog(notification);
        break;
      case 'Aprobar':
      case 'Rechazar':
        _showApprovalDialog(notification, action == 'Aprobar');
        break;
      case 'Ver evidencia':
        _showNotificationDetails(notification);
        break;
      case 'Contactar técnico':
        _showContactTechnicianDialog(notification);
        break;
      case 'Calificar servicio':
      case 'Calificar':
        _showRatingDialog(notification);
        break;
      case 'Descargar factura':
        _downloadInvoice(notification);
        break;
      case 'Ver ubicación':
      case 'Llegar ubicación':
        _showLocationDialog(notification);
        break;
      case 'Ver detalles':
        _showNotificationDetails(notification);
        break;
      case 'Ver promociones':
        context.go('/promociones');
        break;
      case 'Actualizar':
        _showUpdateDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Acción: $action')),
        );
    }
  }

  void _showApprovalDialog(Map<String, dynamic> notification, bool approved) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          approved ? 'Aprobar servicio' : 'Rechazar servicio',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas ${approved ? 'aprobar' : 'rechazar'} este servicio?',
          style: GoogleFonts.poppins(
            color: TallerAlexColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Servicio ${approved ? 'aprobado' : 'rechazado'} correctamente'),
                ),
              );
            },
            backgroundColor: approved ? Colors.green : Colors.red,
            child: Text(
              approved ? 'Aprobar' : 'Rechazar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(Map<String, dynamic> notification) {
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: TallerAlexColors.neumorphicBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Calificar servicio',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: TallerAlexColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo calificarías nuestro servicio?',
                style: GoogleFonts.poppins(
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (index) => GestureDetector(
                          onTap: () => setDialogState(() => rating = index + 1),
                          child: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                        )),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  color: TallerAlexColors.textSecondary,
                ),
              ),
            ),
            NeumorphicButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Gracias por tu calificación de $rating estrellas'),
                  ),
                );
              },
              backgroundColor: TallerAlexColors.primaryFuchsia,
              child: Text(
                'Enviar',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TallerAlexColors.neumorphicBackground,
              TallerAlexColors.paleRose.withOpacity(0.1),
              TallerAlexColors.neumorphicBackground,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: TallerAlexColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                notification['message'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TallerAlexColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTime(String type) {
    showTimePicker(
      context: context,
      initialTime: type == 'inicio'
          ? const TimeOfDay(hour: 22, minute: 0)
          : const TimeOfDay(hour: 7, minute: 0),
    ).then((time) {
      if (time != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Horario ${type == 'inicio' ? 'de inicio' : 'de fin'} actualizado: ${time.format(context)}',
            ),
          ),
        );
      }
    });
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Limpiar notificaciones',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar todas las notificaciones? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(
            color: TallerAlexColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              final notificacionesProvider =
                  Provider.of<NotificacionesProvider>(context, listen: false);
              notificacionesProvider.limpiarNotificacionesLeidas();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todas las notificaciones eliminadas'),
                ),
              );
            },
            backgroundColor: Colors.red,
            child: Text(
              'Eliminar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelCitaDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancelar Cita',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('¿Estás seguro de que deseas cancelar tu cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No', style: GoogleFonts.poppins()),
          ),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cita cancelada exitosamente')),
              );
            },
            backgroundColor: Colors.red,
            child: Text('Sí, cancelar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showContactTechnicianDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Contactar Técnico',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Técnico: ${notification['tecnico'] ?? 'No asignado'}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NeumorphicButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone),
                      SizedBox(width: 4),
                      Text('Llamar')
                    ],
                  ),
                ),
                NeumorphicButton(
                  onPressed: () => Navigator.of(context).pop(),
                  backgroundColor: TallerAlexColors.primaryFuchsia,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Chat', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _downloadInvoice(Map<String, dynamic> notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando factura de ${notification['orderId']}...'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () => context.go('/ordenes'),
        ),
      ),
    );
  }

  void _showLocationDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ubicación',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${notification['sucursal'] ?? 'Sucursal Centro'}'),
            Text('Av. Reforma 123, Col. Centro'),
            Text('Tel: 55 1234 5678'),
            const SizedBox(height: 16),
            NeumorphicButton(
              onPressed: () => Navigator.of(context).pop(),
              backgroundColor: TallerAlexColors.primaryFuchsia,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Abrir en Maps', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Actualizar App',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content:
            Text('Nueva versión disponible con mejoras y nuevas funciones.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Después'),
          ),
          NeumorphicButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text('Actualizar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
