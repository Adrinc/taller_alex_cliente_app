import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/nethive/navigation_provider.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<NavigationProvider, ComponentesProvider>(
        builder: (context, navigationProvider, componentesProvider, child) {
          return Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la página
                  _buildPageTitle(isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Cards de estadísticas principales
                  _buildStatsCards(componentesProvider, isLargeScreen,
                      isMediumScreen, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Gráficos y métricas
                  _buildContentSection(componentesProvider, isLargeScreen,
                      isMediumScreen, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Actividad reciente
                  _buildActivityFeed(
                      isLargeScreen, isMediumScreen, isSmallScreen),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageTitle(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.dashboard,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard MDF/IDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen) ...[
                  Text(
                    'Panel de control de infraestructura de red',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ComponentesProvider componentesProvider,
      bool isLargeScreen, bool isMediumScreen, bool isSmallScreen) {
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
          return _buildStatCard(
            stat['title'] as String,
            stat['value'] as String,
            stat['icon'] as IconData,
            stat['color'] as Color,
            stat['subtitle'] as String,
            isSmallScreen,
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
                  child: _buildStatCard(
                    stat['title'] as String,
                    stat['value'] as String,
                    stat['icon'] as IconData,
                    stat['color'] as Color,
                    stat['subtitle'] as String,
                    isSmallScreen,
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isSmallScreen,
  ) {
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'MDF/IDF',
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

  Widget _buildContentSection(ComponentesProvider componentesProvider,
      bool isLargeScreen, bool isMediumScreen, bool isSmallScreen) {
    if (isSmallScreen) {
      // En móvil: columna vertical
      return Column(
        children: [
          _buildComponentsOverview(componentesProvider, isSmallScreen),
          const SizedBox(height: 16),
          _buildAlertasRecientes(isSmallScreen),
        ],
      );
    } else {
      // En desktop/tablet: row horizontal
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _buildComponentsOverview(componentesProvider, isSmallScreen),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildAlertasRecientes(isSmallScreen),
          ),
        ],
      );
    }
  }

  Widget _buildComponentsOverview(
      ComponentesProvider componentesProvider, bool isSmallScreen) {
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
                Icons.pie_chart,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  isSmallScreen
                      ? 'Componentes por Categoría'
                      : 'Distribución de Componentes por Categoría',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          ...componentesProvider.categorias
              .take(isSmallScreen ? 4 : 5)
              .map((categoria) {
            final componentesDeCategoria = componentesProvider.componentes
                .where((c) => c.categoriaId == categoria.id)
                .length;
            final porcentaje = componentesProvider.componentes.isNotEmpty
                ? (componentesDeCategoria /
                    componentesProvider.componentes.length *
                    100)
                : 0.0;

            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: isSmallScreen ? 2 : 3,
                        child: Text(
                          categoria.nombre,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        flex: isSmallScreen ? 3 : 4,
                        child: Container(
                          height: isSmallScreen ? 6 : 8,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).tertiaryBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: porcentaje / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.of(context).primaryGradient,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      SizedBox(
                        width: isSmallScreen ? 40 : 60,
                        child: Text(
                          isSmallScreen
                              ? '$componentesDeCategoria'
                              : '$componentesDeCategoria (${porcentaje.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAlertasRecientes(bool isSmallScreen) {
    final alertas = [
      {
        'tipo': 'Warning',
        'mensaje': 'Switch en Rack 3 sobrecalentándose',
        'tiempo': '5 min'
      },
      {
        'tipo': 'Error',
        'mensaje': 'Pérdida de conectividad en Panel A4',
        'tiempo': '12 min'
      },
      {
        'tipo': 'Info',
        'mensaje': 'Mantenimiento programado completado',
        'tiempo': '1 hr'
      },
      if (!isSmallScreen)
        {
          'tipo': 'Warning',
          'mensaje': 'Capacidad de cable al 85%',
          'tiempo': '2 hrs'
        },
    ];

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
                Icons.warning,
                color: Colors.orange,
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Text(
                'Alertas Recientes',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          ...alertas.map((alerta) {
            Color alertColor;
            IconData alertIcon;

            switch (alerta['tipo']) {
              case 'Error':
                alertColor = Colors.red;
                alertIcon = Icons.error;
                break;
              case 'Warning':
                alertColor = Colors.orange;
                alertIcon = Icons.warning;
                break;
              default:
                alertColor = Colors.blue;
                alertIcon = Icons.info;
            }

            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: alertColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(alertIcon,
                      color: alertColor, size: isSmallScreen ? 14 : 16),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerta['mensaje']!,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: isSmallScreen ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'hace ${alerta['tiempo']}',
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: isSmallScreen ? 9 : 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(
      bool isLargeScreen, bool isMediumScreen, bool isSmallScreen) {
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
              Text(
                'Actividad Reciente',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildActivityItems(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildActivityItems(bool isSmallScreen) {
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
            child: _buildActivityItem(
              activity['title'] as String,
              activity['description'] as String,
              activity['time'] as String,
              activity['icon'] as IconData,
              activity['color'] as Color,
              isSmallScreen,
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
                  child: _buildActivityItem(
                    activity['title'] as String,
                    activity['description'] as String,
                    activity['time'] as String,
                    activity['icon'] as IconData,
                    activity['color'] as Color,
                    isSmallScreen,
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

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
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
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: AppTheme.of(context).primaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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
