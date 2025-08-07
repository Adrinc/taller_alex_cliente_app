import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class DashboardContentSection extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isLargeScreen;
  final bool isMediumScreen;
  final bool isSmallScreen;

  const DashboardContentSection({
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
          ComponentsOverview(
            componentesProvider: componentesProvider,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          AlertasRecientes(isSmallScreen: isSmallScreen),
        ],
      );
    } else {
      // En desktop/tablet: row horizontal
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ComponentsOverview(
              componentesProvider: componentesProvider,
              isSmallScreen: isSmallScreen,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: AlertasRecientes(isSmallScreen: isSmallScreen),
          ),
        ],
      );
    }
  }
}

class ComponentsOverview extends StatelessWidget {
  final ComponentesProvider componentesProvider;
  final bool isSmallScreen;

  const ComponentsOverview({
    Key? key,
    required this.componentesProvider,
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
                Icons.pie_chart,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  isSmallScreen
                      ? 'Componentes'
                      : 'Distribución de Componentes por Categoría',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: isSmallScreen ? 16 : 18,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          categoria.nombre,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '$componentesDeCategoria (${porcentaje.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: porcentaje / 100,
                    backgroundColor:
                        AppTheme.of(context).primaryColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.of(context).primaryColor,
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class AlertasRecientes extends StatelessWidget {
  final bool isSmallScreen;

  const AlertasRecientes({
    Key? key,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                Icons.notifications_active,
                color: AppTheme.of(context).primaryColor,
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Text(
                  'Alertas Recientes',
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
              case 'Info':
                alertColor = Colors.blue;
                alertIcon = Icons.info;
                break;
              default:
                alertColor = Colors.grey;
                alertIcon = Icons.circle;
            }

            return Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: alertColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    alertIcon,
                    color: alertColor,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerta['mensaje'] as String,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hace ${alerta['tiempo']}',
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: isSmallScreen ? 10 : 11,
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
}
