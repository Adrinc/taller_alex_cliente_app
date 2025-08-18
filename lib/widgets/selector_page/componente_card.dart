import 'package:flutter/material.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/theme/theme.dart';

class ComponenteCard extends StatelessWidget {
  final Componente componente;
  final VoidCallback onTap;
  final bool isLoading;

  const ComponenteCard({
    super.key,
    required this.componente,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono del componente
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getComponentIcon(componente.categoriaId),
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del componente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        componente.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (componente.descripcion?.isNotEmpty == true)
                        Text(
                          componente.descripcion!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Categoría: ${componente.categoriaId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Indicador de loading o icono de flecha
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: theme.secondaryText,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getComponentIcon(int categoriaId) {
    switch (categoriaId) {
      case 1: // Switch
        return Icons.hub;
      case 2: // Cable
        return Icons.cable;
      case 3: // Rack
        return Icons.developer_board;
      case 4: // Servidor
        return Icons.dns;
      case 5: // Router
        return Icons.router;
      case 6: // Patch Panel
        return Icons.dashboard;
      case 7: // UPS
        return Icons.battery_charging_full;
      default:
        return Icons.memory;
    }
  }
}
