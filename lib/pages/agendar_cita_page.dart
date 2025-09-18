import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/taller_alex/citas_provider.dart';
import 'package:nethive_neo/providers/taller_alex/vehiculos_provider.dart';
import 'package:nethive_neo/providers/taller_alex/cupones_provider.dart';
import 'package:nethive_neo/providers/taller_alex/notificaciones_provider.dart';

class AgendarCitaPage extends StatefulWidget {
  const AgendarCitaPage({super.key});

  @override
  State<AgendarCitaPage> createState() => _AgendarCitaPageState();
}

class _AgendarCitaPageState extends State<AgendarCitaPage> {
  int _currentStep = 0;
  late PageController _pageController;

  // Los vehículos ahora se obtienen desde VehiculosProvider

  final List<Map<String, dynamic>> _branches = [
    {
      'id': 1,
      'name': 'Sucursal Centro',
      'address': 'Av. Reforma 123, Col. Centro',
      'phone': '55 1234 5678',
      'distance': '2.5 km',
    },
    {
      'id': 2,
      'name': 'Sucursal Norte',
      'address': 'Blvd. Norte 456, Col. Lindavista',
      'phone': '55 9876 5432',
      'distance': '8.2 km',
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'name': 'Cambio de aceite',
      'description': 'Cambio de aceite y filtro',
      'price': 450.0,
      'duration': 30,
      'selected': false,
    },
    {
      'id': 2,
      'name': 'Afinación menor',
      'description': 'Revisión general del motor',
      'price': 850.0,
      'duration': 60,
      'selected': false,
    },
    {
      'id': 3,
      'name': 'Alineación y balanceo',
      'description': 'Alineación y balanceo de llantas',
      'price': 600.0,
      'duration': 45,
      'selected': false,
    },
    {
      'id': 4,
      'name': 'Revisión de frenos',
      'description': 'Inspección completa del sistema de frenos',
      'price': 300.0,
      'duration': 30,
      'selected': false,
    },
  ];

