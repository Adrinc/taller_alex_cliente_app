import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/taller_alex/ordenes_provider.dart';

class MisOrdenesPage extends StatefulWidget {
  final int? ordenId;

  const MisOrdenesPage({super.key, this.ordenId});

  @override
  State<MisOrdenesPage> createState() => _MisOrdenesPageState();
}

class _MisOrdenesPageState extends State<MisOrdenesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Datos de demo
  final List<Map<String, dynamic>> _activeOrders = [
    {
      'id': 'ORD-2025-001',
      'vehicle': 'Honda Civic 2020 - ABC-123',
      'status': 'diagnostico',
      'statusText': 'Diagnóstico en proceso',
      'progress': 0.3,
      'startDate': '24 Sep 2025',
      'estimatedEnd': '25 Sep 2025',
      'branch': 'Sucursal Centro',
      'technician': 'Juan Pérez',
      'services': [
        {
          'name': 'Diagnóstico general',
          'status': 'en_proceso',
          'statusText': 'En proceso',
          'evidence': ['diag1.jpg', 'diag2.jpg'],
          'requiresApproval': false,
        },
        {
          'name': 'Cambio de frenos',
          'status': 'pendiente_aprobacion',
          'statusText': 'Requiere aprobación',
          'evidence': ['frenos1.jpg'],
          'requiresApproval': true,
          'estimatedCost': 2500.0,
          'description':
              'Se detectó desgaste excesivo en balatas delanteras y discos traseros.',
        },
      ],
      'notifications': 3,
    },
  ];

  final List<Map<String, dynamic>> _pastOrders = [
    {
      'id': 'ORD-2025-002',
      'vehicle': 'Toyota Corolla 2019 - XYZ-789',
      'status': 'completado',
      'statusText': 'Completado',
      'progress': 1.0,
      'startDate': '28 Ago 2025',
      'endDate': '29 Ago 2025',
      'branch': 'Sucursal Norte',
      'technician': 'María García',
      'totalCost': 1850.0,
      'services': [
        {
          'name': 'Cambio de aceite',
          'status': 'completado',
          'statusText': 'Completado',
          'cost': 450.0,
        },
        {
          'name': 'Afinación menor',
          'status': 'completado',
          'statusText': 'Completado',
          'cost': 1400.0,
        },
      ],
      'rating': 5,
    },
    {
      'id': 'ORD-2025-003',
      'vehicle': 'Honda Civic 2020 - ABC-123',
      'status': 'completado',
      'statusText': 'Completado',
      'progress': 1.0,
      'startDate': '15 Jul 2025',
      'endDate': '15 Jul 2025',
      'branch': 'Sucursal Centro',
      'technician': 'Carlos López',
      'totalCost': 750.0,
      'services': [
        {
          'name': 'Inspección pre-viaje',
          'status': 'completado',
          'statusText': 'Completado',
          'cost': 300.0,
        },
        {
          'name': 'Cambio de filtros',
          'status': 'completado',
          'statusText': 'Completado',
          'cost': 450.0,
        },
      ],
      'rating': 4,
    },
  ];

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

  @override
  Widget build(BuildContext context) {
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
                        child: Text(
                          'Mis Órdenes',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.textPrimary,
                          ),
                        ),
                      ),
                      if (_activeOrders.isNotEmpty &&
                          _activeOrders.any((order) =>
                              (order['notifications'] as int?) != null &&
                                  order['notifications'] > 0 ||
                              order['services'].any((service) =>
                                  service['requiresApproval'] == true)))
                        Badge(
                          backgroundColor: TallerAlexColors.primaryFuchsia,
                          label: Text(
                              '${_activeOrders.fold(0, (sum, order) => sum + ((order['notifications'] as int?) ?? 0))}'),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: TallerAlexColors.primaryFuchsia,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
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
                          text: 'Activas (${_activeOrders.length})',
                        ),
                        Tab(
                          text: 'Historial (${_pastOrders.length})',
                        ),
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
                    _buildActiveOrders(),
                    _buildPastOrders(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    if (_activeOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment,
        title: 'No tienes órdenes activas',
        subtitle: 'Agenda una cita para comenzar un nuevo servicio',
        actionText: 'Agendar Cita',
        onAction: () => context.go('/agendar-cita'),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _activeOrders.length,
        itemBuilder: (context, index) {
          final order = _activeOrders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: _buildActiveOrderCard(order),
          );
        },
      ),
    );
  }

  Widget _buildPastOrders() {
    if (_pastOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No tienes órdenes anteriores',
        subtitle: 'Aquí aparecerán tus servicios completados',
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _pastOrders.length,
        itemBuilder: (context, index) {
          final order = _pastOrders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPastOrderCard(order),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
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
                  icon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: 32),
                NeumorphicButton(
                  onPressed: onAction,
                  backgroundColor: TallerAlexColors.primaryFuchsia,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: Text(
                    actionText,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard(Map<String, dynamic> order) {
    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con número de orden y estado
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['id'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.primaryFuchsia,
                      ),
                    ),
                    Text(
                      order['vehicle'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: TallerAlexColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['statusText'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progreso general: ${(order['progress'] * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              NeumorphicContainer(
                width: double.infinity,
                height: 8,
                borderRadius: 4,
                depth: -2,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: TallerAlexColors.neumorphicBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width:
                          MediaQuery.of(context).size.width * order['progress'],
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: TallerAlexColors.primaryGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Información del servicio
          _buildOrderInfo(order),

          const SizedBox(height: 16),

          // Lista de servicios
          ...order['services'].map<Widget>((service) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildServiceItem(service, order['id']),
              )),

          const SizedBox(height: 16),

          // Botón para ver detalles
          NeumorphicButton(
            onPressed: () => _showOrderDetails(order),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.visibility,
                  color: TallerAlexColors.primaryFuchsia,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ver detalles completos',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.primaryFuchsia,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastOrderCard(Map<String, dynamic> order) {
    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['id'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.primaryFuchsia,
                      ),
                    ),
                    Text(
                      order['vehicle'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Completado',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fecha y costo
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: TallerAlexColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${order['startDate']} - ${order['endDate']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '\$${order['totalCost'].toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.primaryFuchsia,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Servicios realizados
          Text(
            'Servicios realizados:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TallerAlexColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...order['services'].map<Widget>((service) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '\$${service['cost'].toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // Rating y botones
          Row(
            children: [
              // Rating
              Row(
                children: List.generate(
                    5,
                    (index) => Icon(
                          index < order['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
              ),
              const Spacer(),
              // Botones
              NeumorphicButton(
                onPressed: () => _showOrderDetails(order),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Ver detalles',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.primaryFuchsia,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NeumorphicButton(
                onPressed: () => _downloadInvoice(order['id']),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: TallerAlexColors.primaryFuchsia,
                child: Text(
                  'Factura',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TallerAlexColors.lightRose.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: TallerAlexColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                order['branch'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.person,
                color: TallerAlexColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                order['technician'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: TallerAlexColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Inicio: ${order['startDate']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'Est. fin: ${order['estimatedEnd']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service, String orderId) {
    final bool requiresApproval = service['requiresApproval'] ?? false;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 8,
      depth: -1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  service['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getServiceStatusColor(service['status'])
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  service['statusText'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getServiceStatusColor(service['status']),
                  ),
                ),
              ),
            ],
          ),
          if (service['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              service['description'],
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ],
          if (service['evidence'] != null &&
              service['evidence'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.photo_camera,
                  color: TallerAlexColors.primaryFuchsia,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Evidencia (${service['evidence'].length})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.primaryFuchsia,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      _showEvidence(service['evidence'], service['name']),
                  child: Text(
                    'Ver fotos',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: TallerAlexColors.primaryFuchsia,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (requiresApproval) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Requiere tu aprobación',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      if (service['estimatedCost'] != null)
                        Text(
                          '\$${service['estimatedCost'].toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.primaryFuchsia,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () =>
                              _approveService(orderId, service['name'], false),
                          backgroundColor: Colors.red,
                          child: Text(
                            'Rechazar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () =>
                              _approveService(orderId, service['name'], true),
                          backgroundColor: Colors.green,
                          child: Text(
                            'Aprobar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getServiceStatusColor(String status) {
    switch (status) {
      case 'completado':
        return Colors.green;
      case 'en_proceso':
        return Colors.blue;
      case 'pendiente_aprobacion':
        return Colors.orange;
      case 'pendiente':
        return TallerAlexColors.textLight;
      default:
        return TallerAlexColors.textSecondary;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalles de la orden',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
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

              // Contenido detallado
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información general
                      NeumorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order['id'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              TallerAlexColors.primaryFuchsia,
                                        ),
                                      ),
                                      Text(
                                        order['vehicle'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: TallerAlexColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: TallerAlexColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    order['statusText'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Progreso visual
                            Row(
                              children: [
                                Icon(
                                  Icons.timeline,
                                  color: TallerAlexColors.primaryFuchsia,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Progreso: ${(order['progress'] * 100).toInt()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: TallerAlexColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            NeumorphicContainer(
                              width: double.infinity,
                              height: 12,
                              borderRadius: 6,
                              depth: -2,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: TallerAlexColors.neumorphicBase,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        order['progress'] *
                                        0.8,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      gradient:
                                          TallerAlexColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Información del servicio
                      NeumorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Servicio',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                                Icons.location_on, 'Sucursal', order['branch']),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.person, 'Técnico asignado',
                                order['technician']),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.schedule, 'Fecha inicio',
                                order['startDate']),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.event, 'Fecha estimada fin',
                                order['estimatedEnd'] ?? 'Por definir'),
                            if (order['totalCost'] != null) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(Icons.attach_money, 'Costo total',
                                  '\$${order['totalCost'].toStringAsFixed(0)}'),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Timeline de servicios
                      NeumorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timeline de Servicios',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...order['services'].asMap().entries.map((entry) {
                              final index = entry.key;
                              final service = entry.value;
                              final isLast =
                                  index == order['services'].length - 1;

                              return Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Timeline dot
                                      Column(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              gradient: _getServiceStatusColor(
                                                          service['status']) ==
                                                      Colors.green
                                                  ? TallerAlexColors
                                                      .primaryGradient
                                                  : null,
                                              color: _getServiceStatusColor(
                                                          service['status']) !=
                                                      Colors.green
                                                  ? _getServiceStatusColor(
                                                          service['status'])
                                                      .withOpacity(0.2)
                                                  : null,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _getServiceStatusColor(
                                                    service['status']),
                                                width: 2,
                                              ),
                                            ),
                                            child: service['status'] ==
                                                    'completado'
                                                ? const Icon(Icons.check,
                                                    size: 16,
                                                    color: Colors.white)
                                                : service['status'] ==
                                                        'en_proceso'
                                                    ? Icon(Icons.refresh,
                                                        size: 16,
                                                        color:
                                                            _getServiceStatusColor(
                                                                service[
                                                                    'status']))
                                                    : Icon(Icons.schedule,
                                                        size: 16,
                                                        color:
                                                            _getServiceStatusColor(
                                                                service[
                                                                    'status'])),
                                          ),
                                          if (!isLast)
                                            Container(
                                              width: 2,
                                              height: 40,
                                              color: TallerAlexColors.textLight
                                                  .withOpacity(0.3),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),

                                      // Service details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    service['name'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: TallerAlexColors
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _getServiceStatusColor(
                                                                service[
                                                                    'status'])
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    service['statusText'],
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          _getServiceStatusColor(
                                                              service[
                                                                  'status']),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (service['description'] !=
                                                null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                service['description'],
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: TallerAlexColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            ],
                                            if (service['cost'] != null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                'Costo: \$${service['cost'].toStringAsFixed(0)}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: TallerAlexColors
                                                      .primaryFuchsia,
                                                ),
                                              ),
                                            ],
                                            if (service['estimatedCost'] !=
                                                null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                'Costo estimado: \$${service['estimatedCost'].toStringAsFixed(0)}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                            if (service['evidence'] != null &&
                                                service['evidence']
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              GestureDetector(
                                                onTap: () => _showEvidence(
                                                    service['evidence'],
                                                    service['name']),
                                                child: NeumorphicContainer(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  borderRadius: 8,
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.photo_camera,
                                                        color: TallerAlexColors
                                                            .primaryFuchsia,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                          'Ver evidencia (${service['evidence'].length} fotos)',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: TallerAlexColors
                                                                .primaryFuchsia,
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: TallerAlexColors
                                                            .primaryFuchsia,
                                                        size: 16,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isLast) const SizedBox(height: 20),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Información adicional
                      NeumorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información Adicional',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(Icons.access_time,
                                'Tiempo estimado total', '2-3 horas'),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.phone, 'Teléfono sucursal',
                                '55 1234 5678'),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.email, 'Email de contacto',
                                'centro@talleralex.com'),
                            const SizedBox(height: 12),
                            _buildDetailRow(Icons.directions_car, 'Kilometraje',
                                '85,432 km'),
                            if (order['notifications'] != null &&
                                order['notifications'] > 0) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notification_important,
                                      color: Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Tienes ${order['notifications']} notificaciones pendientes',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: NeumorphicButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // TODO: Implementar contacto con técnico
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: TallerAlexColors.primaryFuchsia,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Llamar',
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
                              onPressed: () {
                                Navigator.of(context).pop();
                                // TODO: Implementar chat con técnico
                              },
                              backgroundColor: TallerAlexColors.primaryFuchsia,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Chat',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEvidence(List<String> evidence, String serviceName) {
    // Mapear nombres de evidencia a rutas de imágenes reales
    final Map<String, String> evidenceImages = {
      'diag1.jpg': 'images/evidencia_demo/evi1.png',
      'diag2.jpg': 'images/evidencia_demo/evi2.png',
      'frenos1.jpg': 'images/evidencia_demo/evi1.png',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Evidencia - $serviceName',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: SizedBox(
          width: 300,
          height: 400,
          child: Column(
            children: [
              Text(
                'Fotos tomadas durante el servicio',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: evidence.length,
                  itemBuilder: (context, index) {
                    final imagePath = evidenceImages[evidence[index]] ??
                        'images/evidencia_demo/evi1.png';

                    return GestureDetector(
                      onTap: () =>
                          _showFullScreenImage(imagePath, evidence[index]),
                      child: NeumorphicContainer(
                        borderRadius: 12,
                        depth: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Image.asset(
                                imagePath,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    color: TallerAlexColors.neumorphicBase,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.photo,
                                    color: TallerAlexColors.primaryFuchsia,
                                    size: 40,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    evidence[index].split('.').first,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: TallerAlexColors.primaryFuchsia,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imagePath, String imageName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: TallerAlexColors.neumorphicBase,
                    child: Icon(
                      Icons.photo,
                      color: TallerAlexColors.primaryFuchsia,
                      size: 100,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  imageName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _approveService(String orderId, String serviceName, bool approved) {
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
          '¿Estás seguro de que deseas ${approved ? 'aprobar' : 'rechazar'} el servicio "$serviceName"?',
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
              // TODO: Implementar aprobación/rechazo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Servicio ${approved ? 'aprobado' : 'rechazado'} correctamente',
                  ),
                ),
              );
            },
            backgroundColor: approved ? Colors.green : Colors.red,
            child: Text(
              approved ? 'Aprobar' : 'Rechazar',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando factura de $orderId...'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: () {
            // TODO: Implementar descarga de factura
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: TallerAlexColors.primaryFuchsia,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: TallerAlexColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TallerAlexColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
