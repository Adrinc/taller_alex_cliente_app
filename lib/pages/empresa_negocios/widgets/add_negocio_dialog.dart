import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class AddNegocioDialog extends StatefulWidget {
  final EmpresasNegociosProvider provider;
  final String empresaId;

  const AddNegocioDialog({
    super.key,
    required this.provider,
    required this.empresaId,
  });

  @override
  State<AddNegocioDialog> createState() => _AddNegocioDialogState();
}

class _AddNegocioDialogState extends State<AddNegocioDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _tipoLocalController = TextEditingController(text: 'Sucursal');

  bool _isLoading = false;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAnimationInitialized = false;

  final List<String> _tiposLocal = [
    'Sucursal',
    'Oficina Central',
    'Bodega',
    'Centro de Distribución',
    'Punto de Venta',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Escuchar cambios del provider
    widget.provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    if (mounted) {
      setState(() {
        // Forzar rebuild cuando cambie el provider
      });
    }
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Pequeño delay para asegurar que el widget esté completamente montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isAnimationInitialized = true;
        });
        _startAnimations();
      }
    });
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChanged);
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _tipoLocalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const SizedBox.shrink();
    }

    // Detectar el tamaño de pantalla
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    // Ajustar dimensiones según el tipo de pantalla
    final maxWidth = isDesktop ? 900.0 : (isTablet ? 750.0 : 650.0);
    final maxHeight = isDesktop ? 700.0 : 750.0;

    // Ajustar el padding del header según la pantalla
    final headerPadding = isDesktop
        ? const EdgeInsets.symmetric(vertical: 20, horizontal: 30)
        : const EdgeInsets.all(25);

    // Ajustar el tamaño del icono
    final iconSize = isDesktop ? 35.0 : 40.0;
    final titleSize = isDesktop ? 24.0 : 28.0;
    final subtitleSize = isDesktop ? 14.0 : 16.0;

    return AnimatedBuilder(
      animation:
          Listenable.merge([_scaleAnimation, _slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(isDesktop ? 40 : 20),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  minHeight: isDesktop ? 600 : 400,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.of(context).primaryBackground,
                          AppTheme.of(context).secondaryBackground,
                          AppTheme.of(context).tertiaryBackground,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout(
                            headerPadding, iconSize, titleSize, subtitleSize)
                        : _buildMobileLayout(
                            headerPadding, iconSize, titleSize, subtitleSize),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout(EdgeInsets headerPadding, double iconSize,
      double titleSize, double subtitleSize) {
    return Row(
      children: [
        // Header lateral compacto para desktop
        Container(
          width: 280,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.of(context).tertiaryColor,
                AppTheme.of(context).primaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.of(context).tertiaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: headerPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono compacto
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.store_mall_directory,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Título compacto
                  Text(
                    'Nueva Sucursal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Añadir una nueva ubicación a tu empresa',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Contenido principal del formulario
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Información de empresa compacta
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.of(context).tertiaryColor.withOpacity(0.1),
                          AppTheme.of(context).primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppTheme.of(context).tertiaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.of(context).tertiaryColor,
                                AppTheme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empresa',
                                style: TextStyle(
                                  color: AppTheme.of(context).secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.provider.empresaSeleccionada?.nombre ??
                                    "Empresa no seleccionada",
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Formulario en columnas para aprovechar el espacio
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Primera fila - Nombre y Tipo
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildCompactFormField(
                                  controller: _nombreController,
                                  label: 'Nombre de la sucursal',
                                  hint: 'Ej: Sucursal Centro',
                                  icon: Icons.store,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El nombre es requerido';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCompactDropdown(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Segunda fila - Dirección
                          _buildCompactFormField(
                            controller: _direccionController,
                            label: 'Dirección',
                            hint: 'Dirección completa de la sucursal',
                            icon: Icons.location_on_outlined,
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La dirección es requerida';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Tercera fila - Coordenadas
                          Row(
                            children: [
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _latitudController,
                                  label: 'Latitud',
                                  hint: 'Ej: 19.4326',
                                  icon: Icons.location_searching,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Requerido';
                                    }
                                    final lat = double.tryParse(value);
                                    if (lat == null) {
                                      return 'Número inválido';
                                    }
                                    if (lat < -90 || lat > 90) {
                                      return 'Rango: -90 a 90';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildCompactFormField(
                                  controller: _longitudController,
                                  label: 'Longitud',
                                  hint: 'Ej: -99.1332',
                                  icon: Icons.location_searching,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Requerido';
                                    }
                                    final lng = double.tryParse(value);
                                    if (lng == null) {
                                      return 'Número inválido';
                                    }
                                    if (lng < -180 || lng > 180) {
                                      return 'Rango: -180 a 180';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Sección de archivos compacta
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  AppTheme.of(context)
                                      .tertiaryColor
                                      .withOpacity(0.1),
                                  AppTheme.of(context)
                                      .secondaryColor
                                      .withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header de la sección
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.of(context).primaryColor,
                                            AppTheme.of(context).tertiaryColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.of(context)
                                                .primaryColor
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.cloud_upload_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Archivos Opcionales',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.of(context)
                                                .primaryText,
                                          ),
                                        ),
                                        Text(
                                          'Logo e imagen de la sucursal',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Botones de archivos mejorados
                                _buildEnhancedFileButton(
                                  label: 'Logo de la sucursal',
                                  subtitle: 'Formato PNG, JPG (Max 2MB)',
                                  icon: Icons.image_rounded,
                                  fileName: widget.provider.logoFileName,
                                  file: widget.provider.logoToUpload,
                                  onPressed: widget.provider.selectLogo,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade600
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                _buildEnhancedFileButton(
                                  label: 'Imagen principal',
                                  subtitle:
                                      'Imagen representativa de la sucursal',
                                  icon: Icons.photo_library_rounded,
                                  fileName: widget.provider.imagenFileName,
                                  file: widget.provider.imagenToUpload,
                                  onPressed: widget.provider.selectImagen,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.shade400,
                                      Colors.purple.shade600
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Botones de acción
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.of(context)
                                          .secondaryText
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            widget.provider.resetFormData();
                                            Navigator.of(context).pop();
                                          },
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.of(context).tertiaryColor,
                                        AppTheme.of(context).primaryColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.of(context)
                                            .tertiaryColor
                                            .withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _crearNegocio,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_location,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Crear Sucursal',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(EdgeInsets headerPadding, double iconSize,
      double titleSize, double subtitleSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header para móvil (estructura original pero más compacto)
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            padding: headerPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.of(context).tertiaryColor,
                  AppTheme.of(context).primaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).tertiaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.store_mall_directory,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nueva Sucursal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Añadir nueva ubicación',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenido del formulario para móvil (estructura original)
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Información de la empresa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.of(context).tertiaryColor.withOpacity(0.1),
                          AppTheme.of(context).primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppTheme.of(context).tertiaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.of(context).tertiaryColor,
                                AppTheme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empresa',
                                style: TextStyle(
                                  color: AppTheme.of(context).secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.provider.empresaSeleccionada?.nombre ??
                                    "Empresa no seleccionada",
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campos del formulario
                  _buildCompactFormField(
                    controller: _nombreController,
                    label: 'Nombre de la sucursal',
                    hint: 'Ej: Sucursal Centro, Sede Norte',
                    icon: Icons.store,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),

                  _buildCompactFormField(
                    controller: _direccionController,
                    label: 'Dirección',
                    hint: 'Dirección completa de la sucursal',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La dirección es requerida';
                      }
                      return null;
                    },
                  ),

                  // Tipo de local
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: DropdownButtonFormField<String>(
                      value: _tipoLocalController.text,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 14,
                      ),
                      dropdownColor: AppTheme.of(context)
                          .secondaryBackground, // Fondo del dropdown
                      decoration: InputDecoration(
                        labelText: 'Tipo de local',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.of(context).tertiaryColor,
                                AppTheme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.category,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: AppTheme.of(context).tertiaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppTheme.of(context)
                            .secondaryBackground
                            .withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.of(context)
                                .tertiaryColor
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.of(context).tertiaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      items: _tiposLocal.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Container(
                            constraints: const BoxConstraints(
                                maxWidth:
                                    200), // Limitar ancho para evitar overflow
                            child: Text(
                              tipo,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.of(context).primaryText,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Truncar texto si es muy largo
                              maxLines: 1,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _tipoLocalController.text = newValue;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona un tipo';
                        }
                        return null;
                      },
                      isExpanded:
                          true, // Expandir para usar todo el ancho disponible
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.of(context).tertiaryColor,
                      ),
                    ),
                  ),

                  // Sección de coordenadas
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.of(context).tertiaryColor.withOpacity(0.1),
                          AppTheme.of(context).primaryColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppTheme.of(context).tertiaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.of(context)
                              .tertiaryColor
                              .withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.of(context).tertiaryColor,
                                    AppTheme.of(context).primaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_searching,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Coordenadas Geográficas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.of(context).primaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Latitud
                            Expanded(
                              child: TextFormField(
                                controller: _latitudController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*\.?\d*')),
                                ],
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Latitud',
                                  hintText: 'Ej: 19.4326',
                                  labelStyle: TextStyle(
                                    color: AppTheme.of(context).tertiaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context)
                                          .tertiaryColor
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).tertiaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  final lat = double.tryParse(value);
                                  if (lat == null) {
                                    return 'Número inválido';
                                  }
                                  if (lat < -90 || lat > 90) {
                                    return 'Rango: -90 a 90';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Longitud
                            Expanded(
                              child: TextFormField(
                                controller: _longitudController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^-?\d*\.?\d*')),
                                ],
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Longitud',
                                  hintText: 'Ej: -99.1332',
                                  labelStyle: TextStyle(
                                    color: AppTheme.of(context).tertiaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context)
                                          .tertiaryColor
                                          .withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppTheme.of(context).tertiaryColor,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Requerido';
                                  }
                                  final lng = double.tryParse(value);
                                  if (lng == null) {
                                    return 'Número inválido';
                                  }
                                  if (lng < -180 || lng > 180) {
                                    return 'Rango: -180 a 180';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue,
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Puedes obtener las coordenadas desde Google Maps',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sección de archivos compacta para móvil
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.of(context).primaryColor.withOpacity(0.1),
                          AppTheme.of(context).tertiaryColor.withOpacity(0.1),
                          AppTheme.of(context).secondaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.of(context)
                              .primaryColor
                              .withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de la sección
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.of(context).primaryColor,
                                    AppTheme.of(context).tertiaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.of(context)
                                        .primaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.cloud_upload_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Archivos Opcionales',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.of(context).primaryText,
                                  ),
                                ),
                                Text(
                                  'Logo e imagen de la sucursal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Botones de archivos mejorados
                        _buildEnhancedFileButton(
                          label: 'Logo de la sucursal',
                          subtitle: 'Formato PNG, JPG (Max 2MB)',
                          icon: Icons.image_rounded,
                          fileName: widget.provider.logoFileName,
                          file: widget.provider.logoToUpload,
                          onPressed: widget.provider.selectLogo,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildEnhancedFileButton(
                          label: 'Imagen principal',
                          subtitle: 'Imagen representativa de la sucursal',
                          icon: Icons.photo_library_rounded,
                          fileName: widget.provider.imagenFileName,
                          file: widget.provider.imagenToUpload,
                          onPressed: widget.provider.selectImagen,
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade400,
                              Colors.purple.shade600
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.of(context)
                                  .secondaryText
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    widget.provider.resetFormData();
                                    Navigator.of(context).pop();
                                  },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.of(context).tertiaryColor,
                                AppTheme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.of(context)
                                    .tertiaryColor
                                    .withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _crearNegocio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_location,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Crear Sucursal',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.of(context).tertiaryColor,
                  AppTheme.of(context).primaryColor,
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
          labelStyle: TextStyle(
            color: AppTheme.of(context).tertiaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppTheme.of(context).secondaryText,
            fontSize: 12,
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.of(context).tertiaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.of(context).tertiaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCompactDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _tipoLocalController.text,
        style: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontSize: 14,
        ),
        dropdownColor:
            AppTheme.of(context).secondaryBackground, // Fondo del dropdown
        decoration: InputDecoration(
          labelText: 'Tipo de local',
          prefixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.of(context).tertiaryColor,
                  AppTheme.of(context).primaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.category,
              color: Colors.white,
              size: 16,
            ),
          ),
          labelStyle: TextStyle(
            color: AppTheme.of(context).tertiaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.of(context).tertiaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.of(context).tertiaryColor,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _tiposLocal.map((String tipo) {
          return DropdownMenuItem<String>(
            value: tipo,
            child: Container(
              constraints: const BoxConstraints(
                  maxWidth: 200), // Limitar ancho para evitar overflow
              child: Text(
                tipo,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.of(context).primaryText,
                ),
                overflow:
                    TextOverflow.ellipsis, // Truncar texto si es muy largo
                maxLines: 1,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _tipoLocalController.text = newValue;
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecciona un tipo';
          }
          return null;
        },
        isExpanded: true, // Expandir para usar todo el ancho disponible
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppTheme.of(context).tertiaryColor,
        ),
      ),
    );
  }

  Widget _buildEnhancedFileButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required String? fileName,
    required dynamic file,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono con gradiente
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del archivo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileName ?? subtitle,
                        style: TextStyle(
                          color: fileName != null
                              ? AppTheme.of(context).primaryColor
                              : AppTheme.of(context).secondaryText,
                          fontSize: 13,
                          fontWeight: fileName != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Preview de imagen si existe
                if (file != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.provider.getImageWidget(
                        file,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.upload_file,
                      color: AppTheme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _crearNegocio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.provider.crearNegocio(
        empresaId: widget.empresaId,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        latitud: double.parse(_latitudController.text.trim()),
        longitud: double.parse(_longitudController.text.trim()),
        tipoLocal: _tipoLocalController.text.trim(),
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Sucursal creada exitosamente',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Error al crear la sucursal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
