import 'package:flutter/material.dart';
import '../../models/nethive/vista_conexiones_por_negocio_model.dart';
import '../../theme/theme.dart';

class ConnectionCard extends StatelessWidget {
  final VistaConexionesPorNegocio conexion;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;

  const ConnectionCard({
    Key? key,
    required this.conexion,
    this.onTap,
    this.onMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final isCompleted = conexion.tieneRfid;
    final statusColor = !conexion.activo
        ? Colors.grey
        : isCompleted
            ? Colors.green
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado y menú
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (onMenu != null)
                    IconButton(
                      onPressed: onMenu,
                      icon: const Icon(Icons.more_vert),
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Diagrama de conexión
              _buildConnectionDiagram(theme, statusColor),

              const SizedBox(height: 12),

              // Información adicional
              if (conexion.notas != null && conexion.notas!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          conexion.notas!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Información del cable (si existe)
              if (conexion.cableNombre != null) ...[
                const SizedBox(height: 8),
                _buildCableInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionDiagram(AppTheme theme, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Componente origen
          _buildComponentNode(
            name: conexion.origenNombre,
            rfid: conexion.origenUbicacion,
            isSource: true,
          ),

          // Línea de conexión
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.cable,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),

          // Componente destino
          _buildComponentNode(
            name: conexion.destinoNombre,
            rfid: conexion.destinoUbicacion,
            isSource: false,
          ),
        ],
      ),
    );
  }

  Widget _buildComponentNode({
    required String name,
    String? rfid,
    required bool isSource,
  }) {
    final iconColor = isSource ? Colors.blue : Colors.green;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.device_hub,
            color: iconColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (rfid != null)
                Text(
                  'RFID: $rfid',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCableInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cable,
            size: 14,
            color: Colors.blue.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cable: ${conexion.cableNombre}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                if (conexion.rfidCable != null)
                  Text(
                    'RFID: ${conexion.rfidCable}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade600,
                    ),
                  ),
                // TODO: Agregar información de tipo de cable cuando esté disponible
                // if (conexion.tipoCable != null || conexion.color != null) ...[
                //   const SizedBox(height: 2),
                //   Text(
                //     [
                //       if (conexion.tipoCable != null)
                //         'Tipo: ${conexion.tipoCable}',
                //       if (conexion.color != null) 'Color: ${conexion.color}',
                //     ].join(' • '),
                //     style: TextStyle(
                //       fontSize: 10,
                //       color: Colors.blue.shade600,
                //     ),
                //   ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (!conexion.activo) return Icons.cancel;
    if (conexion.rfidCable != null) return Icons.check_circle;
    return Icons.pending;
  }

  String _getStatusText() {
    if (!conexion.activo) return 'Inactiva';
    if (conexion.rfidCable != null) return 'Completada';
    return 'Pendiente';
  }
}
