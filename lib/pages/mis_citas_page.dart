import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/taller_alex/citas_provider.dart';
import 'package:nethive_neo/providers/taller_alex/ordenes_provider.dart';

class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}

class _MisCitasPageState extends State<MisCitasPage> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

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
          child: Consumer<CitasProvider>(
            builder: (context, citasProvider, child) {
              final citas = citasProvider.citas;

              return Column(
                children: [
                  // Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
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
                              'Mis Citas (${citas.length})',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: TallerAlexColors.textPrimary,
                              ),
                            ),
                          ),
                          NeumorphicButton(
                            onPressed: () => context.go('/agendar-cita'),
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            backgroundColor: TallerAlexColors.primaryFuchsia,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filtros de estado
                  FadeInDown(
                    duration: const Duration(milliseconds: 700),
                    child: _buildStatusFilters(),
                  ),

                  // Lista de citas
                  Expanded(
                    child: citas.isEmpty
                        ? _buildEmptyState()
                        : FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: citas.length,
                              itemBuilder: (context, index) {
                                final cita = citas[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: _buildCitaCard(cita, citasProvider),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TallerAlexColors.neumorphicBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TallerAlexColors.shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: TallerAlexColors.shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildStatusChip('Todas', Icons.calendar_today),
          _buildStatusChip('Programadas', Icons.schedule),
          _buildStatusChip('En proceso', Icons.build),
          _buildStatusChip('Completadas', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TallerAlexColors.primaryFuchsia.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TallerAlexColors.primaryFuchsia.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: TallerAlexColors.primaryFuchsia,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TallerAlexColors.primaryFuchsia,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: TallerAlexColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No tienes citas programadas',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agenda tu primera cita para comenzar con el mantenimiento de tu vehículo',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              NeumorphicButton(
                onPressed: () => context.go('/agendar-cita'),
                backgroundColor: TallerAlexColors.primaryFuchsia,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Agendar Cita',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitaCard(
      Map<String, dynamic> cita, CitasProvider citasProvider) {
    final vehiculo = cita['vehiculo'] as Map<String, dynamic>;
    final sucursal = cita['sucursal'] as Map<String, dynamic>;
    final servicios = cita['servicios'] as List<Map<String, dynamic>>;
    final fecha = cita['fecha'] as DateTime;
    final estado = cita['estado'] as String;

    Color statusColor = _getStatusColor(estado);

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: NeumorphicCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con número de orden y estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Orden: ${cita['numeroOrden']}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    estado,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información del vehículo
            _buildInfoRow(
              Icons.directions_car,
              'Vehículo',
              '${vehiculo['brand']} ${vehiculo['model']} ${vehiculo['year']} - ${vehiculo['plate']}',
            ),
            const SizedBox(height: 12),

            // Información de la sucursal
            _buildInfoRow(
              Icons.location_on,
              'Sucursal',
              sucursal['name'],
            ),
            const SizedBox(height: 12),

            // Fecha y hora
            _buildInfoRow(
              Icons.schedule,
              'Fecha y Hora',
              '${_dateFormat.format(fecha)} a las ${cita['hora']}',
            ),
            const SizedBox(height: 16),

            // Servicios
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TallerAlexColors.lightRose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servicios (${servicios.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TallerAlexColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...servicios.map((servicio) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: TallerAlexColors.primaryFuchsia,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                servicio['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: TallerAlexColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Notas si existen
            if (cita['notas'] != null &&
                cita['notas'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TallerAlexColors.neumorphicBase.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notas',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cita['notas'].toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Información de cupón y total
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TallerAlexColors.primaryFuchsia.withOpacity(0.1),
                    TallerAlexColors.paleRose.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cita['cupon'] != null &&
                            cita['cupon'].toString().isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.local_offer,
                                size: 16,
                                color: TallerAlexColors.primaryFuchsia,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cupón aplicado: ${cita['cupon']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TallerAlexColors.primaryFuchsia,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: TallerAlexColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tiempo estimado: ${cita['tiempoEstimado'] ?? 0} min',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: TallerAlexColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total estimado',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TallerAlexColors.textSecondary,
                        ),
                      ),
                      Text(
                        '\$${(cita['subtotal'] ?? 0.0).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                      ),
                    ],
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
                    onPressed: estado == 'Programada'
                        ? () => _showCancelConfirmation(cita, citasProvider)
                        : null,
                    backgroundColor: estado == 'Programada'
                        ? Colors.red.withOpacity(0.1)
                        : TallerAlexColors.neumorphicBase,
                    child: Text(
                      estado == 'Programada' ? 'Cancelar' : 'Ver Detalles',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: estado == 'Programada'
                            ? Colors.red
                            : TallerAlexColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    onPressed: () => _viewOrderDetails(cita),
                    backgroundColor: TallerAlexColors.primaryFuchsia,
                    child: Text(
                      'Ver Orden',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: TallerAlexColors.primaryFuchsia,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'Programada':
        return TallerAlexColors.primaryFuchsia;
      case 'En proceso':
        return Colors.orange;
      case 'Completada':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      default:
        return TallerAlexColors.textSecondary;
    }
  }

  void _showCancelConfirmation(
      Map<String, dynamic> cita, CitasProvider citasProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancelar Cita',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cancelar la cita del ${_dateFormat.format(cita['fecha'])}?',
          style: GoogleFonts.poppins(
            color: TallerAlexColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No',
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              citasProvider.cancelarCita(cita['id']);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cita cancelada exitosamente',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: TallerAlexColors.primaryFuchsia,
                ),
              );
            },
            backgroundColor: Colors.red,
            child: Text(
              'Sí, cancelar',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> cita) {
    final ordenesProvider =
        Provider.of<OrdenesProvider>(context, listen: false);

    try {
      // Crear orden desde la cita si no existe
      final ordenId = ordenesProvider.crearOrdenDesdeCita(cita);

      if (ordenId != null) {
        // Navegar a la página de órdenes y mostrar la orden específica
        context.go('/ordenes', extra: {'ordenId': ordenId});
      } else {
        // Mostrar error si no se pudo crear la orden
        _showError('Error al crear la orden de servicio');
      }
    } catch (e) {
      _showError('Error inesperado: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
