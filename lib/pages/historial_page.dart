import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/theme/theme.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _filterAnimationController;

  String _selectedFilter = 'todos';
  String _selectedYear = '2024';
  String _selectedVehicle = 'todos';
  bool _showFilters = false;

  // Datos de demo
  final Map<String, int> _yearlyStats = {
    '2024': 8,
    '2023': 12,
    '2022': 6,
  };

  final List<Map<String, dynamic>> _vehicles = [
    {'id': '1', 'name': 'Honda Civic 2020 - ABC-123'},
    {'id': '2', 'name': 'Toyota Corolla 2019 - XYZ-789'},
  ];

  final List<Map<String, dynamic>> _historialItems = [
    {
      'id': 'ORD-2024-001',
      'date': DateTime(2024, 9, 15),
      'vehicleId': '1',
      'vehicle': 'Honda Civic 2020 - ABC-123',
      'services': ['Cambio de aceite', 'Afinación menor'],
      'total': 1850.0,
      'branch': 'Sucursal Centro',
      'technician': 'Juan Pérez',
      'status': 'completado',
      'rating': 5,
      'hasInvoice': true,
      'type': 'mantenimiento',
    },
    {
      'id': 'ORD-2024-002',
      'date': DateTime(2024, 8, 28),
      'vehicleId': '2',
      'vehicle': 'Toyota Corolla 2019 - XYZ-789',
      'services': ['Diagnóstico general', 'Cambio de frenos'],
      'total': 2750.0,
      'branch': 'Sucursal Norte',
      'technician': 'María García',
      'status': 'completado',
      'rating': 4,
      'hasInvoice': true,
      'type': 'reparacion',
    },
    {
      'id': 'ORD-2024-003',
      'date': DateTime(2024, 7, 12),
      'vehicleId': '1',
      'vehicle': 'Honda Civic 2020 - ABC-123',
      'services': ['Inspección pre-viaje'],
      'total': 450.0,
      'branch': 'Sucursal Centro',
      'technician': 'Carlos López',
      'status': 'completado',
      'rating': 5,
      'hasInvoice': true,
      'type': 'inspeccion',
    },
    {
      'id': 'ORD-2024-004',
      'date': DateTime(2024, 6, 8),
      'vehicleId': '2',
      'vehicle': 'Toyota Corolla 2019 - XYZ-789',
      'services': ['Cambio de llantas', 'Balanceado'],
      'total': 3200.0,
      'branch': 'Sucursal Sur',
      'technician': 'Ana Martínez',
      'status': 'completado',
      'rating': 5,
      'hasInvoice': true,
      'type': 'mantenimiento',
    },
    {
      'id': 'ORD-2024-005',
      'date': DateTime(2024, 5, 22),
      'vehicleId': '1',
      'vehicle': 'Honda Civic 2020 - ABC-123',
      'services': ['Alineación y balanceo'],
      'total': 680.0,
      'branch': 'Sucursal Centro',
      'technician': 'Juan Pérez',
      'status': 'completado',
      'rating': 4,
      'hasInvoice': true,
      'type': 'mantenimiento',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredItems {
    var items = _historialItems.where((item) {
      // Filtro por año
      if (item['date'].year.toString() != _selectedYear) return false;

      // Filtro por vehículo
      if (_selectedVehicle != 'todos' &&
          item['vehicleId'] != _selectedVehicle) {
        return false;
      }

      // Filtro por tipo de servicio
      if (_selectedFilter != 'todos' && item['type'] != _selectedFilter) {
        return false;
      }

      return true;
    }).toList();

    // Ordenar por fecha (más reciente primero)
    items.sort((a, b) => b['date'].compareTo(a['date']));
    return items;
  }

  Map<String, dynamic> get _statistics {
    final filteredItems = _filteredItems;
    final totalSpent =
        filteredItems.fold<double>(0, (sum, item) => sum + item['total']);
    final averageRating = filteredItems.isNotEmpty
        ? filteredItems.fold<double>(0, (sum, item) => sum + item['rating']) /
            filteredItems.length
        : 0.0;

    final servicesByType = <String, int>{};
    for (var item in filteredItems) {
      servicesByType[item['type']] = (servicesByType[item['type']] ?? 0) + 1;
    }

    return {
      'totalServices': filteredItems.length,
      'totalSpent': totalSpent,
      'averageRating': averageRating,
      'servicesByType': servicesByType,
    };
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
                          'Historial',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.textPrimary,
                          ),
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
                    ],
                  ),
                ),
              ),

              // Filtros animados
              AnimatedBuilder(
                animation: _filterAnimationController,
                builder: (context, child) => SizeTransition(
                  sizeFactor: _filterAnimationController,
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
                      tabs: const [
                        Tab(text: 'Servicios'),
                        Tab(text: 'Estadísticas'),
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
                    _buildHistoryList(),
                    _buildStatistics(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Año
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Año',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      NeumorphicContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedYear,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _yearlyStats.keys.map((year) {
                            return DropdownMenuItem(
                              value: year,
                              child: Text(
                                '$year (${_yearlyStats[year]} servicios)',
                                style: GoogleFonts.poppins(
                                  color: TallerAlexColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedYear = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Vehículo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehículo',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      NeumorphicContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: _selectedVehicle,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos los vehículos'),
                            ),
                            ..._vehicles.map((vehicle) {
                              return DropdownMenuItem(
                                value: vehicle['id'],
                                child: Text(
                                  vehicle['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedVehicle = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tipo de servicio
            Text(
              'Tipo de servicio',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TallerAlexColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('todos', 'Todos'),
                _buildFilterChip('mantenimiento', 'Mantenimiento'),
                _buildFilterChip('reparacion', 'Reparación'),
                _buildFilterChip('inspeccion', 'Inspección'),
              ],
            ),
          ],
        ),
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

  Widget _buildHistoryList() {
    final filteredItems = _filteredItems;

    if (filteredItems.isEmpty) {
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
                  child: const Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No hay servicios',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No se encontraron servicios con los filtros seleccionados',
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
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildHistoryItem(item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
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
                      item['id'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.primaryFuchsia,
                      ),
                    ),
                    Text(
                      item['vehicle'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${item['total'].toStringAsFixed(0)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.primaryFuchsia,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Fecha y sucursal
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: TallerAlexColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${item['date'].day}/${item['date'].month}/${item['date'].year}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                color: TallerAlexColors.textLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['branch'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Servicios
          Text(
            'Servicios realizados:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TallerAlexColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...item['services'].map<Widget>((service) => Padding(
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
                        service,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: TallerAlexColors.textSecondary,
                        ),
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
                          index < item['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
              ),
              const Spacer(),
              // Botones
              NeumorphicButton(
                onPressed: () => _showServiceDetails(item),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Detalles',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.primaryFuchsia,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item['hasInvoice'])
                NeumorphicButton(
                  onPressed: () => _downloadInvoice(item['id']),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  backgroundColor: TallerAlexColors.primaryFuchsia,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.download,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Factura',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = _statistics;

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen general
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen $_selectedYear',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        'Servicios',
                        '${stats['totalServices']}',
                        Icons.build,
                        TallerAlexColors.primaryFuchsia,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Gastado',
                        '\$${stats['totalSpent'].toStringAsFixed(0)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatCard(
                        'Calificación',
                        '${stats['averageRating'].toStringAsFixed(1)} ⭐',
                        Icons.star,
                        Colors.amber,
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard(
                        'Promedio',
                        stats['totalServices'] > 0
                            ? '\$${(stats['totalSpent'] / stats['totalServices']).toStringAsFixed(0)}'
                            : '\$0',
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Servicios por tipo
            if (stats['servicesByType'].isNotEmpty) ...[
              NeumorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Servicios por tipo',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...stats['servicesByType'].entries.map((entry) {
                      final percentage = entry.value / stats['totalServices'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getServiceTypeName(entry.key),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: TallerAlexColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${entry.value} (${(percentage * 100).toInt()}%)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: TallerAlexColors.textSecondary,
                                  ),
                                ),
                              ],
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
                                    width: MediaQuery.of(context).size.width *
                                        percentage *
                                        0.8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      gradient:
                                          TallerAlexColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Gráfico anual
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servicios por año',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._yearlyStats.entries.map((entry) {
                    final maxServices =
                        _yearlyStats.values.reduce((a, b) => a > b ? a : b);
                    final percentage = entry.value / maxServices;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: TallerAlexColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${entry.value} servicios',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: TallerAlexColors.textSecondary,
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
                                      percentage *
                                      0.8,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: entry.key == _selectedYear
                                        ? TallerAlexColors.primaryGradient
                                        : LinearGradient(
                                            colors: [
                                              TallerAlexColors.lightRose,
                                              TallerAlexColors.paleRose,
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getServiceTypeName(String type) {
    switch (type) {
      case 'mantenimiento':
        return 'Mantenimiento';
      case 'reparacion':
        return 'Reparación';
      case 'inspeccion':
        return 'Inspección';
      default:
        return type;
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _showServiceDetails(Map<String, dynamic> service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                      'Detalles del servicio',
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

              // Detalles
              Text(
                service['id'],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.primaryFuchsia,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                service['vehicle'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              // Más detalles...
            ],
          ),
        ),
      ),
    );
  }

  void _downloadInvoice(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Descargar factura',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          'Selecciona el formato de descarga:',
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
              _performDownload(orderId, 'XML');
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'XML',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: TallerAlexColors.primaryFuchsia,
              ),
            ),
          ),
          const SizedBox(width: 8),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performDownload(orderId, 'PDF');
            },
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'PDF',
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

  void _performDownload(String orderId, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descargando factura $format de $orderId...'),
        action: SnackBarAction(
          label: 'Ver descargas',
          onPressed: () {
            // TODO: Abrir administrador de descargas
          },
        ),
      ),
    );
  }
}
