import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sf;

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/services/api_error_handler.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisibility = false;
  bool _isLoading = false;
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    _buttonController.forward().then((_) => _buttonController.reverse());

    try {
      final userState = Provider.of<UserState>(context, listen: false);

      // Check if user exists
      final userId = await userState.getUserId(_emailController.text);
      if (userId == null) {
        await ApiErrorHandler.callToast('Este correo no está registrado');
        setState(() => _isLoading = false);
        return;
      }

      await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (supabase.auth.currentUser == null) {
        await ApiErrorHandler.callToast();
        setState(() => _isLoading = false);
        return;
      }

      currentUser = await SupabaseQueries.getCurrentUserData();
      if (currentUser == null) {
        await ApiErrorHandler.callToast('Error al obtener datos del usuario');
        setState(() => _isLoading = false);
        return;
      }

      log('Usuario autenticado: ${currentUser!.id}');

      if (!mounted) return;

      // Navegar al dashboard
      context.go('/dashboard');
    } catch (e) {
      if (e is sf.AuthException) {
        await ApiErrorHandler.callToast('Credenciales inválidas');
      } else {
        await ApiErrorHandler.callToast('Error al iniciar sesión');
      }
      log('Error al iniciar sesión: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Center(
            child: Column(
              children: [
                Text(
                  'Iniciar Sesión',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accede a tu cuenta de cliente',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Campo Email
          Text(
            'Correo Electrónico',
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es requerido';
                } else if (!EmailValidator.validate(value)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'cliente@ejemplo.com',
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
                  Icons.email_outlined,
                  color: TallerAlexColors.primaryFuchsia,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Campo Contraseña
          Text(
            'Contraseña',
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
              controller: _passwordController,
              obscureText: !_passwordVisibility,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es requerida';
                }
                return null;
              },
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: '••••••••',
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
                  Icons.lock_outline,
                  color: TallerAlexColors.primaryFuchsia,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                      () => _passwordVisibility = !_passwordVisibility),
                  icon: Icon(
                    _passwordVisibility
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Enlace "¿Olvidaste tu contraseña?"
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: Implementar recuperación de contraseña
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: TallerAlexColors.primaryFuchsia,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Botón de login
          ScaleTransition(
            scale: _buttonScale,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: NeumorphicButton(
                onPressed: _isLoading ? null : _login,
                backgroundColor: TallerAlexColors.primaryFuchsia,
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
                        'Iniciar Sesión',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
