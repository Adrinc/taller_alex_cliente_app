import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/pages/login_page/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
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
    super.dispose();
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
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo de Taller Alex
                    FadeInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(30),
                        borderRadius: 25,
                        depth: 8,
                        child: Column(
                          children: [
                            // Icono del taller
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                gradient: TallerAlexColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.car_repair,
                                size: 45,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nombre del taller
                            ShaderMask(
                              shaderCallback: (bounds) => TallerAlexColors
                                  .primaryGradient
                                  .createShader(bounds),
                              child: Text(
                                'Taller Alex',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Tu Auto, Nuestro Compromiso',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: TallerAlexColors.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Formulario de login neumórfico
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: NeumorphicCard(
                          padding: const EdgeInsets.all(28),
                          child: const LoginForm(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Botón para registro
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 800),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: GoogleFonts.poppins(
                              color: TallerAlexColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: Text(
                              'Regístrate aquí',
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

                    const SizedBox(height: 40),

                    // Features de la app
                    FadeIn(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 1200),
                      child: NeumorphicCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: TallerAlexColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.security,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Conexión Segura',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: TallerAlexColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Tus datos están protegidos',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: TallerAlexColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildFeature(
                              Icons.visibility,
                              'Seguimiento en tiempo real',
                            ),
                            const SizedBox(height: 12),
                            _buildFeature(
                              Icons.schedule,
                              'Agenda tus citas fácilmente',
                            ),
                            const SizedBox(height: 12),
                            _buildFeature(
                              Icons.history,
                              'Historial completo de servicios',
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
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: TallerAlexColors.lightRose.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: TallerAlexColors.primaryFuchsia,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: TallerAlexColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
