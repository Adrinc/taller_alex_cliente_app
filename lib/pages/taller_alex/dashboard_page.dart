import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/taller_alex/usuario_provider.dart';
import 'package:nethive_neo/providers/taller_alex/notificaciones_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final bool _hasActiveOrder = true; // Demo data
  final String _vehicleInService = 'Honda Civic 2020 - ABC-123'; // Demo data
  final String _serviceStatus =
      'Diagnóstico completado - Esperando aprobación'; // Demo data
  final bool _hasUpcomingAppointment = true; // Demo data
  final String _nextAppointment =
      'Mañana 10:00 AM - Mantenimiento'; // Demo data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE8EAF0), // Fondo más gris para mayor contraste
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE8EAF0), // Gris claro principal
              const Color(0xFFEDEFF5), // Gris más claro
              const Color(0xFFE3E5EB), // Gris medio
              const Color(0xFFE8EAF0), // Gris claro principal
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con saludo, avatar y notificaciones
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Consumer<UsuarioProvider>(
                    builder: (context, usuarioProvider, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // Avatar del usuario con efecto neumórfico SUPER INTENSO
                            GestureDetector(
                              onTap: () => context.go('/perfil'),
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFFFFFF),
                                      const Color(0xFFE8EAF0),
                                    ],
                                  ),
                                  boxShadow: [
                                    // Sombra oscura MUY INTENSA
                                    BoxShadow(
                                      color: const Color(0xFF9DA4B0)
                                          .withOpacity(0.7),
                                      blurRadius: 30,
                                      offset: const Offset(10, 10),
                                      spreadRadius: 3,
                                    ),
                                    // Sombra clara MUY INTENSA
                                    BoxShadow(
                                      color: Colors.white.withOpacity(1.0),
                                      blurRadius: 25,
                                      offset: const Offset(-8, -8),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    gradient: TallerAlexColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(27),
                                    boxShadow: [
                                      BoxShadow(
                                        color: TallerAlexColors.primaryFuchsia
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: usuarioProvider.imagenBytes != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(27),
                                          child: Image.memory(
                                            usuarioProvider.imagenBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            usuarioProvider.getIniciales(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => TallerAlexColors
                                        .primaryGradient
                                        .createShader(bounds),
                                    child: Text(
                                      '¡Hola, ${usuarioProvider.nombreCompleto.split(' ').first}! 👋',
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          TallerAlexColors.lightRose
                                              .withOpacity(0.3),
                                          TallerAlexColors.paleRose
                                              .withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Bienvenido a Taller Alex',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: TallerAlexColors.primaryFuchsia,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Consumer<NotificacionesProvider>(
                              builder:
                                  (context, notificacionesProvider, child) {
                                return GestureDetector(
                                  onTap: () => context.go('/notificaciones'),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          const Color(0xFFE8EAF0),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        // Sombra oscura INTENSA
                                        BoxShadow(
                                          color: const Color(0xFF9DA4B0)
                                              .withOpacity(0.6),
                                          blurRadius: 20,
                                          offset: const Offset(6, 6),
                                          spreadRadius: 1,
                                        ),
                                        // Sombra clara INTENSA
                                        BoxShadow(
                                          color: Colors.white.withOpacity(1.0),
                                          blurRadius: 15,
                                          offset: const Offset(-4, -4),
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.notifications_outlined,
                                          color:
                                              TallerAlexColors.primaryFuchsia,
                                          size: 26,
                                        ),
                                        if (notificacionesProvider
                                                .notificacionesNoLeidas >
                                            0)
                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                gradient: TallerAlexColors
                                                    .primaryGradient,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: TallerAlexColors
                                                        .primaryFuchsia
                                                        .withOpacity(0.5),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 18,
                                                minHeight: 18,
                                              ),
                                              child: Text(
                                                '${notificacionesProvider.notificacionesNoLeidas}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Tarjetas de estado rápido con diseño mejorado
                FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      // Mi vehículo en taller (si hay orden activa) - NEUMORFISMO EXTREMO
                      if (_hasActiveOrder)
                        Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  const Color(0xFFE8EAF0),
                                ],
                              ),
                              boxShadow: [
                                // Sombra oscura MUY PROFUNDA
                                BoxShadow(
                                  color:
                                      const Color(0xFF9DA4B0).withOpacity(0.6),
                                  blurRadius: 35,
                                  offset: const Offset(12, 12),
                                  spreadRadius: 5,
                                ),
                                // Sombra clara MUY BRILLANTE
                                BoxShadow(
                                  color: Colors.white.withOpacity(1.0),
                                  blurRadius: 30,
                                  offset: const Offset(-10, -10),
                                  spreadRadius: 3,
                                ),
                                // Sombra interior simulada
                                BoxShadow(
                                  color:
                                      const Color(0xFFD1D9E6).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(2, 2),
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white,
                                              const Color(0xFFE8EAF0),
                                            ],
                                          ),
                                          boxShadow: [
                                            // Sombra oscura PROFUNDA para el icono
                                            BoxShadow(
                                              color: const Color(0xFF9DA4B0)
                                                  .withOpacity(0.5),
                                              blurRadius: 18,
                                              offset: const Offset(4, 4),
                                              spreadRadius: 1,
                                            ),
                                            // Sombra clara BRILLANTE
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(1.0),
                                              blurRadius: 15,
                                              offset: const Offset(-3, -3),
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          margin: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            gradient: TallerAlexColors
                                                .primaryGradient,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: TallerAlexColors
                                                    .primaryFuchsia
                                                    .withOpacity(0.4),
                                                blurRadius: 15,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.build_circle,
                                            color: Colors.white,
                                            size: 36,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Vehículo en Servicio',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: TallerAlexColors
                                                    .textPrimary,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _vehicleInService,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: TallerAlexColors
                                                    .textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: TallerAlexColors.lightRose
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          color:
                                              TallerAlexColors.primaryFuchsia,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.orange.withOpacity(0.1),
                                          Colors.orange.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _serviceStatus,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.orange.shade700,
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

                      // Próxima cita con NEUMORFISMO EXTREMO
                      if (_hasUpcomingAppointment)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                const Color(0xFFE8EAF0),
                              ],
                            ),
                            boxShadow: [
                              // Sombra oscura MUY PROFUNDA
                              BoxShadow(
                                color: const Color(0xFF9DA4B0).withOpacity(0.6),
                                blurRadius: 30,
                                offset: const Offset(10, 10),
                                spreadRadius: 4,
                              ),
                              // Sombra clara MUY BRILLANTE
                              BoxShadow(
                                color: Colors.white.withOpacity(1.0),
                                blurRadius: 25,
                                offset: const Offset(-8, -8),
                                spreadRadius: 2,
                              ),
                              // Sombra interior adicional
                              BoxShadow(
                                color:
                                    const Color(0xFFD1D9E6).withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(1, 1),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        TallerAlexColors.primaryFuchsia
                                            .withOpacity(0.2),
                                        TallerAlexColors.lightRose
                                            .withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: TallerAlexColors.primaryFuchsia
                                            .withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.schedule_outlined,
                                    color: TallerAlexColors.primaryFuchsia,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Próxima Cita',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: TallerAlexColors.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _nextAppointment,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: TallerAlexColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: TallerAlexColors.lightRose
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: TallerAlexColors.primaryFuchsia,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Título de secciones principales con diseño mejorado
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: TallerAlexColors.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Servicios Principales',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: TallerAlexColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: TallerAlexColors.softGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '6 servicios',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: TallerAlexColors.primaryFuchsia,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Grid de accesos rápidos con diseño mejorado
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 600),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    children: [
                      _buildQuickAccessCard(
                        icon: Icons.calendar_month,
                        title: 'Agendar\nCita',
                        subtitle: 'Nueva cita',
                        onTap: () => context.go('/agendar-cita'),
                        gradient: TallerAlexColors.primaryGradient,
                      ),
                      _buildQuickAccessCard(
                        icon: Icons.event_available,
                        title: 'Mis\nCitas',
                        subtitle: 'Ver programadas',
                        onTap: () => context.go('/mis-citas'),
                        color: const Color(0xFF9C27B0),
                      ),
                      _buildQuickAccessCard(
                        icon: Icons.directions_car,
                        title: 'Mis\nVehículos',
                        subtitle: '2 registrados',
                        onTap: () => context.go('/vehiculos'),
                        color: Colors.blue,
                      ),
                      _buildQuickAccessCard(
                        icon: Icons.assignment,
                        title: 'Mis\nÓrdenes',
                        subtitle: '1 activa',
                        onTap: () => context.go('/ordenes'),
                        color: Colors.orange,
                      ),
                      _buildQuickAccessCard(
                        icon: Icons.history,
                        title: 'Historial',
                        subtitle: '8 servicios',
                        onTap: () => context.go('/historial'),
                        color: Colors.green,
                      ),
                      _buildQuickAccessCard(
                        icon: Icons.local_offer,
                        title: 'Promociones',
                        subtitle: 'Ver ofertas',
                        onTap: () => context.go('/promociones'),
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100), // Espacio para bottom navigation
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Gradient? gradient,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFE8EAF0),
            ],
          ),
          boxShadow: [
            // Sombra principal ULTRA PROFUNDA
            BoxShadow(
              color: const Color(0xFF9DA4B0).withOpacity(0.7),
              blurRadius: 28,
              offset: const Offset(8, 8),
              spreadRadius: 3,
            ),
            // Highlight superior MUY INTENSO
            BoxShadow(
              color: Colors.white.withOpacity(1.0),
              blurRadius: 20,
              offset: const Offset(-6, -6),
              spreadRadius: 2,
            ),
            // Sombra interna sutil
            BoxShadow(
              color: const Color(0xFFCCD2DD).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(3, 3),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono con container neumórfico SUPER INTENSO
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFE8EAF0),
                    ],
                  ),
                  boxShadow: [
                    // Sombra oscura del contenedor del icono
                    BoxShadow(
                      color: const Color(0xFF9DA4B0).withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(6, 6),
                      spreadRadius: 1,
                    ),
                    // Sombra clara del contenedor
                    BoxShadow(
                      color: Colors.white.withOpacity(1.0),
                      blurRadius: 16,
                      offset: const Offset(-4, -4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // Sombra del icono colorido
                      BoxShadow(
                        color: (color ?? TallerAlexColors.primaryFuchsia)
                            .withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Título con mejor tipografía
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.textPrimary,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              // Subtítulo con badge estilo
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (color ?? TallerAlexColors.primaryFuchsia)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color ?? TallerAlexColors.primaryFuchsia,
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
