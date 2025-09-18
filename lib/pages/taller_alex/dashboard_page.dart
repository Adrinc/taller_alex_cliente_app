import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/taller_alex/usuario_provider.dart';

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con saludo, avatar y notificaciones
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Consumer<UsuarioProvider>(
                    builder: (context, usuarioProvider, child) {
                      return Row(
                        children: [
                          // Avatar del usuario
                          GestureDetector(
                            onTap: () => context.go('/perfil'),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: TallerAlexColors.primaryGradient,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: TallerAlexColors.primaryFuchsia
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: usuarioProvider.imagenBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.memory(
                                        usuarioProvider.imagenBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        usuarioProvider.getIniciales(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, ${usuarioProvider.nombreCompleto.split(' ').first}! 👋',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: TallerAlexColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bienvenido a Taller Alex',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: TallerAlexColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/notificaciones'),
                            child: NeumorphicContainer(
                              padding: const EdgeInsets.all(12),
                              borderRadius: 16,
                              child: Badge(
                                backgroundColor:
                                    TallerAlexColors.primaryFuchsia,
                                label: const Text('3'),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: TallerAlexColors.primaryFuchsia,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Tarjetas de estado rápido
                FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      // Mi vehículo en taller (si hay orden activa)
                      if (_hasActiveOrder)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: NeumorphicCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient:
                                            TallerAlexColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.build,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Vehículo en Servicio',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  TallerAlexColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            _vehicleInService,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: TallerAlexColors
                                                  .textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: TallerAlexColors.textLight,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: TallerAlexColors.lightRose
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _serviceStatus,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color:
                                                TallerAlexColors.textSecondary,
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

                      // Próxima cita
                      if (_hasUpcomingAppointment)
                        NeumorphicCard(
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: TallerAlexColors.lightRose
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.schedule,
                                  color: TallerAlexColors.primaryFuchsia,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Próxima Cita',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: TallerAlexColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _nextAppointment,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: TallerAlexColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Título de secciones principales
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    'Servicios Principales',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Grid de accesos rápidos
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 600),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
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
      child: NeumorphicCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TallerAlexColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
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
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: TallerAlexColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: TallerAlexColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
