import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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

                  // Nueva sección: Gráficos interactivos
                  _buildChartsSection(componentesProvider, isLargeScreen,
                      isMediumScreen, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Gráficos y métricas
                  _buildContentSection(componentesProvider, isLargeScreen,
                      isMediumScreen, isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Nueva sección: Métricas de rendimiento mejoradas
                  _buildEnhancedPerformanceMetrics(
                      componentesProvider, isSmallScreen),

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
          }),
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

  // ===== NUEVAS MEJORAS IMPLEMENTADAS =====

  Widget _buildEnhancedPerformanceMetrics(
      ComponentesProvider componentesProvider, bool isSmallScreen) {
    final totalComponentes = componentesProvider.componentes.length;
    final activosCount =
        componentesProvider.componentes.where((c) => c.activo).length;
    final enUsoCount =
        componentesProvider.componentes.where((c) => c.enUso).length;

    // Calcular métricas avanzadas
    final eficiencia =
        activosCount > 0 ? (enUsoCount / activosCount * 100) : 0.0;
    final disponibilidad =
        totalComponentes > 0 ? (activosCount / totalComponentes * 100) : 0.0;
    final capacidadLibre = activosCount > 0
        ? ((activosCount - enUsoCount) / activosCount * 100)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).secondaryBackground,
            AppTheme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono animado
          Row(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 6.28, // 2π para rotación completa
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.of(context).primaryColor,
                            AppTheme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Métricas de Rendimiento',
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Análisis en tiempo real del sistema',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 20 : 24),

          // Métricas con indicadores circulares animados
          if (isSmallScreen)
            Column(
              children: [
                _buildAnimatedMetricCard('Eficiencia de Uso', eficiencia, 85.0,
                    Colors.green, Icons.speed, isSmallScreen),
                const SizedBox(height: 16),
                _buildAnimatedMetricCard('Disponibilidad', disponibilidad, 95.0,
                    Colors.blue, Icons.cloud_done, isSmallScreen),
                const SizedBox(height: 16),
                _buildAnimatedMetricCard('Capacidad Libre', capacidadLibre,
                    20.0, Colors.orange, Icons.storage, isSmallScreen),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                    child: _buildAnimatedMetricCard(
                        'Eficiencia de Uso',
                        eficiencia,
                        85.0,
                        Colors.green,
                        Icons.speed,
                        isSmallScreen)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildAnimatedMetricCard(
                        'Disponibilidad',
                        disponibilidad,
                        95.0,
                        Colors.blue,
                        Icons.cloud_done,
                        isSmallScreen)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildAnimatedMetricCard(
                        'Capacidad Libre',
                        capacidadLibre,
                        20.0,
                        Colors.orange,
                        Icons.storage,
                        isSmallScreen)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMetricCard(String title, double value, double target,
      Color color, IconData icon, bool isSmallScreen) {
    final performance = value / target;
    final isGood = performance >= 0.8;
    final isWarning = performance >= 0.6 && performance < 0.8;

    Color statusColor =
        isGood ? Colors.green : (isWarning ? Colors.orange : Colors.red);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      tween: Tween(begin: 0.0, end: value / 100),
      builder: (context, animatedValue, child) {
        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Indicador circular animado
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: isSmallScreen ? 80 : 100,
                    height: isSmallScreen ? 80 : 100,
                    child: CircularProgressIndicator(
                      value: animatedValue,
                      strokeWidth: 8,
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0.0, end: value),
                        builder: (context, animatedNumber, child) {
                          return Text(
                            '${animatedNumber.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: statusColor,
                              fontSize: isSmallScreen ? 16 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Text(
                        'Meta: ${target.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 12 : 16),

              // Indicador de estado
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  isGood
                      ? 'Excelente'
                      : (isWarning ? 'Advertencia' : 'Crítico'),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== NUEVA SECCIÓN DE GRÁFICOS INTERACTIVOS =====

  Widget _buildChartsSection(ComponentesProvider componentesProvider,
      bool isLargeScreen, bool isMediumScreen, bool isSmallScreen) {
    if (isSmallScreen) {
      // En móvil: columna vertical
      return Column(
        children: [
          _buildComponentStatusChart(componentesProvider, isSmallScreen),
          const SizedBox(height: 16),
          _buildCategoryDistributionChart(componentesProvider, isSmallScreen),
          const SizedBox(height: 16),
          _buildUsageMetricsChart(componentesProvider, isSmallScreen),
        ],
      );
    } else if (isMediumScreen) {
      // En tablet: 2x2 grid
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildComponentStatusChart(
                    componentesProvider, isSmallScreen),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildCategoryDistributionChart(
                    componentesProvider, isSmallScreen),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildUsageMetricsChart(componentesProvider, isSmallScreen),
        ],
      );
    } else {
      // En desktop: tres columnas
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildComponentStatusChart(
                    componentesProvider, isSmallScreen),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildCategoryDistributionChart(
                    componentesProvider, isSmallScreen),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildUsageMetricsChart(componentesProvider, isSmallScreen),
        ],
      );
    }
  }

  Widget _buildComponentStatusChart(
      ComponentesProvider componentesProvider, bool isSmallScreen) {
    final totalComponentes = componentesProvider.componentes.length;
    final activosCount =
        componentesProvider.componentes.where((c) => c.activo).length;
    final enUsoCount =
        componentesProvider.componentes.where((c) => c.enUso).length;
    final inactivosCount = totalComponentes - activosCount;
    final libresCount = activosCount - enUsoCount;

    if (totalComponentes == 0) {
      return _buildEmptyChart('Estado de Componentes', isSmallScreen);
    }

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
                Icons.donut_small,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Estado de Componentes',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: isSmallScreen ? 200 : 250,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: enUsoCount.toDouble(),
                    title:
                        '${(enUsoCount / totalComponentes * 100).toStringAsFixed(1)}%',
                    radius: isSmallScreen ? 60 : 80,
                    titleStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: libresCount.toDouble(),
                    title:
                        '${(libresCount / totalComponentes * 100).toStringAsFixed(1)}%',
                    radius: isSmallScreen ? 60 : 80,
                    titleStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red,
                    value: inactivosCount.toDouble(),
                    title:
                        '${(inactivosCount / totalComponentes * 100).toStringAsFixed(1)}%',
                    radius: isSmallScreen ? 60 : 80,
                    titleStyle: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: isSmallScreen ? 30 : 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend([
            {'label': 'En Uso', 'color': Colors.green, 'value': enUsoCount},
            {'label': 'Libres', 'color': Colors.orange, 'value': libresCount},
            {
              'label': 'Inactivos',
              'color': Colors.red,
              'value': inactivosCount
            },
          ], isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(
      ComponentesProvider componentesProvider, bool isSmallScreen) {
    final categorias = componentesProvider.categorias;

    if (categorias.isEmpty) {
      return _buildEmptyChart('Distribución por Categorías', isSmallScreen);
    }

    // Contar componentes por categoría
    Map<String, int> categoriaCounts = {};
    for (var categoria in categorias) {
      final count = componentesProvider.componentes
          .where((c) => c.categoriaId == categoria.id)
          .length;
      if (count > 0) {
        categoriaCounts[categoria.nombre] = count;
      }
    }

    if (categoriaCounts.isEmpty) {
      return _buildEmptyChart('Distribución por Categorías', isSmallScreen);
    }

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
                Icons.bar_chart,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución por Categorías',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: isSmallScreen ? 200 : 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: categoriaCounts.values
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        final keys = categoriaCounts.keys.toList();
                        if (index >= 0 && index < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              keys[index].length > 8
                                  ? '${keys[index].substring(0, 8)}...'
                                  : keys[index],
                              style: TextStyle(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: categoriaCounts.entries.map((entry) {
                  final index =
                      categoriaCounts.keys.toList().indexOf(entry.key);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: _getColorForIndex(index),
                        width: isSmallScreen ? 16 : 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(
            categoriaCounts.entries.map((entry) {
              final index = categoriaCounts.keys.toList().indexOf(entry.key);
              return {
                'label': entry.key,
                'color': _getColorForIndex(index),
                'value': entry.value,
              };
            }).toList(),
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageMetricsChart(
      ComponentesProvider componentesProvider, bool isSmallScreen) {
    final categorias = componentesProvider.categorias;

    if (categorias.isEmpty) {
      return _buildEmptyChart('Métricas de Uso por Categoría', isSmallScreen);
    }

    // Crear datos para el gráfico de líneas mostrando eficiencia por categoría
    List<FlSpot> activosSpots = [];
    List<FlSpot> enUsoSpots = [];

    for (int i = 0; i < categorias.length && i < 8; i++) {
      final categoria = categorias[i];
      final componentesCategoria = componentesProvider.componentes
          .where((c) => c.categoriaId == categoria.id)
          .toList();

      final totalCategoria = componentesCategoria.length;
      final activosCategoria =
          componentesCategoria.where((c) => c.activo).length;
      final enUsoCategoria = componentesCategoria.where((c) => c.enUso).length;

      if (totalCategoria > 0) {
        activosSpots.add(
            FlSpot(i.toDouble(), (activosCategoria / totalCategoria * 100)));
        enUsoSpots
            .add(FlSpot(i.toDouble(), (enUsoCategoria / totalCategoria * 100)));
      }
    }

    if (activosSpots.isEmpty) {
      return _buildEmptyChart('Métricas de Uso por Categoría', isSmallScreen);
    }

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
                Icons.trending_up,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Métricas de Uso por Categoría',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Porcentaje de componentes activos vs en uso por categoría',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          SizedBox(
            height: isSmallScreen ? 200 : 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color:
                          AppTheme.of(context).secondaryText.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color:
                          AppTheme.of(context).secondaryText.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < categorias.length) {
                          final nombre = categorias[index].nombre;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              nombre.length > 6
                                  ? '${nombre.substring(0, 6)}...'
                                  : nombre,
                              style: TextStyle(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: isSmallScreen ? 10 : 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppTheme.of(context).secondaryText.withOpacity(0.2),
                  ),
                ),
                minX: 0,
                maxX: (categorias.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: activosSpots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.8),
                        Colors.green,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(0.3),
                          Colors.green.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: enUsoSpots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.8),
                        Colors.blue,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot spot) =>
                        AppTheme.of(context).secondaryBackground,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        final categoriaIndex = flSpot.x.toInt();
                        final categoria = categorias[categoriaIndex].nombre;
                        final isActivos = barSpot.barIndex == 0;

                        return LineTooltipItem(
                          '$categoria\n${isActivos ? 'Activos' : 'En Uso'}: ${flSpot.y.toStringAsFixed(1)}%',
                          TextStyle(
                            color: isActivos ? Colors.green : Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend([
            {
              'label': 'Componentes Activos',
              'color': Colors.green,
              'value': '%'
            },
            {'label': 'Componentes En Uso', 'color': Colors.blue, 'value': '%'},
          ], isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String title, bool isSmallScreen) {
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
                Icons.analytics_outlined,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 40 : 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: isSmallScreen ? 40 : 60,
                  color: AppTheme.of(context).secondaryText.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay datos disponibles',
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 40 : 60),
        ],
      ),
    );
  }

  Widget _buildChartLegend(
      List<Map<String, dynamic>> items, bool isSmallScreen) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        final value = item['value'];
        final displayValue = value is int
            ? '($value)'
            : value.toString().isNotEmpty
                ? '($value)'
                : '';

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item['label']} $displayValue',
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontSize: isSmallScreen ? 11 : 12,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.of(context).primaryColor,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
