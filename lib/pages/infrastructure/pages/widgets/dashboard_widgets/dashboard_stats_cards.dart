import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardStatsCards extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardStatsCards({
    Key? key,
    required this.componentesProvider,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        'title': 'Componentes Totales',
        'value': '${componentesProvider.componentes.length}',
        'icon': Icons.inventory_2,
        'color': Colors.blue,
        'subtitle': 'equipos registrados',
      },
      {
        'title': 'Componentes Activos',
        'value':
            '${componentesProvider.componentes.where((c) => c.activo).length}',
        'icon': Icons.power,
        'color': Colors.green,
        'subtitle': 'en funcionamiento',
      },
      {
        'title': 'En Uso',
        'value':
            '${componentesProvider.componentes.where((c) => c.enUso).length}',
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'subtitle': 'siendo utilizados',
      },
      {
        'title': 'Categorías',
        'value': '${componentesProvider.categorias.length}',
        'icon': Icons.category,
        'color': Colors.purple,
        'subtitle': 'tipos de equipos',
      },
    ];

    if (isSmallScreen) {
      // En móvil: 2x2 grid
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return DashboardStatCard(
            title: stat['title'] as String,
            value: stat['value'] as String,
            icon: stat['icon'] as IconData,
            color: stat['color'] as Color,
            subtitle: stat['subtitle'] as String,
            isSmallScreen: isSmallScreen,
          );
        },
      );
    } else {
      // En desktop/tablet: row horizontal
      return Row(
        children: stats.map((stat) {
          final isLast = stat == stats.last;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: DashboardStatCard(
                    title: stat['title'] as String,
                    value: stat['value'] as String,
                    icon: stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    subtitle: stat['subtitle'] as String,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                if (!isLast) const SizedBox(width: 16),
              ],
            ),
          );
        }).toList(),
      );
    }
  }
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool isSmallScreen;

  const DashboardStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                          color: color, size: isSmallScreen ? 16 : 20),
                    ),
                    const Spacer(),
                    if (!isSmallScreen) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ACTIVO',
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: isSmallScreen ? 8 : 16),
                TweenAnimationBuilder<int>(
                  duration: Duration(
                      milliseconds: 1000 + (animationValue * 500).round()),
                  tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                  builder: (context, animatedValue, child) {
                    return Text(
                      animatedValue.toString(),
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: isSmallScreen ? 20 : 28,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isSmallScreen) ...[
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.of(context).secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
