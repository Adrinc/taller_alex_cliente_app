import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/services/api_error_handler.dart';

class MisVehiculosPage extends StatefulWidget {
  const MisVehiculosPage({super.key});

  @override
  State<MisVehiculosPage> createState() => _MisVehiculosPageState();
}

class _MisVehiculosPageState extends State<MisVehiculosPage> {
  // Datos de demo - en producción vendrían de la base de datos
  List<Map<String, dynamic>> _vehicles = [
    {
      'id': 1,
      'brand': 'Honda',
      'model': 'Civic',
      'year': 2020,
      'plate': 'ABC-123',
      'color': 'Blanco',
      'vin': '1HGBH41JXMN109186',
      'fuelType': 'Gasolina',
      'image': null,
      'services': 8,
      'lastService': '15 Sep 2024',
    },
    {
      'id': 2,
      'brand': 'Toyota',
      'model': 'Corolla',
      'year': 2019,
      'plate': 'XYZ-789',
      'color': 'Azul',
      'vin': '5Y2SL62823Z411565',
      'fuelType': 'Gasolina',
      'image': null,
      'services': 12,
      'lastService': '28 Ago 2024',
    },
  ];

  bool _isLoading = false;

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
                          'Mis Vehículos',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.textPrimary,
                          ),
                        ),
                      ),
                      NeumorphicButton(
                        onPressed: () => _showAddVehicleModal(),
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        backgroundColor: TallerAlexColors.primaryFuchsia,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Lista de vehículos
              Expanded(
                child: _vehicles.isEmpty
                    ? _buildEmptyState()
                    : FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _vehicles[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: _buildVehicleCard(vehicle, index),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                  Icons.directions_car,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No tienes vehículos registrados',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agrega tu primer vehículo para comenzar a gestionar sus servicios',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              NeumorphicButton(
                onPressed: () => _showAddVehicleModal(),
                backgroundColor: TallerAlexColors.primaryFuchsia,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Agregar Vehículo',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, int index) {
    return SlideInLeft(
      duration: Duration(milliseconds: 800 + (index * 100)),
      child: NeumorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del vehículo con foto
            Row(
              children: [
                // Imagen del vehículo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: TallerAlexColors.neumorphicBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: vehicle['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(vehicle['image']),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.directions_car,
                          size: 40,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                ),
                const SizedBox(width: 16),
                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle['brand']} ${vehicle['model']}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TallerAlexColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Año ${vehicle['year']} • ${vehicle['color']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: TallerAlexColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vehicle['plate'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menú de opciones
                PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: TallerAlexColors.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              color: TallerAlexColors.primaryFuchsia),
                          const SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditVehicleModal(vehicle);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(vehicle);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información detallada
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'VIN',
                    vehicle['vin'],
                    Icons.fingerprint,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    'Combustible',
                    vehicle['fuelType'],
                    Icons.local_gas_station,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Estadísticas de servicios
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TallerAlexColors.lightRose.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${vehicle['services']}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.primaryFuchsia,
                          ),
                        ),
                        Text(
                          'Servicios',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: TallerAlexColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: TallerAlexColors.textLight.withOpacity(0.3),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          vehicle['lastService'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TallerAlexColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Último servicio',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: TallerAlexColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () => context.go('/agendar-cita'),
                    backgroundColor: TallerAlexColors.primaryFuchsia,
                    child: Text(
                      'Agendar Cita',
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
                    onPressed: () => context.go('/historial'),
                    child: Text(
                      'Ver Historial',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: TallerAlexColors.primaryFuchsia,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: TallerAlexColors.textLight,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TallerAlexColors.textLight,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddVehicleModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VehicleFormModal(
        onSave: (vehicleData) {
          setState(() {
            _vehicles.add({
              'id': _vehicles.length + 1,
              ...vehicleData,
              'services': 0,
              'lastService': 'Sin servicios',
            });
          });
        },
      ),
    );
  }

  void _showEditVehicleModal(Map<String, dynamic> vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VehicleFormModal(
        vehicle: vehicle,
        onSave: (vehicleData) {
          setState(() {
            final index = _vehicles.indexWhere((v) => v['id'] == vehicle['id']);
            if (index != -1) {
              _vehicles[index] = {
                ...vehicle,
                ...vehicleData,
              };
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Eliminar vehículo',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${vehicle['brand']} ${vehicle['model']} ${vehicle['plate']}?',
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
              setState(() {
                _vehicles.removeWhere((v) => v['id'] == vehicle['id']);
              });
              Navigator.of(context).pop();
              ApiErrorHandler.callToast('Vehículo eliminado');
            },
            backgroundColor: Colors.red,
            child: Text(
              'Eliminar',
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
}

class _VehicleFormModal extends StatefulWidget {
  final Map<String, dynamic>? vehicle;
  final Function(Map<String, dynamic>) onSave;

  const _VehicleFormModal({
    this.vehicle,
    required this.onSave,
  });

  @override
  State<_VehicleFormModal> createState() => _VehicleFormModalState();
}

class _VehicleFormModalState extends State<_VehicleFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _vinController = TextEditingController();

  String _selectedFuelType = 'Gasolina';
  File? _vehicleImage;
  bool _isLoading = false;

  final List<String> _fuelTypes = [
    'Gasolina',
    'Diésel',
    'Híbrido',
    'Eléctrico',
    'Gas LP',
    'Gas Natural',
  ];

  final List<String> _brands = [
    'Toyota',
    'Honda',
    'Nissan',
    'Ford',
    'Chevrolet',
    'Volkswagen',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Lexus',
    'Infiniti',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _brandController.text = widget.vehicle!['brand'];
      _modelController.text = widget.vehicle!['model'];
      _yearController.text = widget.vehicle!['year'].toString();
      _plateController.text = widget.vehicle!['plate'];
      _colorController.text = widget.vehicle!['color'];
      _vinController.text = widget.vehicle!['vin'];
      _selectedFuelType = widget.vehicle!['fuelType'];
      if (widget.vehicle!['image'] != null) {
        _vehicleImage = File(widget.vehicle!['image']);
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    widget.vehicle != null
                        ? 'Editar Vehículo'
                        : 'Nuevo Vehículo',
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

            // Formulario
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Foto del vehículo
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: NeumorphicContainer(
                            width: 120,
                            height: 120,
                            borderRadius: 12,
                            depth: _vehicleImage != null ? -4 : 4,
                            child: _vehicleImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _vehicleImage!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: TallerAlexColors.primaryFuchsia,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Foto del vehículo (opcional)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Marca
                      _buildDropdownField(
                        'Marca',
                        _brandController.text.isEmpty
                            ? null
                            : _brandController.text,
                        _brands,
                        (value) {
                          setState(() {
                            _brandController.text = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La marca es requerida';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Modelo
                      _buildTextField(
                        'Modelo',
                        _modelController,
                        'Civic, Corolla, etc.',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El modelo es requerido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Año y Color
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Año',
                              _yearController,
                              '2020',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El año es requerido';
                                }
                                final year = int.tryParse(value);
                                if (year == null ||
                                    year < 1900 ||
                                    year > DateTime.now().year + 1) {
                                  return 'Año inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Color',
                              _colorController,
                              'Blanco',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'El color es requerido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Placas
                      _buildTextField(
                        'Placas',
                        _plateController,
                        'ABC-123',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Las placas son requeridas';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // VIN
                      _buildTextField(
                        'VIN (Número de serie)',
                        _vinController,
                        '1HGBH41JXMN109186',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El VIN es requerido';
                          }
                          if (value.length != 17) {
                            return 'El VIN debe tener 17 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Tipo de combustible
                      _buildDropdownField(
                        'Tipo de combustible',
                        _selectedFuelType,
                        _fuelTypes,
                        (value) {
                          setState(() {
                            _selectedFuelType = value ?? 'Gasolina';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: _isLoading ? null : _saveVehicle,
                    backgroundColor: TallerAlexColors.primaryFuchsia,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Guardar',
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
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hintText, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        NeumorphicContainer(
          depth: -2,
          borderRadius: 12,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: GoogleFonts.poppins(
              color: TallerAlexColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: TallerAlexColors.textLight,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        NeumorphicContainer(
          depth: -2,
          borderRadius: 12,
          child: DropdownButtonFormField<String>(
            value: value,
            validator: validator,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                          color: TallerAlexColors.textPrimary,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _vehicleImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      await ApiErrorHandler.callToast('Error al seleccionar imagen');
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simular guardado
      await Future.delayed(const Duration(seconds: 1));

      final vehicleData = {
        'brand': _brandController.text,
        'model': _modelController.text,
        'year': int.parse(_yearController.text),
        'plate': _plateController.text.toUpperCase(),
        'color': _colorController.text,
        'vin': _vinController.text.toUpperCase(),
        'fuelType': _selectedFuelType,
        'image': _vehicleImage?.path,
      };

      widget.onSave(vehicleData);

      if (!mounted) return;

      Navigator.of(context).pop();
      await ApiErrorHandler.callToast(widget.vehicle != null
          ? 'Vehículo actualizado correctamente'
          : 'Vehículo agregado correctamente');
    } catch (e) {
      await ApiErrorHandler.callToast('Error al guardar vehículo');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
