import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/providers/nethive/rfid_scanner_provider.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';

class RfidResultBottomSheet extends StatelessWidget {
  const RfidResultBottomSheet({Key? key, this.result}) : super(key: key);

  final RfidScanResult? result;

  IconData _getComponentIcon(Componente? componente) {
    if (componente == null) return Icons.memory;

    // Por ahora usar icono genérico ya que categoría es int
    return Icons.memory;
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox();

    return Consumer<ComponentesProvider>(
      builder: (context, componentesProvider, _) {
        final componente = componentesProvider.componentes
            .where((c) => c.rfid == result!.rfidCode)
            .firstOrNull;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _getComponentIcon(componente),
                    size: 32,
                    color: _getStatusColor(result!.status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          componente?.nombre ?? 'Componente no encontrado',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'RFID: ${result!.rfidCode ?? 'N/A'}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(result!.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(result!.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(result!.status),
                      style: TextStyle(
                        color: _getStatusColor(result!.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Información del componente
              if (componente != null) ...[
                _buildInfoRow('Nombre', componente.nombre),
                _buildInfoRow('Descripción', componente.descripcion ?? 'N/A'),
                _buildInfoRow(
                    'Categoría ID', componente.categoriaId.toString()),
                _buildInfoRow('En Uso', componente.enUso ? 'Sí' : 'No'),
                _buildInfoRow('Activo', componente.activo ? 'Sí' : 'No'),
                if (componente.ubicacion != null)
                  _buildInfoRow('Ubicación', componente.ubicacion!),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Este RFID no está asociado a ningún componente en el sistema.',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Acciones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<RfidScannerProvider>(
                      builder: (context, scannerProvider, _) {
                        if (scannerProvider.isBatchMode) {
                          return ElevatedButton(
                            onPressed: () {
                              // Agregar al lote
                              Navigator.of(context).pop();
                            },
                            child: const Text('Agregar al lote'),
                          );
                        } else {
                          return ElevatedButton(
                            onPressed: componente != null
                                ? () {
                                    // Ir a detalles del componente
                                    Navigator.of(context).pop();
                                    // TODO: Navegar a página de detalles
                                  }
                                : null,
                            child: const Text('Ver detalles'),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Espaciado para safe area
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RfidScanStatus status) {
    switch (status) {
      case RfidScanStatus.assigned:
        return Colors.green;
      case RfidScanStatus.unassigned:
        return Colors.orange;
      case RfidScanStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText(RfidScanStatus status) {
    switch (status) {
      case RfidScanStatus.assigned:
        return 'ASIGNADO';
      case RfidScanStatus.unassigned:
        return 'NO ASIGNADO';
      case RfidScanStatus.error:
        return 'ERROR';
    }
  }
}
