import 'package:flutter/material.dart';
import '../../models/nethive/vista_conexiones_por_negocio_model.dart';
import '../../theme/theme.dart';

class ConnectionDetailsDialog extends StatelessWidget {
  final VistaConexionesPorNegocio conexion;
  final String negocioId;

  const ConnectionDetailsDialog({
    Key? key,
    required this.conexion,
    required this.negocioId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de Conexión',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryText,
                        ),
                      ),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Información de la conexión
            _buildInfoSection(theme),

            const SizedBox(height: 24),

            // Acciones
            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información de Conexión',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 16),

        // Conexión origen -> destino
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Origen
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.radio_button_checked,
                      color: Colors.blue.shade600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conexion.origenNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (conexion.origenUbicacion.isNotEmpty)
                          Text(
                            'Ubicación: ${conexion.origenUbicacion}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Línea conectora
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
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
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
              ),

              // Destino
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.radio_button_checked,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conexion.destinoNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (conexion.destinoUbicacion.isNotEmpty)
                          Text(
                            'Ubicación: ${conexion.destinoUbicacion}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Información adicional
        _buildDetailRow('ID de Conexión', conexion.conexionId.toString()),
        _buildDetailRow('Estado', conexion.activo ? 'Activa' : 'Inactiva'),
        if (conexion.cableNombre != null)
          _buildDetailRow('Cable', conexion.cableNombre!),
        // TODO: Agregar información de cable detallada cuando esté disponible
        // if (conexion.tipoCable != null)
        //   _buildDetailRow('Tipo de Cable', conexion.tipoCable!),
        // if (conexion.color != null) _buildDetailRow('Color', conexion.color!),
        // if (conexion.tamano != null)
        //   _buildDetailRow('Tamaño', conexion.tamano!.toString()),
        // if (conexion.tipoConector != null)
        //   _buildDetailRow('Tipo Conector', conexion.tipoConector!),
        if (conexion.rfidCable != null)
          _buildDetailRow('RFID Cable', conexion.rfidCable!),
        if (conexion.notas != null && conexion.notas!.isNotEmpty)
          _buildDetailRow('Notas', conexion.notas!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Actualizar cable
            _buildActionButton(
              icon: Icons.cable,
              label: 'Actualizar Cable',
              color: Colors.blue,
              onPressed: () => _showUpdateCableDialog(context),
            ),

            // Cambiar estado
            _buildActionButton(
              icon: conexion.activo ? Icons.toggle_off : Icons.toggle_on,
              label: conexion.activo ? 'Desactivar' : 'Activar',
              color: conexion.activo ? Colors.orange : Colors.green,
              onPressed: () => _toggleConnectionStatus(context),
            ),

            // Eliminar
            _buildActionButton(
              icon: Icons.delete,
              label: 'Eliminar',
              color: Colors.red,
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Botón cerrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Cerrar'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getStatusColor() {
    if (!conexion.activo) return Colors.grey;
    if (conexion.rfidCable != null) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon() {
    if (!conexion.activo) return Icons.cancel;
    if (conexion.rfidCable != null) return Icons.check_circle;
    return Icons.pending;
  }

  String _getStatusText() {
    if (!conexion.activo) return 'Conexión Inactiva';
    if (conexion.rfidCable != null) return 'Conexión Completada';
    return 'Conexión Pendiente';
  }

  void _showUpdateCableDialog(BuildContext context) {
    // TODO: Implementar diálogo para actualizar cable
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Actualizar Cable'),
        content: const Text('Funcionalidad en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _toggleConnectionStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(conexion.activo ? 'Desactivar Conexión' : 'Activar Conexión'),
        content: Text(
          conexion.activo
              ? '¿Estás seguro de que quieres desactivar esta conexión?'
              : '¿Estás seguro de que quieres activar esta conexión?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar cambio de estado
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Conexión'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta conexión?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pop(); // Cerrar también el diálogo de detalles
              _deleteConnection(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteConnection(BuildContext context) {
    // TODO: Implementar eliminación real
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de eliminación en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
