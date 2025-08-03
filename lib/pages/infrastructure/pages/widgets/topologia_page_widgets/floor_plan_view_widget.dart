import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';

class FloorPlanViewWidget extends StatelessWidget {
  final bool isMediumScreen;
  final ComponentesProvider provider;

  const FloorPlanViewWidget({
    Key? key,
    required this.isMediumScreen,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ).animate().scale(duration: 600.ms),
            const SizedBox(height: 20),
            const Text(
              'Plano de Planta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Próximamente: Distribución geográfica de componentes\ncon ${_getUbicacionesUnicas().length} ubicaciones identificadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 24),

            // Panel de información adicional para planos
            if (isMediumScreen) _buildFloorPlanInfoPanel(),
          ],
        ),
      ),
    );
  }

  List<String> _getUbicacionesUnicas() {
    final ubicaciones = provider.componentesTopologia
        .where((c) => c.ubicacion != null && c.ubicacion!.trim().isNotEmpty)
        .map((c) => c.ubicacion!)
        .toSet()
        .toList();
    return ubicaciones;
  }

  Widget _buildFloorPlanInfoPanel() {
    final ubicaciones = _getUbicacionesUnicas();
    final componentesPorPiso = _agruparComponentesPorPiso();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Plano',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (ubicaciones.isNotEmpty) ...[
            Text(
              'Ubicaciones detectadas: ${ubicaciones.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...ubicaciones.take(4).map((ubicacion) {
              final componentesEnUbicacion = provider.componentesTopologia
                  .where((c) => c.ubicacion == ubicacion)
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $ubicacion ($componentesEnUbicacion componentes)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              );
            }),
            if (ubicaciones.length > 4)
              Text(
                '... y ${ubicaciones.length - 4} más',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                ),
              ),
          ] else ...[
            Text(
              'No se encontraron ubicaciones específicas',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
          if (componentesPorPiso.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Distribución por niveles:',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...componentesPorPiso.entries.take(3).map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${entry.key}: ${entry.value} componentes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 12),
          const Text(
            'Funcionalidades planificadas:',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ...[
            '• Mapa interactivo de ubicaciones',
            '• Vista por pisos y áreas',
            '• Trazado de rutas de cableado',
            '• Ubicación GPS de componentes',
          ].map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  feature,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                  ),
                ),
              )),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3);
  }

  Map<String, int> _agruparComponentesPorPiso() {
    Map<String, int> pisos = {};

    for (var componente in provider.componentesTopologia) {
      if (componente.ubicacion != null) {
        String ubicacion = componente.ubicacion!.toLowerCase();
        String piso = 'Otros';

        if (ubicacion.contains('piso') || ubicacion.contains('planta')) {
          // Extraer número de piso
          RegExp regex = RegExp(r'(piso|planta)\s*(\d+)', caseSensitive: false);
          var match = regex.firstMatch(ubicacion);
          if (match != null) {
            piso = 'Piso ${match.group(2)}';
          }
        } else if (ubicacion.contains('pb') ||
            ubicacion.contains('planta baja')) {
          piso = 'Planta Baja';
        } else if (ubicacion.contains('sotano') ||
            ubicacion.contains('sótano')) {
          piso = 'Sótano';
        } else if (ubicacion.contains('azotea') ||
            ubicacion.contains('terraza')) {
          piso = 'Azotea';
        }

        pisos[piso] = (pisos[piso] ?? 0) + 1;
      }
    }

    return pisos;
  }
}
