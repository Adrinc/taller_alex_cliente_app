import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/providers/providers.dart';

class RfidResultBottomSheet extends StatelessWidget {
  final RfidScanResult result;

  const RfidResultBottomSheet({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle superior
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (result.status) {
      case RfidScanStatus.assigned:
        return _buildAssignedContent(context);
      case RfidScanStatus.unassigned:
        return _buildUnassignedContent(context);
      case RfidScanStatus.error:
        return _buildErrorContent(context);
    }
  }

  Widget _buildAssignedContent(BuildContext context) {
    final componente = result.componente!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header con estado
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RFID Asignado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    result.rfidCode ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Información del componente
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                componente.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (componente.descripcion?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  componente.descripcion!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Acciones
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/componente/${componente.id}');
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Ver Detalles'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showReassignDialog(context, result.rfidCode!);
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Reasignar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnassignedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code,
                color: Colors.blue,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RFID Disponible',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    result.rfidCode ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          '¿Qué desea hacer con este RFID?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 20),

        // Opciones de acción
        _buildActionOption(
          context,
          icon: Icons.add_box,
          title: 'Crear Nuevo Componente',
          subtitle: 'Registrar un componente nuevo con este RFID',
          color: Colors.green,
          onTap: () {
            Navigator.pop(context);
            final componentesProvider = context.read<ComponentesProvider>();
            final negocioId = componentesProvider.negocioSeleccionadoId;
            final rfidParam = 'rfid=${result.rfidCode}';
            final negocioParam =
                negocioId != null ? '&negocioId=$negocioId' : '';
            context.go('/componente/crear?$rfidParam$negocioParam');
          },
        ),

        const SizedBox(height: 12),

        _buildActionOption(
          context,
          icon: Icons.link,
          title: 'Asignar a Componente Existente',
          subtitle: 'Vincular este RFID a un componente ya registrado',
          color: Colors.blue,
          onTap: () {
            Navigator.pop(context);

            // Obtener el negocioId del ComponentesProvider
            final componentesProvider =
                Provider.of<ComponentesProvider>(context, listen: false);
            final negocioId = componentesProvider.negocioSeleccionadoId;

            // Construir la URL con ambos parámetros
            String url = '/componente/selector?rfid=${result.rfidCode}';
            if (negocioId != null) {
              url += '&negocioId=$negocioId';
            }

            context.go(url);
          },
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Error de Escaneo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          result.errorMessage ?? 'Error desconocido',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de Nuevo'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showReassignDialog(BuildContext context, String rfidCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reasignar RFID'),
        content: Text('¿Está seguro de que desea reasignar el RFID $rfidCode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Obtener el negocioId del ComponentesProvider
              final componentesProvider =
                  Provider.of<ComponentesProvider>(context, listen: false);
              final negocioId = componentesProvider.negocioSeleccionadoId;

              // Construir la URL con ambos parámetros
              String url = '/componente/selector?rfid=$rfidCode';
              if (negocioId != null) {
                url += '&negocioId=$negocioId';
              }

              context.go(url);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
