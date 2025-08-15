import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/widgets/common/custom_app_bar.dart';
import 'package:nethive_neo/models/nethive/categoria_componente_model.dart';
import 'package:nethive_neo/helpers/globals.dart';

class CrearComponentePage extends StatefulWidget {
  final String? rfidCode;

  const CrearComponentePage({
    super.key,
    this.rfidCode,
  });

  @override
  State<CrearComponentePage> createState() => _CrearComponentePageState();
}

class _CrearComponentePageState extends State<CrearComponentePage> {
  List<CategoriaComponente> _categorias = [];
  CategoriaComponente? _categoriaSeleccionada;
  bool _cargandoCategorias = true;
  String? _errorCategorias;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _rfidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rfidController.text = widget.rfidCode ?? '';
    _cargarCategorias();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    try {
      setState(() {
        _cargandoCategorias = true;
        _errorCategorias = null;
      });

      final response = await supabaseLU
          .from('categoria_componente')
          .select('*')
          .order('nombre');

      final categorias = (response as List)
          .map((cat) => CategoriaComponente.fromMap(cat))
          .toList();

      setState(() {
        _categorias = categorias;
        _cargandoCategorias = false;
      });
    } catch (e) {
      setState(() {
        _errorCategorias = 'Error al cargar categorías: $e';
        _cargandoCategorias = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Crear Componente',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del RFID
              if (widget.rfidCode != null) ...[
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.qr_code,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RFID Escaneado',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.rfidCode!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Selección de categoría
              Text(
                'Categoría del Componente',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCategoriaSelector(),
              const SizedBox(height: 24),

              // Formulario básico
              if (_categoriaSeleccionada != null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildFormularioDatos(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _categoriaSeleccionada != null
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _guardarComponente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Crear Componente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCategoriaSelector() {
    if (_cargandoCategorias) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_errorCategorias != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.error,
                color: Colors.red.shade700,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                _errorCategorias!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _cargarCategorias,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ..._categorias.map((categoria) {
          final isSelected = _categoriaSeleccionada?.id == categoria.id;
          return Card(
            elevation: isSelected ? 4 : 1,
            color: isSelected ? Colors.blue.shade50 : null,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoria.colorCategoria != null
                      ? Color(int.parse(
                          categoria.colorCategoria!.replaceFirst('#', '0xFF')))
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconoCategoria(categoria.nombre),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                categoria.nombre,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade700 : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle,
                      color: Colors.blue.shade700,
                    )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                setState(() {
                  _categoriaSeleccionada = categoria;
                });
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFormularioDatos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos del ${_categoriaSeleccionada!.nombre}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Campos básicos
        TextFormField(
          controller: _nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Componente *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.inventory),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _rfidController,
          decoration: const InputDecoration(
            labelText: 'Código RFID *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.qr_code),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El código RFID es obligatorio';
            }
            return null;
          },
          readOnly: widget.rfidCode != null,
        ),
        const SizedBox(height: 24),

        // Campos específicos por categoría
        _buildCamposEspecificos(),
      ],
    );
  }

  Widget _buildCamposEspecificos() {
    final categoria = _categoriaSeleccionada!.nombre.toLowerCase();

    switch (categoria) {
      case 'cable':
        return _buildCamposCable();
      case 'switch':
        return _buildCamposSwitch();
      case 'patch panel':
        return _buildCamposPatchPanel();
      case 'rack':
        return _buildCamposRack();
      case 'ups':
        return _buildCamposUPS();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCamposCable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especificaciones del Cable',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 12),

        // Aquí irían los campos específicos para cables
        // según la tabla detalle_cable de Supabase
        const Text('Campos específicos para cables en desarrollo...'),
      ],
    );
  }

  Widget _buildCamposSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especificaciones del Switch',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 12),
        const Text('Campos específicos para switches en desarrollo...'),
      ],
    );
  }

  Widget _buildCamposPatchPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especificaciones del Patch Panel',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 12),
        const Text('Campos específicos para patch panels en desarrollo...'),
      ],
    );
  }

  Widget _buildCamposRack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especificaciones del Rack',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 12),
        const Text('Campos específicos para racks en desarrollo...'),
      ],
    );
  }

  Widget _buildCamposUPS() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Especificaciones del UPS',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 12),
        const Text('Campos específicos para UPS en desarrollo...'),
      ],
    );
  }

  IconData _getIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'cable':
        return Icons.cable;
      case 'switch':
        return Icons.router;
      case 'patch panel':
        return Icons.dashboard;
      case 'rack':
        return Icons.storage;
      case 'ups':
        return Icons.battery_charging_full;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> _guardarComponente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Por ahora solo mostramos un mensaje de éxito
      // Aquí se implementaría la lógica para guardar en Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Componente "${_nombreController.text}" creado exitosamente',
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // Navegar a la vista del componente
              },
            ),
          ),
        );

        // Regresar a la pantalla anterior
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar indicador de carga

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear componente: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
