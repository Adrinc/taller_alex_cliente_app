import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardChartsSection extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardChartsSection({
    Key? key,
    required this.componentesProvider,
    required this.isLargeScreen,
    required this.isMediumScreen,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSmallScreen) {
      // En móvil: columna vertical
      return Column(
        children: [
          ComponentStatusChart(
            componentesProvider: componentesProvider,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          CategoryDistributionChart(
            componentesProvider: componentesProvider,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          UsageMetricsChart(
            componentesProvider: componentesProvider,
            isSmallScreen: isSmallScreen,
          ),
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
                child: ComponentStatusChart(
                  componentesProvider: componentesProvider,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: CategoryDistributionChart(
                  componentesProvider: componentesProvider,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          UsageMetricsChart(
            componentesProvider: componentesProvider,
            isSmallScreen: isSmallScreen,
          ),
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
                child: ComponentStatusChart(
                  componentesProvider: componentesProvider,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: CategoryDistributionChart(
                  componentesProvider: componentesProvider,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          UsageMetricsChart(
            componentesProvider: componentesProvider,
            isSmallScreen: isSmallScreen,
          ),
        ],
      );
    }
  }
}

class ComponentStatusChart extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isSmallScreen;

  const ComponentStatusChart({
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
    final inactivosCount = totalComponentes - activosCount;
    final libresCount = activosCount - enUsoCount;

    if (totalComponentes == 0) {
      return EmptyChart(
          title: 'Estado de Componentes', isSmallScreen: isSmallScreen);
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
          ChartLegend(
            items: [
              {'label': 'En Uso', 'color': Colors.green, 'value': enUsoCount},
              {'label': 'Libres', 'color': Colors.orange, 'value': libresCount},
              {
                'label': 'Inactivos',
                'color': Colors.red,
                'value': inactivosCount
              },
            ],
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}

class CategoryDistributionChart extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isSmallScreen;

  const CategoryDistributionChart({
    Key? key,
    required this.componentesProvider,
    required this.isSmallScreen,
  }) : super(key: key);

  Color _getColorForIndex(int index, BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    final categorias = componentesProvider.categorias;

    if (categorias.isEmpty) {
      return EmptyChart(
          title: 'Distribución por Categorías', isSmallScreen: isSmallScreen);
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
      return EmptyChart(
          title: 'Distribución por Categorías', isSmallScreen: isSmallScreen);
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
                        color: _getColorForIndex(index, context),
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
          ChartLegend(
            items: categoriaCounts.entries.map((entry) {
              final index = categoriaCounts.keys.toList().indexOf(entry.key);
              return {
                'label': entry.key,
                'color': _getColorForIndex(index, context),
                'value': entry.value,
              };
            }).toList(),
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}

class UsageMetricsChart extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isSmallScreen;

  const UsageMetricsChart({
    Key? key,
    required this.componentesProvider,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categorias = componentesProvider.categorias;

    if (categorias.isEmpty) {
      return EmptyChart(
          title: 'Métricas de Uso por Categoría', isSmallScreen: isSmallScreen);
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
      return EmptyChart(
          title: 'Métricas de Uso por Categoría', isSmallScreen: isSmallScreen);
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
          ChartLegend(
            items: [
              {
                'label': 'Componentes Activos',
                'color': Colors.green,
                'value': '%'
              },
              {
                'label': 'Componentes En Uso',
                'color': Colors.blue,
                'value': '%'
              },
            ],
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}

class EmptyChart extends StatelessWidget {
  final String title;
  final bool isSmallScreen;

  const EmptyChart({
    Key? key,
    required this.title,
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
}

class ChartLegend extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isSmallScreen;

  const ChartLegend({
    Key? key,
    required this.items,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
