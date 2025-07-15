import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart' as sf;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/pages/widgets/custom_button.dart';
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
    double height = MediaQuery.of(context).size.height / 1024;
    double width = MediaQuery.of(context).size.width / 1440;

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

    return SizedBox(
      width: 521,
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset(
                  AppTheme.themeMode == ThemeMode.light
                      ? 'assets/images/logo_lu.jpeg'
                      : 'assets/images/logo_lu.jpeg',
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  width: width * 200,
                  height: height * 200,
                ),
              ),
              Text(
                'Inicie Sesión',
                textAlign: TextAlign.start,
                style: AppTheme.of(context).title3.override(
                      fontFamily: AppTheme.of(context).title3Family,
                      color: AppTheme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 50.32),
              Text(
                'Correo',
                style: AppTheme.of(context).bodyText2,
              ),
              const SizedBox(height: 20),
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
                decoration: _buildInputDecoration('Nombre de usuario'),
                style: AppTheme.of(context).bodyText3.override(
                      fontFamily: AppTheme.of(context).bodyText3Family,
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Contraseña',
                style: AppTheme.of(context).bodyText2,
              ),
              const SizedBox(height: 20),
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
                decoration:
                    _buildInputDecoration('Contraseña', isPassword: true),
                style: AppTheme.of(context).bodyText3.override(
                      fontFamily: AppTheme.of(context).bodyText3Family,
                      color: AppTheme.of(context).primaryText,
                    ),
              ),
              const SizedBox(height: 53),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.25,
                    child: Checkbox(
                      value: userState.recuerdame,
                      activeColor: AppTheme.of(context).primaryColor,
                      onChanged: (value) async {
                        await userState.updateRecuerdame();
                      },
                      splashRadius: 0,
                    ),
                  ),
                  const SizedBox(width: 18),
                  InkWell(
                    onTap: () async {
                      await userState.updateRecuerdame();
                    },
                    child: Text(
                      'Recuerdame',
                      style: AppTheme.of(context).bodyText3,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'Olvidaste Contraseña?',
                      style: AppTheme.of(context).bodyText3.override(
                            fontFamily: AppTheme.of(context).bodyText3Family,
                            color: AppTheme.of(context).primaryColor,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  await login();
                },
                text: 'Iniciar Sesión',
                options: ButtonOptions(
                  width: double.infinity,
                  height: 68,
                  color: AppTheme.of(context).primaryColor,
                  textStyle: AppTheme.of(context).bodyText2.override(
                        fontFamily: AppTheme.of(context).bodyText3Family,
                        color: AppTheme.of(context).primaryBackground,
                      ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 68),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No registrasdo aun? ',
                    style: AppTheme.of(context).bodyText2.override(
                          fontFamily: AppTheme.of(context).bodyText2Family,
                          color: AppTheme.of(context).alternate,
                        ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      'Registrate',
                      style: AppTheme.of(context).bodyText2.override(
                            fontFamily: AppTheme.of(context).bodyText2Family,
                            color: AppTheme.of(context).primaryColor,
                          ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.copyright,
                    size: 16,
                    color: Color(0xFF99B2C6),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Copyright CB Luna 2024',
                    style: AppTheme.of(context).bodyText3.override(
                          fontFamily: AppTheme.of(context).bodyText3Family,
                          color: AppTheme.of(context).alternate,
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

  InputDecoration _buildInputDecoration(String label,
      {bool isPassword = false}) {
    Widget? suffixIcon;
    if (isPassword) {
      suffixIcon = InkWell(
        onTap: () => setState(
          () => passwordVisibility = !passwordVisibility,
        ),
        focusNode: FocusNode(skipTraversal: true),
        child: Icon(
          passwordVisibility
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: const Color(0xFFB8B8B8),
          size: 22,
        ),
      );
    }
    return InputDecoration(
      hintText: label,
      filled: true,
      // isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 27, vertical: 20),
      fillColor: AppTheme.of(context).tertiaryBackground,
      hintStyle: GoogleFonts.quicksand(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: AppTheme.of(context).hintText,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 27, right: 19),
        child: Icon(
          isPassword ? Icons.lock : Icons.mail_rounded,
          size: 24,
          color: AppTheme.of(context).hintText,
        ),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
