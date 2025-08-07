import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardActivityFeed extends StatelessWidget {
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardActivityFeed({
    Key? key,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ActivityItems(isSmallScreen: isSmallScreen),
        ],
      ),
    );
  }
}

class ActivityItems extends StatelessWidget {
  final bool isSmallScreen;

  const ActivityItems({
    Key? key,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'title': 'Nuevo componente añadido',
        'description': 'Switch Cisco SG300-28 registrado en Rack 5',
        'time': '10:30 AM',
        'icon': Icons.add_circle,
        'color': Colors.green,
      },
      {
        'title': 'Mantenimiento completado',
        'description': 'Revisión de cables en Panel Principal',
        'time': '09:15 AM',
        'icon': Icons.build_circle,
        'color': Colors.blue,
      },
      {
        'title': 'Configuración actualizada',
        'description': 'Parámetros de red modificados',
        'time': '08:45 AM',
        'icon': Icons.settings,
        'color': Colors.purple,
      },
    ];

    if (isSmallScreen) {
      // En móvil: lista vertical
      return Column(
        children: activities.map((activity) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ActivityItem(
              title: activity['title'] as String,
              description: activity['description'] as String,
              time: activity['time'] as String,
              icon: activity['icon'] as IconData,
              color: activity['color'] as Color,
              isSmallScreen: isSmallScreen,
            ),
          );
        }).toList(),
      );
    } else {
      // En desktop/tablet: fila horizontal
      return Row(
        children: activities.map((activity) {
          final isLast = activity == activities.last;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ActivityItem(
                    title: activity['title'] as String,
                    description: activity['description'] as String,
                    time: activity['time'] as String,
                    icon: activity['icon'] as IconData,
                    color: activity['color'] as Color,
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

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color color;
  final bool isSmallScreen;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: isSmallScreen
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }
}
