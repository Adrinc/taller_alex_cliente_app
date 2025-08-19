import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nethive_neo/providers/nethive/componente_creation_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class CrearComponentePage extends StatefulWidget {
  final String? rfidCode;
  final String? negocioId;

  const CrearComponentePage({
    super.key,
    this.rfidCode,
    this.negocioId,
  });

  @override
  State<CrearComponentePage> createState() => _CrearComponentePageState();
}

class _CrearComponentePageState extends State<CrearComponentePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController();

  // Controladores para campos específicos
  final Map<String, TextEditingController> _controllers = {};

  // Estado de imágenes
  final List<File> _imagenes = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Configurar el RFID y negocio si vienen como parámetros
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ComponenteCreationProvider>();
      if (widget.rfidCode != null) {
        provider.setRfidCode(widget.rfidCode!);
      }
      if (widget.negocioId != null) {
        provider.setNegocioId(widget.negocioId!);
      }
      provider.cargarCategorias();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();

    // Limpiar todos los controladores dinámicos
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryBackground,
              theme.secondaryBackground,
              theme.tertiaryBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<ComponenteCreationProvider>(
            builder: (context, provider, child) {
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Header personalizado
                    _buildHeader(theme, provider),

                    // Contenido principal
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del RFID
                            if (provider.rfidCode != null)
                              _buildRfidInfo(theme, provider),

                            // Selección de categoría
                            _buildCategoriaSection(theme, provider),

                            // Formulario de datos básicos
                            if (provider.categoriaSeleccionada != null) ...[
                              const SizedBox(height: 24),
                              _buildDatosBasicos(theme, provider),

                              const SizedBox(height: 24),
                              _buildCamposEspecificos(theme, provider),

                              const SizedBox(height: 24),
                              _buildSeccionImagenes(theme),

                              const SizedBox(
                                  height:
                                      100), // Espacio para el botón flotante
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: Consumer<ComponenteCreationProvider>(
        builder: (context, provider, child) {
          if (provider.categoriaSeleccionada == null)
            return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed:
                provider.isLoading ? null : () => _guardarComponente(provider),
            backgroundColor: theme.primaryColor,
            icon: provider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              provider.isLoading ? 'Guardando...' : 'Crear Componente',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(AppTheme theme, ComponenteCreationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Componente',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText,
                  ),
                ),
                if (provider.categoriaSeleccionada != null)
                  Text(
                    provider.categoriaSeleccionada!.nombre,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.secondaryText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRfidInfo(AppTheme theme, ComponenteCreationProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.secondaryColor.withOpacity(0.1)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RFID Escaneado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.rfidCode!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: theme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaSection(
      AppTheme theme, ComponenteCreationProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría del Componente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        if (provider.isLoadingCategorias)
          _buildLoadingCard(theme)
        else if (provider.error != null)
          _buildErrorCard(theme, provider)
        else
          _buildCategoriasList(theme, provider),
      ],
    );
  }

  Widget _buildLoadingCard(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: theme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Cargando categorías...',
              style: TextStyle(color: theme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(AppTheme theme, ComponenteCreationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error, color: Colors.red, size: 32),
          const SizedBox(height: 12),
          Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.cargarCategorias(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasList(
      AppTheme theme, ComponenteCreationProvider provider) {
    return Column(
      children: provider.categorias.map((categoria) {
        final isSelected = provider.categoriaSeleccionada?.id == categoria.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.1)
                : theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : theme.primaryColor.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoriaColor(categoria.nombre),
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.primaryColor : theme.primaryText,
                fontSize: 16,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: theme.primaryColor)
                : Icon(Icons.arrow_forward_ios,
                    size: 16, color: theme.secondaryText),
            onTap: () {
              provider.setCategoriaSeleccionada(categoria);
              _initializeControllers(categoria.nombre);
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatosBasicos(
      AppTheme theme, ComponenteCreationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Básica',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Campo Nombre
          _buildTextField(
            controller: _nombreController,
            label: 'Nombre del Componente *',
            icon: Icons.inventory,
            theme: theme,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
            onChanged: (value) => provider.setNombre(value),
          ),
          const SizedBox(height: 16),

          // Campo Descripción
          _buildTextField(
            controller: _descripcionController,
            label: 'Descripción',
            icon: Icons.description,
            theme: theme,
            maxLines: 3,
            onChanged: (value) => provider.setDescripcion(value),
          ),
          const SizedBox(height: 16),

          // Campo Ubicación
          _buildTextField(
            controller: _ubicacionController,
            label: 'Ubicación',
            icon: Icons.location_on,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Campo RFID
          _buildTextField(
            controller: TextEditingController(text: provider.rfidCode ?? ''),
            label: 'Código RFID *',
            icon: Icons.qr_code,
            theme: theme,
            readOnly: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El código RFID es obligatorio';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppTheme theme,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: theme.secondaryBackground,
        labelStyle: TextStyle(color: theme.secondaryText),
      ),
      style: TextStyle(color: theme.primaryText),
      maxLines: maxLines,
      readOnly: readOnly,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildCamposEspecificos(
      AppTheme theme, ComponenteCreationProvider provider) {
    final categoria = provider.categoriaSeleccionada!.nombre.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Especificaciones de ${provider.categoriaSeleccionada!.nombre}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Campos dinámicos basados en la categoría
          ..._buildCamposPorCategoria(categoria, theme, provider),
        ],
      ),
    );
  }

  List<Widget> _buildCamposPorCategoria(
      String categoria, AppTheme theme, ComponenteCreationProvider provider) {
    switch (categoria) {
      case 'cable':
        return _buildCamposCable(theme, provider);
      case 'switch':
        return _buildCamposSwitch(theme, provider);
      case 'patch panel':
        return _buildCamposPatchPanel(theme, provider);
      case 'rack':
        return _buildCamposRack(theme, provider);
      case 'ups':
        return _buildCamposUPS(theme, provider);
      case 'router':
      case 'firewall':
        return _buildCamposRouterFirewall(theme, provider);
      default:
        return _buildCamposEquipoActivo(theme, provider);
    }
  }

  List<Widget> _buildCamposCable(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField(
          'tipo_cable', 'Tipo de Cable', Icons.cable, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('color', 'Color', Icons.palette, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'tamaño', 'Tamaño (metros)', Icons.straighten, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('tipo_conector', 'Tipo de Conector',
          Icons.settings_input_component, theme, provider),
    ];
  }

  List<Widget> _buildCamposSwitch(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'numero_serie', 'Número de Serie', Icons.qr_code, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'cantidad_puertos', 'Cantidad de Puertos', Icons.hub, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('velocidad_puertos', 'Velocidad de Puertos',
          Icons.speed, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('tipo_puertos', 'Tipo de Puertos',
          Icons.electrical_services, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'direccion_ip', 'Dirección IP', Icons.network_check, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'firmware', 'Firmware', Icons.system_update, theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField('administrable', 'Administrable', theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField('poe', 'PoE (Power over Ethernet)', theme, provider),
    ];
  }

  List<Widget> _buildCamposPatchPanel(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('tipo_conector', 'Tipo de Conector',
          Icons.electrical_services, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'numero_puertos', 'Número de Puertos', Icons.hub, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'categoria', 'Categoría', Icons.category, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'tipo_montaje', 'Tipo de Montaje', Icons.build, theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField(
          'numeracion_frontal', 'Numeración Frontal', theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField('panel_ciego', 'Panel Ciego', theme, provider),
    ];
  }

  List<Widget> _buildCamposRack(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'altura_u', 'Altura (U)', Icons.height, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('profundidad_cm', 'Profundidad (cm)',
          Icons.straighten, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'ancho_cm', 'Ancho (cm)', Icons.straighten, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('color', 'Color', Icons.palette, theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField(
          'ventilacion_integrada', 'Ventilación Integrada', theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField(
          'puertas_con_llave', 'Puertas con Llave', theme, provider),
      const SizedBox(height: 16),
      _buildSwitchField('ruedas', 'Ruedas', theme, provider),
    ];
  }

  List<Widget> _buildCamposUPS(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('voltaje_entrada', 'Voltaje de Entrada',
          Icons.electric_bolt, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('voltaje_salida', 'Voltaje de Salida',
          Icons.electric_bolt, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('capacidad_va', 'Capacidad (VA)',
          Icons.battery_charging_full, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('autonomia_minutos', 'Autonomía (minutos)',
          Icons.timer, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('cantidad_tomas', 'Cantidad de Tomas',
          Icons.electrical_services, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildSwitchField('rackeable', 'Rackeable', theme, provider),
    ];
  }

  List<Widget> _buildCamposRouterFirewall(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'numero_serie', 'Número de Serie', Icons.qr_code, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'interfaces', 'Interfaces', Icons.settings_ethernet, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('capacidad_routing_gbps',
          'Capacidad de Routing (Gbps)', Icons.speed, theme, provider,
          isNumeric: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'direccion_ip', 'Dirección IP', Icons.network_check, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'firmware', 'Firmware', Icons.system_update, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'licencias', 'Licencias', Icons.verified_user, theme, provider),
    ];
  }

  List<Widget> _buildCamposEquipoActivo(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'numero_serie', 'Número de Serie', Icons.qr_code, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('especificaciones', 'Especificaciones',
          Icons.description, theme, provider,
          maxLines: 3),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'direccion_ip', 'Dirección IP', Icons.network_check, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'firmware', 'Firmware', Icons.system_update, theme, provider),
    ];
  }

  Widget _buildDynamicTextField(
    String key,
    String label,
    IconData icon,
    AppTheme theme,
    ComponenteCreationProvider provider, {
    bool isNumeric = false,
    int maxLines = 1,
  }) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController();
    }

    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: theme.tertiaryBackground,
        labelStyle: TextStyle(color: theme.secondaryText),
      ),
      style: TextStyle(color: theme.primaryText),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      onChanged: (value) {
        provider.setDetalleEspecifico(
            key, isNumeric ? (double.tryParse(value) ?? 0) : value);
      },
    );
  }

  Widget _buildSwitchField(String key, String label, AppTheme theme,
      ComponenteCreationProvider provider) {
    bool currentValue = provider.detallesEspecificos[key] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: theme.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: currentValue,
            onChanged: (value) {
              provider.setDetalleEspecifico(key, value);
              setState(() {}); // Para actualizar la UI del switch
            },
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionImagenes(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fotos del Componente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 16),

          // Botones de cámara y galería
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tomarFoto(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _tomarFoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid de imágenes
          if (_imagenes.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imagenes.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_imagenes[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _imagenes.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.tertiaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  'No hay fotos seleccionadas',
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _initializeControllers(String categoria) {
    // Limpiar controladores existentes
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  Future<void> _tomarFoto(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenes.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al tomar la foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'cable':
        return Colors.orange;
      case 'switch':
        return Colors.blue;
      case 'patch panel':
        return Colors.purple;
      case 'rack':
        return Colors.green;
      case 'ups':
        return Colors.red;
      case 'router':
        return Colors.teal;
      case 'firewall':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'cable':
        return Icons.cable;
      case 'switch':
        return Icons.hub;
      case 'patch panel':
        return Icons.dashboard;
      case 'rack':
        return Icons.storage;
      case 'ups':
        return Icons.battery_charging_full;
      case 'router':
        return Icons.router;
      case 'firewall':
        return Icons.security;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> _guardarComponente(ComponenteCreationProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Actualizar datos del provider
    provider.setNombre(_nombreController.text);
    provider.setDescripcion(_descripcionController.text);

    try {
      final success = await provider.crearComponente();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Componente "${_nombreController.text}" creado exitosamente'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navegar a la vista del componente
              },
            ),
          ),
        );

        // Limpiar el provider y regresar
        provider.reset();
        context.pop();
      } else if (provider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
