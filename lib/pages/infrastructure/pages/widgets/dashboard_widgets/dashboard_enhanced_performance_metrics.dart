import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardEnhancedPerformanceMetrics extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isSmallScreen;

  const DashboardEnhancedPerformanceMetrics({
    Key? key,
    required this.componentesProvider,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            AppTheme.of(context).primaryColor.withOpacity(0.05),
            AppTheme.of(context).secondaryBackground,
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
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 6.28, // 2π radianes = 360 grados
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.of(context).primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: isSmallScreen ? 18 : 22,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
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
                      ),
                    ),
                    Text(
                      'Análisis avanzado de infraestructura',
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
                AnimatedMetricCard(
                  title: 'Eficiencia de Uso',
                  value: eficiencia,
                  target: 80.0,
                  color: AppTheme.of(context).primaryColor,
                  icon: Icons.trending_up,
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 16),
                AnimatedMetricCard(
                  title: 'Disponibilidad',
                  value: disponibilidad,
                  target: 95.0,
                  color: Colors.green,
                  icon: Icons.check_circle,
                  isSmallScreen: isSmallScreen,
                ),
                const SizedBox(height: 16),
                AnimatedMetricCard(
                  title: 'Capacidad Libre',
                  value: capacidadLibre,
                  target: 30.0,
                  color: Colors.orange,
                  icon: Icons.storage,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Eficiencia de Uso',
                    value: eficiencia,
                    target: 80.0,
                    color: AppTheme.of(context).primaryColor,
                    icon: Icons.trending_up,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Disponibilidad',
                    value: disponibilidad,
                    target: 95.0,
                    color: Colors.green,
                    icon: Icons.check_circle,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedMetricCard(
                    title: 'Capacidad Libre',
                    value: capacidadLibre,
                    target: 30.0,
                    color: Colors.orange,
                    icon: Icons.storage,
                    isSmallScreen: isSmallScreen,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AnimatedMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final double target;
  final Color color;
  final IconData icon;
  final bool isSmallScreen;

  const AnimatedMetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.target,
    required this.color,
    required this.icon,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
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
            children: [
              // Header con título e icono
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isSmallScreen ? 16 : 20),

              // Indicador circular con progreso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
}
