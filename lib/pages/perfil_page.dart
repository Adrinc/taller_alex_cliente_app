import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nethive_neo/theme/theme.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  // Controladores de formulario
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _rfcController = TextEditingController();

  // Configuraciones
  bool _notificacionesPush = true;
  bool _notificacionesEmail = false;
  bool _modoseguro = false;
  bool _autoBackup = true;
  // String _idioma = 'es';
  // String _tema = 'claro';

  // Datos del usuario
  String? _profileImage;
  final Map<String, dynamic> _userData = {
    'name': 'Juan Pérez García',
    'email': 'juan.perez@email.com',
    'phone': '+52 55 1234 5678',
    'address': 'Av. Principal 123, Col. Centro, CDMX',
    'rfc': 'PEGJ890123ABC',
    'memberSince': DateTime(2023, 3, 15),
    'totalServices': 8,
    'favoriteLocation': 'Sucursal Centro',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = _userData['name'];
    _emailController.text = _userData['email'];
    _phoneController.text = _userData['phone'];
    _addressController.text = _userData['address'];
    _rfcController.text = _userData['rfc'];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _rfcController.dispose();
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
              // Header con foto de perfil
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
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
                              'Mi Perfil',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                          ),
                          NeumorphicButton(
                            onPressed: _logout,
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            child: Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Foto de perfil
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: TallerAlexColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: TallerAlexColors.primaryFuchsia
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _profileImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _changeProfileImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: TallerAlexColors.primaryFuchsia,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Información básica
                      Text(
                        _userData['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: TallerAlexColors.textPrimary,
                        ),
                      ),
                      Text(
                        _userData['email'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Estadísticas rápidas
                      Row(
                        children: [
                          _buildStatItem(
                            'Servicios',
                            '${_userData['totalServices']}',
                            Icons.build,
                          ),
                          _buildStatItem(
                            'Miembro desde',
                            '${_userData['memberSince'].year}',
                            Icons.calendar_today,
                          ),
                          _buildStatItem(
                            'Sucursal favorita',
                            'Centro',
                            Icons.location_on,
                          ),
                        ],
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
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(text: 'Datos'),
                        Tab(text: 'Configuración'),
                        Tab(text: 'Cuenta'),
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
                    _buildPersonalData(),
                    _buildSettings(),
                    _buildAccountInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: NeumorphicContainer(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: TallerAlexColors.primaryFuchsia,
              size: 16,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: TallerAlexColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalData() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información personal
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información personal',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nombre completo',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo electrónico',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Dirección',
                    icon: Icons.location_on,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _rfcController,
                    label: 'RFC (opcional)',
                    icon: Icons.assignment_ind,
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
                    onPressed: _resetChanges,
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
                    onPressed: _saveChanges,
                    backgroundColor: TallerAlexColors.primaryFuchsia,
                    child: Text(
                      'Guardar cambios',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notificaciones
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSwitch(
                    'Notificaciones push',
                    'Recibir notificaciones en tiempo real',
                    _notificacionesPush,
                    (value) => setState(() => _notificacionesPush = value),
                    Icons.notifications_active,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingSwitch(
                    'Notificaciones por email',
                    'Recibir resúmenes por correo electrónico',
                    _notificacionesEmail,
                    (value) => setState(() => _notificacionesEmail = value),
                    Icons.email,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Seguridad
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seguridad',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSwitch(
                    'Modo seguro',
                    'Confirmación adicional para acciones importantes',
                    _modoseguro,
                    (value) => setState(() => _modoseguro = value),
                    Icons.security,
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: _changePassword,
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Cambiar contraseña',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: TallerAlexColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Aplicación
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aplicación',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSwitch(
                    'Copia de seguridad automática',
                    'Respaldar datos automáticamente',
                    _autoBackup,
                    (value) => setState(() => _autoBackup = value),
                    Icons.backup,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingSelector(
                    'Idioma',
                    'Español',
                    Icons.language,
                    _changeLanguage,
                  ),
                  const SizedBox(height: 12),
                  _buildSettingSelector(
                    'Tema',
                    'Claro',
                    Icons.palette,
                    _changeTheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la cuenta
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la cuenta',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'ID de cliente',
                    'TAC-${DateTime.now().year}-001',
                    Icons.badge,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Miembro desde',
                    '${_userData['memberSince'].day}/${_userData['memberSince'].month}/${_userData['memberSince'].year}',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Última actividad',
                    'Hoy, ${TimeOfDay.now().format(context)}',
                    Icons.access_time,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Servicios totales',
                    '${_userData['totalServices']}',
                    Icons.build,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Datos y privacidad
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos y privacidad',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: _downloadData,
                    child: Row(
                      children: [
                        Icon(
                          Icons.download,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Descargar mis datos',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: TallerAlexColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeumorphicButton(
                    onPressed: _showPrivacyPolicy,
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Política de privacidad',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: TallerAlexColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Zona de peligro
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zona de peligro',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: _deleteAccount,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Eliminar cuenta',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Información de la app
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la app',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Versión',
                    '1.0.0',
                    Icons.info,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Última actualización',
                    '15/09/2024',
                    Icons.update,
                  ),
                  const SizedBox(height: 16),
                  NeumorphicButton(
                    onPressed: _showAbout,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Acerca de Taller Alex',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: TallerAlexColors.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: TallerAlexColors.primaryFuchsia,
          ),
          border: InputBorder.none,
          labelStyle: GoogleFonts.poppins(
            color: TallerAlexColors.textSecondary,
          ),
        ),
        style: GoogleFonts.poppins(
          color: TallerAlexColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: TallerAlexColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
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
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: TallerAlexColors.primaryFuchsia,
          activeTrackColor: TallerAlexColors.primaryFuchsia.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildSettingSelector(
    String title,
    String currentValue,
    IconData icon,
    VoidCallback onTap,
  ) {
    return NeumorphicButton(
      onPressed: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: TallerAlexColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
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
                Text(
                  currentValue,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: TallerAlexColors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: TallerAlexColors.primaryFuchsia,
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: TallerAlexColors.textSecondary,
            ),
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
    );
  }

  void _changeProfileImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TallerAlexColors.neumorphicBackground,
              TallerAlexColors.paleRose.withOpacity(0.1),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar foto de perfil',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: TallerAlexColors.primaryFuchsia,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cámara',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.gallery);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: TallerAlexColors.primaryFuchsia,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Galería',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _profileImage = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar imagen'),
        ),
      );
    }
  }

  void _saveChanges() {
    // TODO: Implementar guardado de cambios
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados correctamente'),
      ),
    );
  }

  void _resetChanges() {
    _initializeControllers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios descartados'),
      ),
    );
  }

  void _changePassword() {
    // TODO: Implementar cambio de contraseña
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cambiar contraseña',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          'Se enviará un enlace de cambio de contraseña a tu correo electrónico.',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Enlace enviado a tu correo electrónico'),
                ),
              );
            },
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'Enviar',
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

  void _changeLanguage() {
    // TODO: Implementar cambio de idioma
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad disponible próximamente'),
      ),
    );
  }

  void _changeTheme() {
    // TODO: Implementar cambio de tema
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad disponible próximamente'),
      ),
    );
  }

  void _downloadData() {
    // TODO: Implementar descarga de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparando descarga de datos...'),
      ),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Mostrar política de privacidad
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Política de privacidad',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'En Taller Alex respetamos tu privacidad y protegemos tus datos personales de acuerdo con las mejores prácticas de la industria...',
            style: GoogleFonts.poppins(
              color: TallerAlexColors.textSecondary,
            ),
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

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Acerca de Taller Alex',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: TallerAlexColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.build,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Taller Alex Cliente\nVersión 1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Red de talleres automotrices con más de 10 años de experiencia brindando servicios de calidad.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'Cerrar',
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

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '⚠️ Eliminar cuenta',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
        content: Text(
          'Esta acción es irreversible. Se eliminarán todos tus datos, historial de servicios y configuraciones. ¿Estás seguro?',
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
              // TODO: Implementar eliminación de cuenta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad disponible próximamente'),
                ),
              );
            },
            backgroundColor: Colors.red,
            child: Text(
              'Eliminar',
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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cerrar sesión',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
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
              context.go('/');
            },
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'Cerrar sesión',
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
}
