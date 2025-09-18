import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/theme/theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();

    // Auto-navegar al login después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TallerAlexColors.neumorphicBackground,
              TallerAlexColors.paleRose.withOpacity(0.3),
              TallerAlexColors.lightRose.withOpacity(0.2),
              TallerAlexColors.neumorphicBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo principal con efecto neumórfico
              FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.all(40),
                  borderRadius: 30,
                  depth: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icono del taller con gradiente fucsia
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          gradient: TallerAlexColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.car_repair,
                          size: 55,
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
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Tu Auto, Nuestro Compromiso',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: TallerAlexColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Mensaje de bienvenida
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Transparencia y control total de tu vehículo.\nSeguimiento en tiempo real de todos los servicios.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: TallerAlexColors.textSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Barra de progreso neumórfica
              FadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 1200),
                child: Column(
                  children: [
                    Text(
                      'Cargando aplicación...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TallerAlexColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Contenedor neumórfico para la barra de progreso
                    NeumorphicContainer(
                      width: 250,
                      height: 8,
                      borderRadius: 4,
                      depth: -2, // Profundidad negativa para efecto hundido
                      backgroundColor: TallerAlexColors.neumorphicBase,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Container(
                                width: 250 * _progressAnimation.value,
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: TallerAlexColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),

              // Información de la app
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 1800),
                child: NeumorphicCard(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: TallerAlexColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smartphone,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'App Cliente Taller Alex',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: TallerAlexColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agenda citas • Seguimiento en tiempo real • Historial completo',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: TallerAlexColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
