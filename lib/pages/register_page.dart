import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/services/api_error_handler.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;
  bool _isLoading = false;
  File? _profileImage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      await ApiErrorHandler.callToast('Error al seleccionar imagen');
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implementar registro real con Supabase
      // Simulación de registro exitoso en modo demo
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      await ApiErrorHandler.callToast(
          '¡Registro exitoso! Ahora puedes iniciar sesión');
      context.go('/login');
    } catch (e) {
      await ApiErrorHandler.callToast('Error al registrar cuenta');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TallerAlexColors.neumorphicBackground,
                TallerAlexColors.paleRose.withOpacity(0.4),
                TallerAlexColors.lightRose.withOpacity(0.3),
                TallerAlexColors.neumorphicBackground,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    // Header con botón de regreso
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Row(
                        children: [
                          NeumorphicButton(
                            onPressed: () => context.go('/login'),
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
                              'Crear Cuenta',
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

                    const SizedBox(height: 30),

                    // Logo pequeño de Taller Alex
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: 20,
                        depth: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                gradient: TallerAlexColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.car_repair,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => TallerAlexColors
                                      .primaryGradient
                                      .createShader(bounds),
                                  child: Text(
                                    'Taller Alex',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Registro de Cliente',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: TallerAlexColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Formulario de registro
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: NeumorphicCard(
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Foto de perfil
                                Center(
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: NeumorphicContainer(
                                      width: 100,
                                      height: 100,
                                      borderRadius: 50,
                                      depth: _profileImage != null ? -4 : 4,
                                      child: _profileImage != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Image.file(
                                                _profileImage!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.add_a_photo,
                                              size: 30,
                                              color: TallerAlexColors
                                                  .primaryFuchsia,
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    'Foto de perfil (opcional)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: TallerAlexColors.textSecondary,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Campo Nombre Completo
                                _buildFieldLabel('Nombre Completo'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _nameController,
                                  hintText: 'Juan Pérez',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El nombre es requerido';
                                    }
                                    if (value.length < 2) {
                                      return 'Nombre muy corto';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Campo Email
                                _buildFieldLabel('Correo Electrónico'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  hintText: 'juan@ejemplo.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El correo es requerido';
                                    } else if (!EmailValidator.validate(
                                        value)) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Campo Teléfono
                                _buildFieldLabel('Teléfono'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _phoneController,
                                  hintText: '55 1234 5678',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El teléfono es requerido';
                                    }
                                    if (value.length < 10) {
                                      return 'Teléfono inválido';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Campo Contraseña
                                _buildFieldLabel('Contraseña'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _passwordController,
                                  hintText: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: !_passwordVisibility,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _passwordVisibility =
                                            !_passwordVisibility),
                                    icon: Icon(
                                      _passwordVisibility
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: TallerAlexColors.textSecondary,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'La contraseña es requerida';
                                    }
                                    if (value.length < 6) {
                                      return 'Mínimo 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Campo Confirmar Contraseña
                                _buildFieldLabel('Confirmar Contraseña'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hintText: '••••••••',
                                  icon: Icons.lock_outline,
                                  obscureText: !_confirmPasswordVisibility,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() =>
                                        _confirmPasswordVisibility =
                                            !_confirmPasswordVisibility),
                                    icon: Icon(
                                      _confirmPasswordVisibility
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: TallerAlexColors.textSecondary,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirma tu contraseña';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 40),

                                // Botón de registro
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: NeumorphicButton(
                                    onPressed: _isLoading ? null : _register,
                                    backgroundColor:
                                        TallerAlexColors.primaryFuchsia,
                                    borderRadius: 16,
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
                                            'Crear Cuenta',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
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
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Link para ir al login
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: GoogleFonts.poppins(
                              color: TallerAlexColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              'Inicia sesión aquí',
                              style: GoogleFonts.poppins(
                                color: TallerAlexColors.primaryFuchsia,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: TallerAlexColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return NeumorphicContainer(
      depth: -2,
      borderRadius: 12,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: GoogleFonts.poppins(
          color: TallerAlexColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: TallerAlexColors.textLight,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: TallerAlexColors.primaryFuchsia,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
