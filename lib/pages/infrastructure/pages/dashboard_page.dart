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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<NavigationProvider, ComponentesProvider>(
        builder: (context, navigationProvider, componentesProvider, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la página
                  _buildPageTitle(),

                  const SizedBox(height: 24),

                  // Cards de estadísticas principales
                  _buildStatsCards(componentesProvider),

                  const SizedBox(height: 24),

                  // Gráficos y métricas
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildComponentsOverview(componentesProvider),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildAlertasRecientes(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Actividad reciente
                  _buildActivityFeed(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageTitle() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard MDF/IDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Panel de control de infraestructura de red',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(ComponentesProvider componentesProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Componentes Totales',
            '${componentesProvider.componentes.length}',
            Icons.inventory_2,
            Colors.blue,
            'equipos registrados',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Componentes Activos',
            '${componentesProvider.componentes.where((c) => c.activo).length}',
            Icons.power,
            Colors.green,
            'en funcionamiento',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En Uso',
            '${componentesProvider.componentes.where((c) => c.enUso).length}',
            Icons.trending_up,
            Colors.orange,
            'siendo utilizados',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Categorías',
            '${componentesProvider.categorias.length}',
            Icons.category,
            Colors.purple,
            'tipos de equipos',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationValue),
          child: Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
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
                ),
                const SizedBox(height: 16),
                TweenAnimationBuilder<int>(
                  duration: Duration(
                      milliseconds: 1000 + (animationValue * 500).round()),
                  tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                  builder: (context, animatedValue, child) {
                    return Text(
                      animatedValue.toString(),
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 28,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComponentsOverview(ComponentesProvider componentesProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Distribución de Componentes por Categoría',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...componentesProvider.categorias.take(5).map((categoria) {
            final componentesDeCategoria = componentesProvider.componentes
                .where((c) => c.categoriaId == categoria.id)
                .length;
            final porcentaje = componentesProvider.componentes.isNotEmpty
                ? (componentesDeCategoria /
                    componentesProvider.componentes.length *
                    100)
                : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      categoria.nombre,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 8,
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
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$componentesDeCategoria (${porcentaje.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 12,
                      ),
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

  Widget _buildAlertasRecientes() {
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
      {
        'tipo': 'Warning',
        'mensaje': 'Capacidad de cable al 85%',
        'tiempo': '2 hrs'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alertas Recientes',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: alertColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(alertIcon, color: alertColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerta['mensaje']!,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'hace ${alerta['tiempo']}',
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: 10,
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

  Widget _buildActivityFeed() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Actividad Reciente',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActivityItem(
                  'Nuevo componente añadido',
                  'Switch Cisco SG300-28 registrado en Rack 5',
                  '10:30 AM',
                  Icons.add_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityItem(
                  'Mantenimiento completado',
                  'Revisión de cables en Panel Principal',
                  '09:15 AM',
                  Icons.build_circle,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActivityItem(
                  'Configuración actualizada',
                  'Parámetros de red modificados',
                  '08:45 AM',
                  Icons.settings,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
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
