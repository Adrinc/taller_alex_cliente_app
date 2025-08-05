import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';

class EditComponenteDialog extends StatefulWidget {
  final ComponentesProvider provider;
  final Componente componente;

  const EditComponenteDialog({
    super.key,
    required this.provider,
    required this.componente,
  });

  @override
  State<EditComponenteDialog> createState() => _EditComponenteDialogState();
}

class _EditComponenteDialogState extends State<EditComponenteDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _rfidController; // ← NUEVO controlador para RFID

  bool _isLoading = false;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isAnimationInitialized = false;

  // Variables del formulario
  late int _categoriaSeleccionada;
  late bool _activo;
  late bool _enUso;
  bool _actualizarImagen = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    // Escuchar cambios del provider
    widget.provider.addListener(_onProviderChanged);
  }

  void _initializeControllers() {
    _nombreController = TextEditingController(text: widget.componente.nombre);
    _descripcionController =
        TextEditingController(text: widget.componente.descripcion ?? '');
    _ubicacionController =
        TextEditingController(text: widget.componente.ubicacion ?? '');
    _rfidController = TextEditingController(text: widget.componente.rfid ?? ''); // ← NUEVO controlador

    _categoriaSeleccionada = widget.componente.categoriaId;
    _activo = widget.componente.activo;
    _enUso = widget.componente.enUso;
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
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _rfidController.dispose(); // ← NUEVO dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAnimationInitialized) {
      return const SizedBox.shrink();
    }

    // Detectar el tamaño de pantalla con mejor precisión
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;
    final isMobile = screenSize.width <= 768;

    // Ajustar dimensiones según el tipo de pantalla para mejor responsividad
    double maxWidth;
    double maxHeight;
    EdgeInsets insetPadding;

    if (isMobile) {
      // Configuración específica para smartphones
      maxWidth = screenSize.width * 0.95; // 95% del ancho de pantalla
      maxHeight = screenSize.height * 0.9; // 90% del alto de pantalla
      insetPadding = const EdgeInsets.all(10);
    } else if (isTablet) {
      // Configuración para tablets
      maxWidth = 750.0;
      maxHeight = 700.0;
      insetPadding = const EdgeInsets.all(20);
    } else {
      // Configuración para desktop
      maxWidth = 1000.0;
      maxHeight = 750.0;
      insetPadding = const EdgeInsets.all(40);
    }

    return AnimatedBuilder(
      animation:
          Listenable.merge([_scaleAnimation, _slideAnimation, _fadeAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: insetPadding,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: maxWidth,
                height: maxHeight,
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  minHeight: isMobile ? 400 : (isDesktop ? 650 : 500),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 60,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 30),
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
                        ? _buildDesktopLayout()
                        : _buildMobileLayout(isMobile),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    final categoria = widget.provider.getCategoriaById(_categoriaSeleccionada);

    return Row(
      children: [
        // Header lateral compacto para desktop
        Container(
          width: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.of(context).primaryColor,
                AppTheme.of(context).secondaryColor,
                AppTheme.of(context).tertiaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.of(context).primaryColor.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Imagen del componente
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.componente.imagenUrl != null &&
                              widget.componente.imagenUrl!.isNotEmpty
                          ? Image.network(
                              "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/componentes/${widget.componente.imagenUrl}",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Icon(
                                    Icons.devices,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Container(
                              padding: const EdgeInsets.all(20),
                              child: const Icon(
                                Icons.devices,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título compacto
                  const Text(
                    'Editar Componente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '📝 ${widget.componente.nombre}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info adicional
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Categoría: ${categoria?.nombre ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
                  // Formulario en columnas para aprovechar el espacio
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Primera fila - Nombre y Categoría
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildCompactFormField(
                                  controller: _nombreController,
                                  label: 'Nombre del componente',
                                  hint: 'Ej: Switch Core Principal',
                                  icon: Icons.devices_rounded,
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
                                child: _buildCategoriaDropdown(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Segunda fila - Ubicación
                          _buildCompactFormField(
                            controller: _ubicacionController,
                            label: 'Ubicación',
                            hint: 'Ej: MDF Principal - Rack 1',
                            icon: Icons.location_on_rounded,
                            validator: (value) {
                              // La ubicación es opcional
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Tercera fila - Descripción
                          _buildCompactFormField(
                            controller: _descripcionController,
                            label: 'Descripción',
                            hint: 'Descripción detallada del componente',
                            icon: Icons.description_rounded,
                            maxLines: 3,
                            validator: (value) {
                              // La descripción es opcional
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Cuarta fila - RFID (Nuevo campo)
                          _buildCompactFormField(
                            controller: _rfidController,
                            label: 'RFID',
                            hint: 'Ej: 123456789ABCDEF',
                            icon: Icons.nfc_rounded,
                            validator: (value) {
                              // El RFID es opcional, pero si se proporciona, debe tener un formato válido
                              if (value != null && value.trim().isNotEmpty) {
                                final rfidPattern = RegExp(r'^[0-9A-Fa-f]{1,16}$');
                                if (!rfidPattern.hasMatch(value.trim())) {
                                  return 'RFID inválido. Debe ser de 1 a 16 caracteres hexadecimales.';
                                }
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Switches de estado
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatusSwitch(
                                  'Activo',
                                  'El componente está operativo',
                                  _activo,
                                  (value) => setState(() => _activo = value),
                                  Icons.power_settings_new,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatusSwitch(
                                  'En Uso',
                                  'El componente está siendo utilizado',
                                  _enUso,
                                  (value) => setState(() => _enUso = value),
                                  Icons.trending_up,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Sección de imagen
                          _buildImageSection(),

                          const SizedBox(height: 25),

                          // Botones de acción
                          Row(
                            children: [
                              // Botón cancelar
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppTheme.of(context)
                                          .secondaryText
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
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
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.close_rounded,
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              // Botón guardar cambios
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.of(context).primaryColor,
                                        AppTheme.of(context).secondaryColor,
                                        AppTheme.of(context).tertiaryColor,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.of(context)
                                            .primaryColor
                                            .withOpacity(0.5),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _guardarCambios,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
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
                                                Icons.save_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Guardar Cambios',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
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

  Widget _buildMobileLayout(bool isMobile) {
    widget.provider.getCategoriaById(_categoriaSeleccionada);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header espectacular con animación
        SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.of(context).primaryColor,
                  AppTheme.of(context).secondaryColor,
                  AppTheme.of(context).tertiaryColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Imagen del componente
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: widget.componente.imagenUrl != null &&
                            widget.componente.imagenUrl!.isNotEmpty
                        ? Image.network(
                            "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/componentes/${widget.componente.imagenUrl}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                child: const Icon(
                                  Icons.devices,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              );
                            },
                          )
                        : Container(
                            padding: const EdgeInsets.all(20),
                            child: const Icon(
                              Icons.devices,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Título
                const Text(
                  'Editar Componente',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '📝 ${widget.componente.nombre}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenido del formulario
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campos del formulario
                  _buildCompactFormField(
                    controller: _nombreController,
                    label: 'Nombre del componente',
                    hint: 'Ej: Switch Core Principal',
                    icon: Icons.devices_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),

                  _buildCategoriaDropdown(),

                  _buildCompactFormField(
                    controller: _ubicacionController,
                    label: 'Ubicación',
                    hint: 'Ej: MDF Principal - Rack 1',
                    icon: Icons.location_on_rounded,
                  ),

                  _buildCompactFormField(
                    controller: _descripcionController,
                    label: 'Descripción',
                    hint: 'Descripción detallada del componente',
                    icon: Icons.description_rounded,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Campo RFID (nuevo)
                  _buildCompactFormField(
                    controller: _rfidController,
                    label: 'RFID',
                    hint: 'Ej: 123456789ABCDEF',
                    icon: Icons.nfc_rounded,
                    validator: (value) {
                      // El RFID es opcional, pero si se proporciona, debe tener un formato válido
                      if (value != null && value.trim().isNotEmpty) {
                        final rfidPattern = RegExp(r'^[0-9A-Fa-f]{1,16}$');
                        if (!rfidPattern.hasMatch(value.trim())) {
                          return 'RFID inválido. Debe ser de 1 a 16 caracteres hexadecimales.';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Switches de estado
                  _buildStatusSwitch(
                    'Activo',
                    'El componente está operativo',
                    _activo,
                    (value) => setState(() => _activo = value),
                    Icons.power_settings_new,
                    Colors.green,
                  ),

                  const SizedBox(height: 12),

                  _buildStatusSwitch(
                    'En Uso',
                    'El componente está siendo utilizado',
                    _enUso,
                    (value) => setState(() => _enUso = value),
                    Icons.trending_up,
                    Colors.orange,
                  ),

                  const SizedBox(height: 20),

                  // Sección de imagen
                  _buildImageSection(),

                  const SizedBox(height: 25),

                  // Botones de acción
                  Row(
                    children: [
                      // Botón cancelar
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppTheme.of(context)
                                  .secondaryText
                                  .withOpacity(0.4),
                              width: 2,
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: AppTheme.of(context).secondaryText,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: AppTheme.of(context).secondaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Botón guardar
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.of(context).primaryColor,
                                AppTheme.of(context).secondaryColor,
                                AppTheme.of(context).tertiaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _guardarCambios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Guardar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
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
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          labelStyle: TextStyle(
            color: AppTheme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: 12,
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: _categoriaSeleccionada,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _categoriaSeleccionada = value;
            });
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Seleccione una categoría';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Categoría',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.category_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          labelStyle: TextStyle(
            color: AppTheme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: widget.provider.categorias.map((categoria) {
          return DropdownMenuItem<int>(
            value: categoria.id,
            child: Text(
              categoria.nombre,
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
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
          color: AppTheme.of(context).primaryColor.withOpacity(0.4),
          width: 2,
        ),
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
                  gradient: AppTheme.of(context).primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.image_rounded,
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
                      'Imagen del Componente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.of(context).primaryText,
                      ),
                    ),
                    Text(
                      'Actualizar imagen (opcional)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botón para seleccionar imagen
          GestureDetector(
            onTap: () async {
              await widget.provider.selectImagen();
              setState(() {
                _actualizarImagen = widget.provider.imagenToUpload != null;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  width: 2,
                ),
                color: AppTheme.of(context).secondaryBackground,
              ),
              child: Column(
                children: [
                  // Preview de imagen
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.provider.imagenToUpload != null
                          ? widget.provider.getImageWidget(
                              widget.provider.imagenToUpload,
                              height: 80,
                              width: 80,
                            )
                          : widget.componente.imagenUrl != null &&
                                  widget.componente.imagenUrl!.isNotEmpty
                              ? Image.network(
                                  "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/componentes/${widget.componente.imagenUrl}",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Icon(
                                        Icons.devices,
                                        color:
                                            AppTheme.of(context).primaryColor,
                                        size: 24,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Icon(
                                    Icons.devices,
                                    color: AppTheme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Texto explicativo
                  Text(
                    widget.provider.imagenFileName ??
                        'Toca para seleccionar imagen',
                    style: TextStyle(
                      color: widget.provider.imagenFileName != null
                          ? AppTheme.of(context).primaryColor
                          : AppTheme.of(context).secondaryText,
                      fontSize: 14,
                      fontWeight: widget.provider.imagenFileName != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (widget.provider.imagenFileName == null)
                    Text(
                      'PNG, JPG (Max 2MB)',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.provider.actualizarComponente(
        componenteId: widget.componente.id,
        negocioId: widget.componente.negocioId,
        categoriaId: _categoriaSeleccionada,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        enUso: _enUso,
        activo: _activo,
        ubicacion: _ubicacionController.text.trim().isEmpty
            ? null
            : _ubicacionController.text.trim(),
        rfid: _rfidController.text.trim().isEmpty
            ? null
            : _rfidController.text.trim(), // ← NUEVO parámetro RFID
        actualizarImagen: _actualizarImagen,
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
                    'Componente actualizado exitosamente',
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
                    'Error al actualizar el componente',
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
