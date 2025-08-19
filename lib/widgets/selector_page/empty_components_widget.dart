import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/theme/theme.dart';

class EmptyComponentsWidget extends StatelessWidget {
  final String? rfidCode;
  final String? negocioId;

  const EmptyComponentsWidget({
    super.key,
    this.rfidCode,
    this.negocioId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.1),
                  theme.secondaryColor.withOpacity(0.1)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Todos los componentes tienen RFID!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Todos los componentes de este negocio ya tienen un código RFID asignado.',
            style: TextStyle(
              fontSize: 16,
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes crear un nuevo componente para asignar este RFID.',
            style: TextStyle(
              fontSize: 14,
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              final rfidParam = 'rfid=${rfidCode ?? ''}';
              final negocioParam =
                  negocioId != null ? '&negocioId=$negocioId' : '';
              context.go('/componente/crear?$rfidParam$negocioParam');
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Crear Nuevo Componente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}
