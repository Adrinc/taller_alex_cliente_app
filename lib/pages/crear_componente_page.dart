import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nethive_neo/providers/nethive/componente_creation_provider.dart';
import 'package:nethive_neo/providers/nethive/distribuciones_provider.dart';
import 'package:nethive_neo/models/nethive/distribucion_model.dart';
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

  // Variables para distribución
  Distribucion? _distribucionSeleccionada;
  bool _isLoadingDistribuciones = false;

  // Variables para navegación por pasos
  int _currentStep = 0;
  PageController _pageController = PageController();

  // Pasos del formulario
  static const int STEP_CATEGORIA = 0;
  static const int STEP_FORMULARIO = 1;

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
        _cargarDistribuciones(widget.negocioId!);
      }
      provider.cargarCategorias();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _pageController.dispose();

    // Limpiar todos los controladores dinámicos
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _cargarDistribuciones(String negocioId) async {
    print('DEBUG: Iniciando carga de distribuciones para negocio: $negocioId');
    setState(() => _isLoadingDistribuciones = true);

    try {
      final distribucionesProvider = context.read<DistribucionesProvider>();

      // Cargar tipos PRIMERO, luego distribuciones
      print('DEBUG: Cargando tipos de distribución...');
      await distribucionesProvider.loadTiposDistribucion();
      print(
          'DEBUG: Tipos cargados: ${distribucionesProvider.tiposDistribucion.length}');

      print('DEBUG: Cargando distribuciones...');
      await distribucionesProvider.loadDistribucionesByNegocio(negocioId);
      print(
          'DEBUG: Distribuciones cargadas: ${distribucionesProvider.distribuciones.length}');
    } catch (e) {
      print('ERROR: Error cargando distribuciones: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar distribuciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        print('DEBUG: Finalizando carga de distribuciones');
        setState(() => _isLoadingDistribuciones = false);
      }
    }
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
              return Column(
                children: [
                  // Header con indicador de pasos
                  _buildStepHeader(theme, provider),

                  // Contenido principal con PageView
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics:
                          const NeverScrollableScrollPhysics(), // Deshabilitamos el swipe
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      children: [
                        // Paso 1: Selección de categoría
                        _buildCategoriaStep(theme, provider),

                        // Paso 2: Formulario completo
                        _buildFormularioStep(theme, provider),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Consumer<ComponenteCreationProvider>(
        builder: (context, provider, child) {
          return _buildFloatingActionButton(theme, provider);
        },
      ),
    );
  }

  Widget _buildStepHeader(AppTheme theme, ComponenteCreationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header principal con botón de retroceso
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _currentStep == STEP_CATEGORIA
                        ? Icons.arrow_back
                        : Icons.arrow_back,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    if (_currentStep == STEP_CATEGORIA) {
                      context.pop();
                    } else {
                      _previousStep();
                    }
                  },
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
                    Text(
                      _getStepTitle(),
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

          const SizedBox(height: 16),

          // RFID Info siempre visible
          if (provider.rfidCode != null) _buildRfidInfo(theme, provider),

          const SizedBox(height: 16),

          // Indicador de progreso
          _buildProgressIndicator(theme),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case STEP_CATEGORIA:
        return 'Seleccionar categoría del componente';
      case STEP_FORMULARIO:
        return 'Completar información del componente';
      default:
        return '';
    }
  }

  Widget _buildProgressIndicator(AppTheme theme) {
    return Row(
      children: [
        // Paso 1
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= STEP_CATEGORIA
                  ? theme.primaryColor
                  : theme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Paso 2
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= STEP_FORMULARIO
                  ? theme.primaryColor
                  : theme.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaStep(
      AppTheme theme, ComponenteCreationProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona la categoría del componente',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esto determinará qué información específica necesitaremos recopilar.',
            style: TextStyle(
              fontSize: 14,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          if (provider.isLoadingCategorias)
            _buildLoadingCard(theme)
          else if (provider.error != null)
            _buildErrorCard(theme, provider)
          else
            _buildCategoriasList(theme, provider),
        ],
      ),
    );
  }

  Widget _buildFormularioStep(
      AppTheme theme, ComponenteCreationProvider provider) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del ${provider.categoriaSeleccionada?.nombre ?? 'Componente'}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa todos los campos requeridos para registrar el componente.',
              style: TextStyle(
                fontSize: 14,
                color: theme.secondaryText,
              ),
            ),
            const SizedBox(height: 24),

            // Formulario completo
            _buildDatosBasicos(theme, provider),
            const SizedBox(height: 24),
            _buildSeccionDistribucion(theme, provider),
            const SizedBox(height: 24),
            _buildCamposEspecificos(theme, provider),
            const SizedBox(height: 24),
            _buildSeccionImagenes(theme),
            const SizedBox(height: 100), // Espacio para el botón flotante
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(
      AppTheme theme, ComponenteCreationProvider provider) {
    if (_currentStep == STEP_CATEGORIA) {
      // En el paso de categoría, mostrar botón de continuar
      if (provider.categoriaSeleccionada == null) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton.extended(
        onPressed: () => _nextStep(),
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.arrow_forward, color: Colors.white),
        label: const Text(
          'Continuar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // En el paso de formulario, mostrar botón de guardar
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
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < STEP_FORMULARIO) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > STEP_CATEGORIA) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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

              // Automáticamente avanzar al siguiente paso después de un pequeño delay
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _nextStep();
                }
              });
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-_/]')),
              LengthLimitingTextInputFormatter(100),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
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
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            onChanged: (value) => provider.setDescripcion(value),
          ),
          const SizedBox(height: 16),

          // Campo Ubicación
          _buildTextField(
            controller: _ubicacionController,
            label: 'Ubicación',
            icon: Icons.location_on,
            theme: theme,
            inputFormatters: [
              LengthLimitingTextInputFormatter(200),
            ],
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
                return 'El código RFID es requerido';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionDistribucion(
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
          Row(
            children: [
              Icon(
                Icons.account_tree,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona la distribución donde se ubicará este componente',
            style: TextStyle(
              fontSize: 12,
              color: theme.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          Consumer<DistribucionesProvider>(
            builder: (context, distribucionesProvider, child) {
              if (_isLoadingDistribuciones) {
                return _buildDistribucionLoading(theme);
              }

              if (distribucionesProvider.distribuciones.isEmpty) {
                return _buildDistribucionEmpty(theme, distribucionesProvider);
              }

              return _buildDistribucionSelector(theme, distribucionesProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDistribucionLoading(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.tertiaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cargando distribuciones...',
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistribucionEmpty(
      AppTheme theme, DistribucionesProvider distribucionesProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay distribuciones disponibles',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Necesitas crear al menos una distribución (MDF/IDF) antes de poder registrar componentes.',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                _showCreateDistribucionDialog(distribucionesProvider),
            icon: const Icon(Icons.add),
            label: const Text('Crear Distribución'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistribucionSelector(
      AppTheme theme, DistribucionesProvider distribucionesProvider) {
    print('DEBUG: Construyendo selector de distribuciones');
    print(
        'DEBUG: Distribuciones: ${distribucionesProvider.distribuciones.length}');
    print('DEBUG: Tipos: ${distribucionesProvider.tiposDistribucion.length}');

    // Verificar que tanto las distribuciones como los tipos estén cargados
    if (distribucionesProvider.distribuciones.isEmpty ||
        distribucionesProvider.tiposDistribucion.isEmpty) {
      print('DEBUG: Mostrando loading porque faltan datos');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.tertiaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            'Cargando distribuciones...',
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    print('DEBUG: Construyendo dropdown con datos completos');
    return Column(
      children: [
        // Dropdown para seleccionar distribución existente
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.tertiaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _distribucionSeleccionada == null
                  ? Colors.red.withOpacity(0.5)
                  : theme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonFormField<Distribucion>(
            value: _distribucionSeleccionada,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Seleccionar distribución',
            ),
            style: TextStyle(color: theme.primaryText),
            dropdownColor: theme.secondaryBackground,
            items: _buildSafeDropdownItems(distribucionesProvider, theme),
            onChanged: (Distribucion? value) {
              setState(() {
                _distribucionSeleccionada = value;
              });
              // Actualizar el provider inmediatamente
              if (value != null) {
                context
                    .read<ComponenteCreationProvider>()
                    .setDistribucionId(value.id);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Debe seleccionar una distribución';
              }
              return null;
            },
          ),
        ),

        const SizedBox(height: 12),

        // Botón para crear nueva distribución
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () =>
                _showCreateDistribucionDialog(distribucionesProvider),
            icon: Icon(Icons.add, color: theme.primaryColor),
            label: Text(
              'Crear nueva distribución',
              style: TextStyle(color: theme.primaryColor),
            ),
            style: TextButton.styleFrom(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<Distribucion>> _buildSafeDropdownItems(
      DistribucionesProvider distribucionesProvider, AppTheme theme) {
    try {
      return distribucionesProvider.distribuciones
          .where((distribucion) =>
              distribucion.nombre.isNotEmpty && distribucion.tipoId > 0)
          .map((distribucion) {
            try {
              final tipoNombre =
                  distribucionesProvider.getTipoNombre(distribucion.tipoId) ??
                      'Desconocido';
              Color chipColor = _getDistribucionColor(tipoNombre);

              return DropdownMenuItem<Distribucion>(
                value: distribucion,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tipoNombre,
                        style: TextStyle(
                          color: chipColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        distribucion.nombre,
                        style: TextStyle(color: theme.primaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            } catch (e) {
              print(
                  'ERROR: Error construyendo item para distribución ${distribucion.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<DropdownMenuItem<Distribucion>>()
          .toList();
    } catch (e) {
      print('ERROR: Error construyendo items del dropdown: $e');
      return [];
    }
  }

  Color _getDistribucionColor(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'MDF':
        return Colors.deepPurple;
      case 'IDF':
        return Colors.indigo;
      case 'RACK':
        return Colors.orange;
      case 'STANDALONE':
        return Colors.teal;
      default:
        return Colors.blueGrey;
    }
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
    bool isNumeric = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    List<TextInputFormatter> formatters = inputFormatters ?? [];

    // Si es numérico, agregar filtros para solo números
    if (isNumeric) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'^\..*')));
    }

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
      keyboardType: keyboardType ??
          (isNumeric ? TextInputType.number : TextInputType.text),
      inputFormatters: formatters,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildCamposEspecificos(
      AppTheme theme, ComponenteCreationProvider provider) {
    // Verificar que hay una categoría seleccionada
    if (provider.categoriaSeleccionada == null) {
      return const SizedBox.shrink();
    }

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
          'tipo_cable', 'Tipo de Cable', Icons.cable, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('color', 'Color', Icons.palette, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'tamaño', 'Tamaño (metros)', Icons.straighten, theme, provider,
          isNumeric: true, isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('tipo_conector', 'Tipo de Conector',
          Icons.settings_input_component, theme, provider),
    ];
  }

  List<Widget> _buildCamposSwitch(
      AppTheme theme, ComponenteCreationProvider provider) {
    return [
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'numero_serie', 'Número de Serie', Icons.qr_code, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'cantidad_puertos', 'Cantidad de Puertos', Icons.hub, theme, provider,
          isNumeric: true, isRequired: true),
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
          Icons.electrical_services, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'numero_puertos', 'Número de Puertos', Icons.hub, theme, provider,
          isNumeric: true, isRequired: true),
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
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'altura_u', 'Altura (U)', Icons.height, theme, provider,
          isNumeric: true, isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('profundidad_cm', 'Profundidad (cm)',
          Icons.straighten, theme, provider,
          isNumeric: true, isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField(
          'ancho_cm', 'Ancho (cm)', Icons.straighten, theme, provider,
          isNumeric: true, isRequired: true),
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
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('voltaje_entrada', 'Voltaje de Entrada',
          Icons.electric_bolt, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('voltaje_salida', 'Voltaje de Salida',
          Icons.electric_bolt, theme, provider),
      const SizedBox(height: 16),
      _buildDynamicTextField('capacidad_va', 'Capacidad (VA)',
          Icons.battery_charging_full, theme, provider,
          isNumeric: true, isRequired: true),
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
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider,
          isRequired: true),
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
      _buildDynamicTextField('tipo', 'Tipo', Icons.category, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('marca', 'Marca', Icons.business, theme, provider,
          isRequired: true),
      const SizedBox(height: 16),
      _buildDynamicTextField('modelo', 'Modelo', Icons.memory, theme, provider,
          isRequired: true),
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
    bool isRequired = false,
  }) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController();
    }

    List<TextInputFormatter> formatters = [];

    // Configurar validaciones específicas según el tipo de campo
    if (isNumeric) {
      // Solo permitir números y punto decimal
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
      // Evitar que empiece con punto
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'^\..*')));
      // Evitar múltiples puntos decimales
      formatters.add(TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text.split('.').length > 2) {
          return oldValue;
        }
        return newValue;
      }));
    } else if (key == 'direccion_ip') {
      // Formato específico para direcciones IP
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')));
      formatters.add(LengthLimitingTextInputFormatter(15));
    } else if (key == 'numero_serie' || key == 'firmware') {
      // Solo alfanuméricos para números de serie y firmware
      formatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.\-_]')));
    } else if (key == 'tipo_cable' ||
        key == 'color' ||
        key == 'marca' ||
        key == 'modelo') {
      // Solo letras, números y algunos caracteres especiales para campos de texto
      formatters
          .add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-_/]')));
    }

    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: theme.tertiaryBackground,
        labelStyle: TextStyle(color: theme.secondaryText),
      ),
      style: TextStyle(color: theme.primaryText),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      inputFormatters: formatters,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Este campo es requerido';
        }

        if (isNumeric && value != null && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue == null) {
            return 'Debe ser un número válido';
          }
          if (numValue <= 0) {
            return 'Debe ser un número mayor a 0';
          }
        }

        if (key == 'direccion_ip' && value != null && value.isNotEmpty) {
          if (!_isValidIP(value)) {
            return 'Dirección IP inválida (ej: 192.168.1.1)';
          }
        }

        return null;
      },
      onChanged: (value) {
        // Validación en tiempo real para números
        if (isNumeric && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue != null) {
            provider.setDetalleEspecifico(key, numValue);
          }
        } else {
          provider.setDetalleEspecifico(key, value);
        }
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

  bool _isValidIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (String part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
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

  void _showCreateDistribucionDialog(
      DistribucionesProvider distribucionesProvider) {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    int? selectedTipoId;

    // Cargar tipos de distribución si no están cargados
    if (distribucionesProvider.tiposDistribucion.isEmpty) {
      distribucionesProvider.loadTiposDistribucion();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nueva Distribución'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selector de tipo de distribución
              Consumer<DistribucionesProvider>(
                builder: (context, provider, child) {
                  if (provider.tiposDistribucion.isEmpty) {
                    return const CircularProgressIndicator();
                  }

                  return DropdownButtonFormField<int>(
                    value: selectedTipoId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Distribución',
                      border: OutlineInputBorder(),
                    ),
                    items: provider.tiposDistribucion
                        .map((tipo) => DropdownMenuItem(
                              value: tipo.id,
                              child: Text(tipo.nombre),
                            ))
                        .toList(),
                    onChanged: (value) => selectedTipoId = value,
                    validator: (value) =>
                        value == null ? 'Selecciona un tipo' : null,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Campo de nombre
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo de descripción
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate() && selectedTipoId != null) {
                final success = await distribucionesProvider.createDistribucion(
                  negocioId: widget.negocioId!,
                  tipoId: selectedTipoId!,
                  nombre: nombreController.text.trim(),
                  descripcion: descripcionController.text.trim().isEmpty
                      ? null
                      : descripcionController.text.trim(),
                );

                if (success && mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Distribución creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Actualizar la distribución seleccionada a la recién creada
                  if (distribucionesProvider.distribuciones.isNotEmpty) {
                    final nuevaDistribucion =
                        distribucionesProvider.distribuciones.last;
                    setState(() {
                      _distribucionSeleccionada = nuevaDistribucion;
                    });
                    // Actualizar también el provider
                    context
                        .read<ComponenteCreationProvider>()
                        .setDistribucionId(nuevaDistribucion.id);
                  }
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(distribucionesProvider.error ??
                          'Error al crear distribución'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarComponente(ComponenteCreationProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se haya seleccionado una distribución
    if (_distribucionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una distribución para el componente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Actualizar datos del provider
    provider.setNombre(_nombreController.text);
    provider.setDescripcion(_descripcionController.text);
    provider.setUbicacion(_ubicacionController.text);

    try {
      final success = await provider.crearComponente();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Componente "${_nombreController.text}" creado exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Limpiar el provider
        provider.reset();

        // Navegar de vuelta al home del técnico
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Navegar al home del técnico con el negocio actual
          if (widget.negocioId != null) {
            context.go('/home?negocioId=${widget.negocioId}');
          } else {
            context.go('/home');
          }
        }
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