  final List<String> _availableTimes = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  Map<String, dynamic>? _selectedVehicle;
  Map<String, dynamic>? _selectedBranch;
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _couponController = TextEditingController();
  Map<String, dynamic>? _selectedCoupon;
  bool _useManualCoupon = false;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                          'Agendar Cita',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stepper
              FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: NeumorphicCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        _buildStepIndicator(0, 'Vehículo'),
                        _buildStepConnector(0),
                        _buildStepIndicator(1, 'Sucursal'),
                        _buildStepConnector(1),
                        _buildStepIndicator(2, 'Servicios'),
                        _buildStepConnector(2),
                        _buildStepIndicator(3, 'Fecha'),
                        _buildStepConnector(3),
                        _buildStepIndicator(4, 'Confirmar'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: PageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  children: [
                    _buildVehicleSelection(),
                    _buildBranchSelection(),
                    _buildServiceSelection(),
                    _buildDateTimeSelection(),
                    _buildConfirmation(),
                  ],
                ),
              ),

              // Navigation buttons
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: NeumorphicButton(
                            onPressed: () => _goToStep(_currentStep - 1),
                            backgroundColor: TallerAlexColors.neumorphicSurface,
                            child: Text(
                              'Anterior',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: _getNextButtonAction(),
                          backgroundColor: TallerAlexColors.primaryFuchsia,
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _getNextButtonText(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
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

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: isActive || isCompleted
                  ? TallerAlexColors.primaryGradient
                  : null,
              color:
                  isActive || isCompleted ? null : TallerAlexColors.textLight,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Center(
                    child: Text(
                      '${step + 1}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isActive || isCompleted
                  ? TallerAlexColors.primaryFuchsia
                  : TallerAlexColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;

    return Container(
      height: 2,
      width: 20,
      color: isCompleted
          ? TallerAlexColors.primaryFuchsia
          : TallerAlexColors.textLight,
    );
  }

  Widget _buildVehicleSelection() {
    return Consumer<VehiculosProvider>(
      builder: (context, vehiculosProvider, child) {
        final vehicles = vehiculosProvider.vehiculos;

        return FadeIn(
          duration: const Duration(milliseconds: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecciona tu vehículo',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el vehículo para el cual deseas agendar la cita (${vehicles.length} disponibles)',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                ...vehicles.map((vehicle) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedVehicle = vehicle),
                        child: NeumorphicCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: TallerAlexColors.neumorphicBase,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.directions_car,
                                  color: TallerAlexColors.primaryFuchsia,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${vehicle['brand']} ${vehicle['model']} ${vehicle['year']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: TallerAlexColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Placas: ${vehicle['plate']} • ${vehicle['color']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: TallerAlexColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<Map<String, dynamic>>(
                                value: vehicle,
                                groupValue: _selectedVehicle,
                                onChanged: (value) =>
                                    setState(() => _selectedVehicle = value),
                                activeColor: TallerAlexColors.primaryFuchsia,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),

                // Agregar nuevo vehículo
                NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => context.go('/vehiculos'),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: TallerAlexColors.lightRose.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add,
                            color: TallerAlexColors.primaryFuchsia,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agregar nuevo vehículo',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: TallerAlexColors.primaryFuchsia,
                                ),
                              ),
                              Text(
                                'Registra un vehículo adicional',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: TallerAlexColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: TallerAlexColors.textLight,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchSelection() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona sucursal',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige la sucursal más conveniente para ti',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TallerAlexColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ..._branches.map((branch) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBranch = branch),
                    child: NeumorphicCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: TallerAlexColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      branch['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: TallerAlexColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      branch['address'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: TallerAlexColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<Map<String, dynamic>>(
                                value: branch,
                                groupValue: _selectedBranch,
                                onChanged: (value) =>
                                    setState(() => _selectedBranch = value),
                                activeColor: TallerAlexColors.primaryFuchsia,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: TallerAlexColors.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                branch['phone'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: TallerAlexColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.navigation,
                                color: TallerAlexColors.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                branch['distance'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: TallerAlexColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona servicios',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Elige los servicios que necesita tu vehículo',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TallerAlexColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            ..._services.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: NeumorphicCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: service['selected'],
                        onChanged: (value) {
                          setState(() {
                            _services[index]['selected'] = value ?? false;
                          });
                        },
                        activeColor: TallerAlexColors.primaryFuchsia,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                            Text(
                              service['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: TallerAlexColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '\$${service['price'].toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: TallerAlexColors.primaryFuchsia,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.schedule,
                                  color: TallerAlexColors.textLight,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${service['duration']} min',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: TallerAlexColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Resumen de servicios seleccionados
            if (_services.any((service) => service['selected'])) ...[
              const SizedBox(height: 16),
              NeumorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...() {
                      final selectedServices =
                          _services.where((s) => s['selected']).toList();
                      return selectedServices.map((service) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  service['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: TallerAlexColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '\$${service['price'].toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: TallerAlexColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ));
                    }(),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total estimado:',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.textPrimary,
                          ),
                        ),
                        Text(
                          '\$${_services.where((s) => s['selected']).fold(0.0, (sum, s) => sum + s['price']).toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.primaryFuchsia,
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
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha y hora',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona cuándo deseas llevar tu vehículo',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TallerAlexColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Calendario
            NeumorphicCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: TallerAlexColors.primaryFuchsia,
                            onPrimary: Colors.white,
                            surface: TallerAlexColors.neumorphicBackground,
                            onSurface: TallerAlexColors.textPrimary,
                          ),
                      datePickerTheme: DatePickerThemeData(
                        backgroundColor: TallerAlexColors.neumorphicBackground,
                        elevation: 8.0,
                        shadowColor:
                            TallerAlexColors.shadowDark.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        headerBackgroundColor: TallerAlexColors.primaryFuchsia,
                        headerForegroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        headerHeadlineStyle: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                        headerHelpStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        weekdayStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TallerAlexColors.textSecondary,
                        ),
                        dayStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        dayForegroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          // Priorizar estado seleccionado sobre cualquier otro estado
                          if (states.contains(MaterialState.selected)) {
                            return const Color.fromARGB(255, 236, 2, 88);
                          }
                          if (states.contains(MaterialState.disabled)) {
                            return TallerAlexColors.textLight.withOpacity(0.4);
                          }
                          // Para estados hover/focused mantener el color normal
                          return TallerAlexColors.textPrimary;
                        }),
                        dayBackgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          // Si está seleccionado, siempre mantener el fucsia
                          if (states.contains(MaterialState.selected)) {
                            return TallerAlexColors.primaryFuchsia;
                          }
                          // Si está deshabilitado, transparent
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.transparent;
                          }
                          // Si está siendo hover/focused pero ya fue seleccionado, mantener fucsia
                          if (states.contains(MaterialState.hovered) ||
                              states.contains(MaterialState.focused)) {
                            return Colors.transparent;
                          }
                          return Colors.transparent;
                        }),
                        dayOverlayColor:
                            MaterialStateProperty.resolveWith((states) {
                          // Evitar overlay colors que puedan interferir con la selección
                          if (states.contains(MaterialState.selected)) {
                            return Colors.transparent;
                          }
                          if (states.contains(MaterialState.hovered)) {
                            return TallerAlexColors.primaryFuchsia
                                .withOpacity(0.1);
                          }
                          if (states.contains(MaterialState.pressed)) {
                            return TallerAlexColors.primaryFuchsia
                                .withOpacity(0.2);
                          }
                          return const Color.fromARGB(187, 4, 198, 85);
                        }),
                        dayShape: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: TallerAlexColors.primaryFuchsia,
                                width: 2,
                              ),
                            );
                          }
                          return RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          );
                        }),
                        todayForegroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return TallerAlexColors.primaryFuchsia;
                        }),
                        todayBackgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return TallerAlexColors.primaryFuchsia;
                          }
                          return TallerAlexColors.primaryFuchsia
                              .withOpacity(0.1);
                        }),
                        todayBorder: BorderSide(
                          color: TallerAlexColors.primaryFuchsia,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      onDateChanged: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Horarios disponibles
            if (_selectedDate != null) ...[
              NeumorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horarios disponibles',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTimes
                          .map((time) => GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTime = time),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: _selectedTime == time
                                        ? TallerAlexColors.primaryGradient
                                        : null,
                                    color: _selectedTime == time
                                        ? null
                                        : TallerAlexColors.neumorphicBase,
                                    borderRadius: BorderRadius.circular(20),
                                    border: _selectedTime == time
                                        ? null
                                        : Border.all(
                                            color: TallerAlexColors.textLight
                                                .withOpacity(0.3),
                                          ),
                                  ),
                                  child: Text(
                                    time,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedTime == time
                                          ? Colors.white
                                          : TallerAlexColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notas adicionales
              NeumorphicCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas adicionales (opcional)',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    NeumorphicContainer(
                      depth: -2,
                      borderRadius: 12,
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        style: GoogleFonts.poppins(
                          color: TallerAlexColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Describe algún problema específico o solicitud especial...',
                          hintStyle: GoogleFonts.poppins(
                            color: TallerAlexColors.textLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cupón de descuento
              Consumer<CuponesProvider>(
                builder: (context, cuponesProvider, child) {
                  final serviciosSeleccionados = _services
                      .where((s) => s['selected'])
                      .map((s) => s['name'] as String)
                      .toList();

                  final cuponesAplicables = cuponesProvider
                      .getCuponesAplicables(serviciosSeleccionados);

                  return NeumorphicCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: TallerAlexColors.primaryFuchsia,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cupón de descuento (opcional)',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Opciones de selección
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _useManualCoupon = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: !_useManualCoupon
                                            ? TallerAlexColors.primaryFuchsia
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Mis cupones',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: !_useManualCoupon
                                          ? TallerAlexColors.primaryFuchsia
                                          : TallerAlexColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _useManualCoupon = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _useManualCoupon
                                            ? TallerAlexColors.primaryFuchsia
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Código manual',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: _useManualCoupon
                                          ? TallerAlexColors.primaryFuchsia
                                          : TallerAlexColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Contenido según la selección
                        if (!_useManualCoupon) ...[
                          // Selector de cupones del wallet
                          if (cuponesAplicables.isNotEmpty) ...[
                            Text(
                              'Selecciona un cupón:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...cuponesAplicables
                                .map((cupon) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedCoupon = cupon;
                                            _couponController.text =
                                                cupon['codigo'];
                                          });
                                        },
                                        child: NeumorphicContainer(
                                          depth: _selectedCoupon?['id'] ==
                                                  cupon['id']
                                              ? -2
                                              : 2,
                                          borderRadius: 12,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: _selectedCoupon?[
                                                          'id'] ==
                                                      cupon['id']
                                                  ? LinearGradient(
                                                      colors: [
                                                        TallerAlexColors
                                                            .primaryFuchsia
                                                            .withOpacity(0.1),
                                                        TallerAlexColors
                                                            .lightRose
                                                            .withOpacity(0.1),
                                                      ],
                                                    )
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    gradient: TallerAlexColors
                                                        .primaryGradient,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.local_offer,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        cupon['titulo'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              TallerAlexColors
                                                                  .textPrimary,
                                                        ),
                                                      ),
                                                      Text(
                                                        cupon['descripcion'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: TallerAlexColors
                                                              .textSecondary,
                                                        ),
                                                      ),
                                                      Text(
                                                        cupon['tipo'] ==
                                                                'porcentaje'
                                                            ? '${cupon['descuento']}% OFF'
                                                            : '\$${cupon['descuento']} OFF',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: TallerAlexColors
                                                              .primaryFuchsia,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_selectedCoupon?['id'] ==
                                                    cupon['id'])
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: TallerAlexColors
                                                        .primaryFuchsia,
                                                    size: 20,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    TallerAlexColors.textLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: TallerAlexColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No tienes cupones disponibles para los servicios seleccionados.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: TallerAlexColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          // Campo manual de cupón
                          Row(
                            children: [
                              Expanded(
                                child: NeumorphicContainer(
                                  depth: -2,
                                  borderRadius: 12,
                                  child: TextField(
                                    controller: _couponController,
                                    style: GoogleFonts.poppins(
                                      color: TallerAlexColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Ingresa tu código de cupón',
                                      hintStyle: GoogleFonts.poppins(
                                        color: TallerAlexColors.textLight,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCoupon = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              NeumorphicButton(
                                onPressed: () {
                                  // TODO: Validar cupón manual
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Cupón validado: ${_couponController.text}'),
                                      backgroundColor:
                                          TallerAlexColors.primaryFuchsia,
                                    ),
                                  );
                                },
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: Text(
                                  'Aplicar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: TallerAlexColors.primaryFuchsia,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmation() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmar cita',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisa los detalles antes de confirmar tu cita',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: TallerAlexColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Resumen de la cita
            NeumorphicCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationSection(
                    'Vehículo',
                    _selectedVehicle != null
                        ? '${_selectedVehicle!['brand']} ${_selectedVehicle!['model']} ${_selectedVehicle!['year']} - ${_selectedVehicle!['plate']}'
                        : 'No seleccionado',
                    Icons.directions_car,
                  ),
                  const SizedBox(height: 20),
                  _buildConfirmationSection(
                    'Sucursal',
                    _selectedBranch?['name'] ?? 'No seleccionada',
                    Icons.location_on,
                  ),
                  const SizedBox(height: 20),
                  _buildConfirmationSection(
                    'Servicios',
                    _services
                            .where((s) => s['selected'])
                            .map((s) => s['name'])
                            .join(', ')
                            .isEmpty
                        ? 'Ningún servicio seleccionado'
                        : _services
                            .where((s) => s['selected'])
                            .map((s) => s['name'])
                            .join(', '),
                    Icons.build,
                  ),
                  const SizedBox(height: 20),
                  _buildConfirmationSection(
                    'Fecha y hora',
                    _selectedDate != null && _selectedTime != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} a las $_selectedTime'
                        : 'No seleccionada',
                    Icons.schedule,
                  ),
                  if (_notesController.text.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildConfirmationSection(
                      'Notas',
                      _notesController.text,
                      Icons.note,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Total
            if (_services.any((service) => service['selected']))
              NeumorphicCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total estimado:',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${_services.where((s) => s['selected']).fold(0.0, (sum, s) => sum + s['price']).toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.primaryFuchsia,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationSection(
      String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: TallerAlexColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
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
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  VoidCallback? _getNextButtonAction() {
    if (_isProcessing) return null;

    switch (_currentStep) {
      case 0:
        return _selectedVehicle != null ? () => _goToStep(1) : null;
      case 1:
        return _selectedBranch != null ? () => _goToStep(2) : null;
      case 2:
        return _services.any((service) => service['selected'])
            ? () => _goToStep(3)
            : null;
      case 3:
        return _selectedDate != null && _selectedTime != null
            ? () => _goToStep(4)
            : null;
      case 4:
        return _confirmAppointment;
      default:
        return null;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 4:
        return 'Confirmar Cita';
      default:
        return 'Siguiente';
    }
  }

  Future<void> _confirmAppointment() async {
    setState(() => _isProcessing = true);

    try {
      // Configurar callback de notificaciones
      final citasProvider = Provider.of<CitasProvider>(context, listen: false);
      final notificacionesProvider =
          Provider.of<NotificacionesProvider>(context, listen: false);

      citasProvider.configurarNotificaciones(
        notificacionesProvider.agregarNotificacionCitaCreada,
      );

      final serviciosSeleccionados =
          _services.where((s) => s['selected']).toList();

      citasProvider.agregarCita(
        vehiculo: _selectedVehicle!,
        sucursal: _selectedBranch!,
        servicios: serviciosSeleccionados,
        fecha: _selectedDate!,
        hora: _selectedTime!,
        notas: _notesController.text,
        cupon: _couponController.text,
      );

      // Simular proceso de confirmación
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Mostrar mensaje de éxito
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: TallerAlexColors.neumorphicBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: TallerAlexColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Cita confirmada!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu cita ha sido agendada exitosamente. Recibirás una notificación de confirmación.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              NeumorphicButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/dashboard');
                },
                backgroundColor: TallerAlexColors.primaryFuchsia,
                child: Text(
                  'Ir al Dashboard',
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
    } catch (e) {
      // Manejar error
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
