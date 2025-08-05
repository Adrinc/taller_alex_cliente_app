import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class AddComponenteDialog extends StatefulWidget {
  final ComponentesProvider provider;

  const AddComponenteDialog({
    super.key,
    required this.provider,
  });

  @override
  State<AddComponenteDialog> createState() => _AddComponenteDialogState();
}

class _AddComponenteDialogState extends State<AddComponenteDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _ubicacionController;
  late TextEditingController _rfidController; // ← NUEVO controlador para RFID

  bool _enUso = false;
  bool _activo = true;
  int? _categoriaSeleccionada;
  bool _isLoading = false;

  // Animaciones
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _descripcionController = TextEditingController();
    _ubicacionController = TextEditingController();
    _rfidController = TextEditingController(); // ← NUEVO controlador

    // Configurar animaciones
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _ubicacionController.dispose();
    _rfidController.dispose(); // ← NUEVO dispose
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isMobile = screenSize.width <= 768;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Container(
        width: isDesktop ? 900 : (isMobile ? screenSize.width * 0.95 : 700),
        height: isDesktop ? 650 : (isMobile ? screenSize.height * 0.9 : 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
            BoxShadow(
              color: AppTheme.of(context).primaryColor.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(isMobile),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Panel lateral izquierdo con diseño espectacular
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
                  // Icono principal del componente
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: widget.provider.imagenToUpload != null
                          ? Image.memory(
                              widget.provider.imagenToUpload!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón para seleccionar imagen
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await widget.provider.selectImagen();
                        setState(() {});
                      },
                      icon: const Icon(Icons.image, color: Colors.white),
                      label: Text(
                        widget.provider.imagenToUpload != null
                            ? 'Cambiar Imagen'
                            : 'Seleccionar Imagen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Título
                  const Text(
                    'Nuevo Componente',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Subtítulo
                  Text(
                    'Registra un nuevo componente\npara tu infraestructura',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Estados predeterminados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatusIndicator(
                        _activo ? 'Activo' : 'Inactivo',
                        _activo ? Icons.check_circle : Icons.cancel,
                        _activo ? Colors.green : Colors.red,
                      ),
                      _buildStatusIndicator(
                        _enUso ? 'En Uso' : 'Libre',
                        _enUso ? Icons.trending_up : Icons.trending_flat,
                        _enUso ? Colors.orange : Colors.grey,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info del negocio
                  if (widget.provider.negocioSeleccionadoNombre != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Negocio: ${widget.provider.negocioSeleccionadoNombre}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Panel principal con formulario
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del formulario
                Row(
                  children: [
                    Icon(
                      Icons.add_box_rounded,
                      color: AppTheme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Información del Componente',
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppTheme.of(context).secondaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Formulario
                Expanded(
                  child: Form(
                    key: _formKey,
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
                                  label: 'Nombre del Componente',
                                  hint: 'Ej: Switch Principal MDF',
                                  icon: Icons.devices_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'El nombre es obligatorio';
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

                          // Cuarta fila - RFID (nuevo campo)
                          _buildCompactFormField(
                            controller: _rfidController,
                            label: 'RFID',
                            hint: 'Ej: 123456789',
                            icon: Icons.radio,
                            validator: (value) {
                              // El RFID es opcional
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Switches de estado
                          Row(
                            children: [
                              Expanded(
                                child: _buildSwitchCard(
                                  title: 'Componente Activo',
                                  subtitle: 'El componente está operativo',
                                  value: _activo,
                                  onChanged: (value) {
                                    setState(() {
                                      _activo = value;
                                    });
                                  },
                                  icon: Icons.power_settings_new,
                                  activeColor: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildSwitchCard(
                                  title: 'En Uso',
                                  subtitle:
                                      'El componente está siendo utilizado',
                                  value: _enUso,
                                  onChanged: (value) {
                                    setState(() {
                                      _enUso = value;
                                    });
                                  },
                                  icon: Icons.work,
                                  activeColor: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Botones de acción
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.of(context).secondaryText,
                          side: BorderSide(
                            color: AppTheme.of(context)
                                .secondaryText
                                .withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.of(context).primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.of(context)
                                  .primaryColor
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _guardarComponente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save_rounded,
                                  color: Colors.white, size: 20),
                          label: Text(
                            _isLoading ? 'Guardando...' : 'Crear Componente',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
    );
  }

  Widget _buildMobileLayout(bool isMobile) {
    return Column(
      children: [
        // Header móvil
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nuevo Componente',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Imagen/selector móvil
                GestureDetector(
                  onTap: () async {
                    await widget.provider.selectImagen();
                    setState(() {});
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: widget.provider.imagenToUpload != null
                          ? Image.memory(
                              widget.provider.imagenToUpload!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(
                                Icons.add_photo_alternate,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.provider.imagenToUpload != null
                      ? 'Toca para cambiar imagen'
                      : 'Toca para añadir imagen',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenido del formulario para móvil
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Estados en móvil
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusIndicator(
                          _activo ? 'Activo' : 'Inactivo',
                          _activo ? Icons.check_circle : Icons.cancel,
                          _activo ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusIndicator(
                          _enUso ? 'En Uso' : 'Libre',
                          _enUso ? Icons.trending_up : Icons.trending_flat,
                          _enUso ? Colors.orange : Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Campos del formulario
                  _buildCompactFormField(
                    controller: _nombreController,
                    label: 'Nombre del Componente',
                    hint: 'Ej: Switch Principal MDF',
                    icon: Icons.devices_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildCategoriaDropdown(),

                  const SizedBox(height: 16),

                  _buildCompactFormField(
                    controller: _ubicacionController,
                    label: 'Ubicación',
                    hint: 'Ej: MDF Principal - Rack 1',
                    icon: Icons.location_on_rounded,
                  ),

                  const SizedBox(height: 16),

                  _buildCompactFormField(
                    controller: _descripcionController,
                    label: 'Descripción',
                    hint: 'Descripción detallada del componente',
                    icon: Icons.description_rounded,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 16),

                  // Campo RFID en móvil
                  _buildCompactFormField(
                    controller: _rfidController,
                    label: 'RFID',
                    hint: 'Ej: 123456789',
                    icon: Icons.radio,
                  ),

                  const SizedBox(height: 20),

                  // Switches en móvil
                  _buildSwitchCard(
                    title: 'Componente Activo',
                    subtitle: 'El componente está operativo',
                    value: _activo,
                    onChanged: (value) {
                      setState(() {
                        _activo = value;
                      });
                    },
                    icon: Icons.power_settings_new,
                    activeColor: Colors.green,
                  ),

                  const SizedBox(height: 12),

                  _buildSwitchCard(
                    title: 'En Uso',
                    subtitle: 'El componente está siendo utilizado',
                    value: _enUso,
                    onChanged: (value) {
                      setState(() {
                        _enUso = value;
                      });
                    },
                    icon: Icons.work,
                    activeColor: Colors.orange,
                  ),

                  const SizedBox(height: 30),

                  // Botones para móvil
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppTheme.of(context).primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.of(context)
                                  .primaryColor
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _guardarComponente,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.save_rounded,
                                  color: Colors.white, size: 20),
                          label: Text(
                            _isLoading ? 'Guardando...' : 'Crear Componente',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Cancelar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.of(context).secondaryText,
                            side: BorderSide(
                              color: AppTheme.of(context)
                                  .secondaryText
                                  .withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines ?? 1,
        style: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppTheme.of(context).secondaryText,
            fontSize: 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: 13,
          ),
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
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
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
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppTheme.of(context).secondaryBackground,
          shadowColor: AppTheme.of(context).primaryColor.withOpacity(0.3),
        ),
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
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontSize: 14,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: AppTheme.of(context).primaryColor,
          ),
          iconSize: 24,
          isExpanded: true, // Esto soluciona el overflow
          menuMaxHeight: 300,
          decoration: InputDecoration(
            labelText: 'Categoría',
            labelStyle: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.category_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: AppTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
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
          dropdownColor: AppTheme.of(context).secondaryBackground,
          items: widget.provider.categorias.map((categoria) {
            return DropdownMenuItem<int>(
              value: categoria.id,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        categoria.nombre,
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? activeColor.withOpacity(0.3)
              : AppTheme.of(context).primaryColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: value
                ? activeColor.withOpacity(0.1)
                : Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (value ? activeColor : Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? activeColor : Colors.grey,
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
                    fontSize: 14,
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
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarComponente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una categoría'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.provider.negocioSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se ha seleccionado un negocio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.provider.crearComponente(
        negocioId: widget.provider.negocioSeleccionadoId!,
        categoriaId: _categoriaSeleccionada!,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isNotEmpty
            ? _descripcionController.text.trim()
            : null,
        enUso: _enUso,
        activo: _activo,
        ubicacion: _ubicacionController.text.trim().isNotEmpty
            ? _ubicacionController.text.trim()
            : null,
        rfid: _rfidController.text.trim().isNotEmpty
            ? _rfidController.text.trim()
            : null, // ← NUEVO parámetro RFID
      );

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Componente creado exitosamente',
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
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Error al crear el componente',
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
