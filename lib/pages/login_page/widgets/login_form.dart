import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/services/api_error_handler.dart';
import 'package:nethive_neo/theme/theme.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();
  bool passwordVisibility = false;

  @override
  Widget build(BuildContext context) {
    final UserState userState = Provider.of<UserState>(context);

    Future<void> login() async {
      //Login
      try {
        // Check if user exists
        final userId =
            await userState.getUserId(userState.emailController.text);

        if (userId == null) {
          await ApiErrorHandler.callToast('Este Correo no está registrado');
          return;
        }

        await supabase.auth.signInWithPassword(
          email: userState.emailController.text,
          password: userState.passwordController.text,
        );

        if (userState.recuerdame == true) {
          await userState.setEmail();
          await userState.setPassword();
        } else {
          userState.emailController.text = '';
          userState.passwordController.text = '';
          await prefs.remove('email');
          await prefs.remove('password');
        }

        if (supabase.auth.currentUser == null) {
          await ApiErrorHandler.callToast();
          return;
        }

        currentUser = await SupabaseQueries.getCurrentUserData();

        if (currentUser == null) {
          await ApiErrorHandler.callToast();
          return;
        }
        /* 
        13: limitado
        14: ilimitado
         */

        /* ILIMITADO */
        print('User Role ID: ${currentUser!.role.roleId}');
        /*    if (currentUser!.role.roleId == 14 || currentUser!.role.roleId == 13) {
          context.pushReplacement('/book_page_main');
          return;
        } */
        /* LIMITADO */

        theme = await SupabaseQueries.getUserTheme();
        AppTheme.initConfiguration(theme);

        if (!mounted) return;

        context.pushReplacement('/');
      } catch (e) {
        if (e is sf.AuthException) {
          await userState.incrementLoginAttempts(
            userState.emailController.text,
          );
          await ApiErrorHandler.callToast('Credenciales Invalidas');

          return;
        }
        log('Error al iniciar sesion - $e');
      }
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo NetHive para formulario (solo en desktop)
            MediaQuery.of(context).size.width >= 768
                ? Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/images/favicon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido a NetHive',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Plataforma de Gestión de Infraestructura',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),

            // Título
            Text(
              'CORREO ELECTRÓNICO',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // Campo de email
            TextFormField(
              controller: userState.emailController,
              onFieldSubmitted: (value) async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await login();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El correo es requerido';
                } else if (!EmailValidator.validate(value)) {
                  return 'Favor de ingresar un correo valido';
                }
                return null;
              },
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'admin@nethive.com',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Título contraseña
            Text(
              'CONTRASEÑA',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // Campo de contraseña
            TextFormField(
              controller: userState.passwordController,
              obscureText: !passwordVisibility,
              onFieldSubmitted: (value) async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                await login();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La contraseña es requerida';
                }
                return null;
              },
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(
                    () => passwordVisibility = !passwordVisibility,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botón de iniciar sesión
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  await login();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'INICIAR SESIÓN',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Enlace "Conexión insegura"
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Conexión insegura',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFEF4444),
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Características principales
            Text(
              'CARACTERÍSTICAS PRINCIPALES',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de características
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem('Gestión completa de infraestructura'),
                _buildFeatureItem('Monitoreo en tiempo real'),
                _buildFeatureItem('Reportes avanzados'),
                _buildFeatureItem('Dashboard intuitivo'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
