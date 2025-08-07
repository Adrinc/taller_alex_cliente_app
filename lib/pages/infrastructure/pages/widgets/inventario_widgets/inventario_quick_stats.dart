import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'inventario_stat_card.dart';

class InventarioQuickStats extends StatelessWidget {
  final ComponentesProvider componentesProvider;

  const InventarioQuickStats({
    Key? key,
    required this.componentesProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InventarioStatCard(
            title: 'Total Componentes',
            value: componentesProvider.componentes.length,
            icon: Icons.devices,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InventarioStatCard(
            title: 'Activos',
            value:
                componentesProvider.componentes.where((c) => c.activo).length,
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InventarioStatCard(
            title: 'En Uso',
            value: componentesProvider.componentes.where((c) => c.enUso).length,
            icon: Icons.trending_up,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InventarioStatCard(
            title: 'Categorías',
            value: componentesProvider.categorias.length,
            icon: Icons.category,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }
}
