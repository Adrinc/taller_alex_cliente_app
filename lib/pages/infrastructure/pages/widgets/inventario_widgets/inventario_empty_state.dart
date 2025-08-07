import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class InventarioEmptyState extends StatelessWidget {
  const InventarioEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2,
              color: AppTheme.of(context).primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay componentes registrados',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade el primer componente para comenzar',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
