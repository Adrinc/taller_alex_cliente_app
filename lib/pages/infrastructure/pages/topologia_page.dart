import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/models/nethive/topologia_completa_model.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/topologia_page_widgets/rack_view_widget.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/topologia_page_widgets/floor_plan_view_widget.dart';

class TopologiaPage extends StatefulWidget {
  const TopologiaPage({Key? key}) : super(key: key);

  @override
  State<TopologiaPage> createState() => _TopologiaPageState();
}

class _TopologiaPageState extends State<TopologiaPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedView = 'network'; // network, rack, floor
  bool _isLoading = false;

  // Dashboard para el FlowChart
  late Dashboard dashboard;

  // Mapas para elementos y conexiones
  Map<String, FlowElement> elementosMap = {};

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
    _initializeDashboard();

    // Cargar datos después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTopologyData();
    });
  }

  void _initializeDashboard() {
    dashboard = Dashboard(
      blockDefaultZoomGestures: false,
      minimumZoomFactor: 0.25,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMediumScreen = MediaQuery.of(context).size.width > 800;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<ComponentesProvider>(
        builder: (context, componentesProvider, child) {
          if (componentesProvider.isLoadingTopologia || _isLoading) {
            return _buildLoadingView();
          }

          // Verificar si hay un negocio seleccionado
          if (componentesProvider.negocioSeleccionadoId == null) {
            return _buildNoBusinessSelectedView();
          }

          // Verificar si hay componentes
          if (componentesProvider.componentesTopologia.isEmpty) {
            return _buildNoComponentsView();
          }

          return Container(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header profesional
                _buildProfessionalHeader(componentesProvider),
                const SizedBox(height: 24),

                // Controles avanzados
                if (isMediumScreen) ...[
                  _buildAdvancedControls(componentesProvider),
                  const SizedBox(height: 24),
                ],

                // Vista principal profesional
                Expanded(
                  child: _buildProfessionalTopologyView(
                      isMediumScreen, componentesProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: AppTheme.of(context).primaryColor,
          ).animate().scale(duration: 600.ms).then(delay: 200.ms).fadeIn(),
          const SizedBox(height: 24),
          Text(
            'Cargando topología de red...',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Construyendo infraestructura desde la base de datos',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildNoBusinessSelectedView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: AppTheme.of(context).primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Selecciona un Negocio',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Debe seleccionar un negocio desde la gestión\nde empresas para visualizar su topología',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoComponentsView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.device_hub_outlined,
              size: 80,
              color: AppTheme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Sin Componentes',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Este negocio no tiene componentes\nregistrados en la infraestructura',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader(ComponentesProvider provider) {
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
              Icons.account_tree,
              color: Colors.white,
              size: 24,
            ),
          ).animate().scale(duration: 600.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Topología de Red - ${provider.negocioSeleccionadoNombre ?? "Negocio"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                Text(
                  '${provider.componentesTopologia.length} componentes • ${provider.conexionesDatos.length} conexiones de datos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
          if (provider.problemasTopologia.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.problemasTopologia.length} alertas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3, end: 0);
  }

  Widget _buildAdvancedControls(ComponentesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Selector de vista
          Expanded(
            child: Row(
              children: [
                Text(
                  'Vista:',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                _buildViewButton('network', 'Diagrama Interactivo', Icons.hub),
                const SizedBox(width: 8),
                _buildViewButton('rack', 'Vista Rack', Icons.dns),
                const SizedBox(width: 8),
                _buildViewButton('floor', 'Plano de Planta', Icons.map),
              ],
            ),
          ),

          // Información de componentes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen:',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip('MDF', provider.getComponentesMDF().length,
                        Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatChip('IDF', provider.getComponentesIDF().length,
                        Colors.green),
                    const SizedBox(width: 8),
                    _buildStatChip('Switch',
                        provider.getComponentesSwitch().length, Colors.purple),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Controles de la topología
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _refreshTopology(provider);
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar topología',
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppTheme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  dashboard.setZoomFactor(1.0);
                },
                icon: const Icon(Icons.center_focus_strong),
                tooltip: 'Centrar vista',
                style: IconButton.styleFrom(
                  backgroundColor:
                      AppTheme.of(context).primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildViewButton(String value, String label, IconData icon) {
    final isSelected = _selectedView == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).primaryColor
                : AppTheme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected ? Colors.white : AppTheme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTopologyView(
      bool isMediumScreen, ComponentesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // Fondo oscuro profesional tipo GitHub
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Vista según selección
            if (_selectedView == 'network')
              _buildInteractiveFlowChart(provider)
            else if (_selectedView == 'rack')
              _buildRackView(isMediumScreen, provider)
            else if (_selectedView == 'floor')
              _buildFloorPlanView(isMediumScreen, provider),

            // Leyenda profesional
            if (isMediumScreen && _selectedView == 'network')
              Positioned(
                top: 16,
                right: 16,
                child: _buildProfessionalLegend(),
              ),

            // Panel de información
            if (_selectedView == 'network')
              Positioned(
                top: 16,
                left: 16,
                child: _buildInfoPanel(provider),
              ),

            // Panel de problemas si existen
            if (provider.problemasTopologia.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                child: _buildProblemasPanel(provider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFlowChart(ComponentesProvider provider) {
    return FutureBuilder(
      future: _buildNetworkTopologyFromData(provider),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return FlowChart(
          dashboard: dashboard,
          onElementPressed: (context, position, element) {
            _showElementDetails(element, provider);
          },
          onElementLongPressed: (context, position, element) {
            _showElementContextMenu(context, position, element, provider);
          },
          onNewConnection: (source, target) {
            _handleNewConnection(source, target, provider);
          },
          onDashboardTapped: (context, position) {
            // Limpiar selecciones
          },
        )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  Future<void> _buildNetworkTopologyFromData(
      ComponentesProvider provider) async {
    dashboard.removeAllElements();
    elementosMap.clear();

    // Obtener componentes organizados por tipo
    final mdfComponents = provider.getComponentesMDF();
    final idfComponents = provider.getComponentesIDF();
    final switchComponents = provider.getComponentesSwitch();
    final routerComponents = provider.getComponentesRouter();
    final serverComponents = provider.getComponentesServidor();

    print('Construyendo topología con datos reales:');
    print('- MDF: ${mdfComponents.length}');
    print('- IDF: ${idfComponents.length}');
    print('- Switches: ${switchComponents.length}');
    print('- Routers: ${routerComponents.length}');
    print('- Servidores: ${serverComponents.length}');

    double currentX = 100;
    double currentY = 100;
    const double espacioX = 220;
    const double espacioY = 180;

    // 1. Crear elementos MDF
    if (mdfComponents.isNotEmpty) {
      double mdfX = currentX + espacioX * 2;
      for (var mdfComp in mdfComponents) {
        final mdfElement = _createMDFElement(mdfComp, Offset(mdfX, currentY));
        dashboard.addElement(mdfElement);
        elementosMap[mdfComp.id] = mdfElement;
        mdfX += espacioX * 0.8;
      }
      currentY += espacioY;
    }

    // 2. Crear elementos IDF
    if (idfComponents.isNotEmpty) {
      double idfX = currentX;
      for (var idfComp in idfComponents) {
        final idfElement = _createIDFElement(idfComp, Offset(idfX, currentY));
        dashboard.addElement(idfElement);
        elementosMap[idfComp.id] = idfElement;
        idfX += espacioX;
      }
      currentY += espacioY;
    }

    // 3. Crear routers
    if (routerComponents.isNotEmpty) {
      double routerX = currentX;
      for (var router in routerComponents) {
        final routerElement =
            _createRouterElement(router, Offset(routerX, currentY));
        dashboard.addElement(routerElement);
        elementosMap[router.id] = routerElement;
        routerX += espacioX * 0.9;
      }
      currentY += espacioY;
    }

    // 4. Crear switches
    if (switchComponents.isNotEmpty) {
      double switchX = currentX;
      for (var switchComp in switchComponents) {
        final switchElement =
            _createSwitchElement(switchComp, Offset(switchX, currentY));
        dashboard.addElement(switchElement);
        elementosMap[switchComp.id] = switchElement;
        switchX += espacioX * 0.8;
      }
      currentY += espacioY;
    }

    // 5. Crear servidores
    if (serverComponents.isNotEmpty) {
      double serverX = currentX + espacioX;
      for (var servidor in serverComponents) {
        final serverElement =
            _createServerElement(servidor, Offset(serverX, currentY));
        dashboard.addElement(serverElement);
        elementosMap[servidor.id] = serverElement;
        serverX += espacioX * 0.8;
      }
    }

    // 6. Crear conexiones basadas en datos reales
    _createConnections(provider);

    print('Elementos creados: ${elementosMap.length}');
    print(
        'Conexiones de datos disponibles: ${provider.conexionesDatos.length}');
  }

  FlowElement _createMDFElement(
      ComponenteTopologia component, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(180, 140),
      text: 'MDF\n${component.nombre}',
      textColor: Colors.white,
      textSize: 14,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor:
          component.activo ? const Color(0xFF2196F3) : const Color(0xFF757575),
      borderColor:
          component.activo ? const Color(0xFF1976D2) : const Color(0xFF424242),
      borderThickness: 3,
      elevation: component.activo ? 8 : 4,
      data: _buildElementData(component, 'MDF'),
      handlers: [
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createIDFElement(
      ComponenteTopologia component, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(160, 120),
      text: 'IDF\n${component.nombre}',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: component.activo
          ? (component.enUso
              ? const Color(0xFF4CAF50)
              : const Color(0xFFFF9800))
          : const Color(0xFF757575),
      borderColor: component.activo
          ? (component.enUso
              ? const Color(0xFF388E3C)
              : const Color(0xFFF57C00))
          : const Color(0xFF424242),
      borderThickness: 2,
      elevation: component.activo ? 6 : 2,
      data: _buildElementData(component, 'IDF'),
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createSwitchElement(
      ComponenteTopologia component, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(140, 100),
      text: 'Switch\n${component.nombre}',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor:
          component.activo ? const Color(0xFF9C27B0) : const Color(0xFF757575),
      borderColor:
          component.activo ? const Color(0xFF7B1FA2) : const Color(0xFF424242),
      borderThickness: 2,
      elevation: component.activo ? 4 : 2,
      data: _buildElementData(component, 'Switch'),
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
      ],
    );
  }

  FlowElement _createRouterElement(
      ComponenteTopologia component, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(160, 100),
      text: 'Router\n${component.nombre}',
      textColor: Colors.white,
      textSize: 11,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor:
          component.activo ? const Color(0xFFFF5722) : const Color(0xFF757575),
      borderColor:
          component.activo ? const Color(0xFFE64A19) : const Color(0xFF424242),
      borderThickness: 3,
      elevation: component.activo ? 6 : 2,
      data: _buildElementData(component, 'Router'),
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createServerElement(
      ComponenteTopologia component, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(150, 100),
      text: 'Servidor\n${component.nombre}',
      textColor: Colors.white,
      textSize: 11,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor:
          component.activo ? const Color(0xFFE91E63) : const Color(0xFF757575),
      borderColor:
          component.activo ? const Color(0xFFC2185B) : const Color(0xFF424242),
      borderThickness: 3,
      elevation: component.activo ? 6 : 2,
      data: _buildElementData(component, 'Server'),
      handlers: [
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  Map<String, dynamic> _buildElementData(
      ComponenteTopologia component, String displayType) {
    return {
      'type': displayType,
      'componenteId': component.id,
      'name': component.nombre,
      'categoria': component.categoria,
      'status': component.activo
          ? (component.enUso ? 'active' : 'warning')
          : 'disconnected',
      'description': component.descripcion ?? 'Sin descripción',
      'ubicacion': component.ubicacion ?? 'Sin ubicación',
      'distribucion': component.nombreDistribucion ?? 'Sin distribución',
      'tipoDistribucion': component.tipoDistribucion,
      'enUso': component.enUso,
      'fechaRegistro': component.fechaRegistro.toString().split(' ')[0],
    };
  }

  void _createConnections(ComponentesProvider provider) {
    // Crear conexiones basadas en los datos reales
    for (var conexion in provider.conexionesDatos) {
      if (!conexion.activo) continue;

      final sourceElement = elementosMap[conexion.componenteOrigenId];
      final targetElement = elementosMap[conexion.componenteDestinoId];

      if (sourceElement != null && targetElement != null) {
        // Determinar color y grosor basado en el tipo de conexión
        Color connectionColor = _getConnectionColor(conexion, provider);
        double thickness = _getConnectionThickness(conexion, provider);

        final connectionParams = ConnectionParams(
          destElementId: targetElement.id,
          arrowParams: ArrowParams(
            color: connectionColor,
            thickness: thickness,
          ),
        );

        sourceElement.next = [...sourceElement.next ?? [], connectionParams];
      }
    }

    // También crear conexiones de energía si es necesario
    for (var conexionEnergia in provider.conexionesEnergia) {
      if (!conexionEnergia.activo) continue;

      final sourceElement = elementosMap[conexionEnergia.origenId];
      final targetElement = elementosMap[conexionEnergia.destinoId];

      if (sourceElement != null && targetElement != null) {
        final connectionParams = ConnectionParams(
          destElementId: targetElement.id,
          arrowParams: ArrowParams(
            color: Colors.red.withOpacity(0.7),
            thickness: 2,
          ),
        );

        sourceElement.next = [...sourceElement.next ?? [], connectionParams];
      }
    }
  }

  Color _getConnectionColor(
      ConexionDatos conexion, ComponentesProvider provider) {
    // Determinar color basado en el tipo de cable o componentes conectados
    if (conexion.nombreCable != null) {
      final cableName = conexion.nombreCable!.toLowerCase();
      if (cableName.contains('fibra')) return Colors.cyan;
      if (cableName.contains('utp')) return Colors.yellow;
      if (cableName.contains('coaxial')) return Colors.orange;
    }

    // Color por defecto basado en los componentes
    final sourceComponent =
        provider.getComponenteTopologiaById(conexion.componenteOrigenId);
    final targetComponent =
        provider.getComponenteTopologiaById(conexion.componenteDestinoId);

    if (sourceComponent?.esMDF == true || targetComponent?.esMDF == true) {
      return Colors.cyan; // Conexiones principales
    }
    if (sourceComponent?.esIDF == true || targetComponent?.esIDF == true) {
      return Colors.yellow; // Conexiones intermedias
    }

    return Colors.green; // Conexiones generales
  }

  double _getConnectionThickness(
      ConexionDatos conexion, ComponentesProvider provider) {
    final sourceComponent =
        provider.getComponenteTopologiaById(conexion.componenteOrigenId);
    final targetComponent =
        provider.getComponenteTopologiaById(conexion.componenteDestinoId);

    if (sourceComponent?.esMDF == true || targetComponent?.esMDF == true) {
      return 4; // Conexiones principales más gruesas
    }
    if (sourceComponent?.esIDF == true || targetComponent?.esIDF == true) {
      return 3; // Conexiones intermedias
    }

    return 2; // Conexiones estándar
  }

  void _showElementDetails(FlowElement element, ComponentesProvider provider) {
    final data = element.data as Map<String, dynamic>;
    final componenteId = data['componenteId'] as String;
    final component = provider.getComponenteTopologiaById(componenteId);

    if (component == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).primaryBackground,
        title: Row(
          children: [
            Icon(_getIconForType(data['type']),
                color: _getColorForType(data['type'])),
            const SizedBox(width: 8),
            Expanded(child: Text(data['name'])),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Tipo', data['type']),
                _buildDetailRow('Categoría', component.categoria),
                _buildDetailRow('Estado', _getStatusText(data['status'])),
                _buildDetailRow('En Uso', component.enUso ? 'Sí' : 'No'),
                _buildDetailRow(
                    'Ubicación', component.ubicacion ?? 'Sin especificar'),
                if (component.tipoDistribucion != null)
                  _buildDetailRow('Distribución',
                      '${component.tipoDistribucion} - ${component.nombreDistribucion}'),
                _buildDetailRow('Fecha Registro',
                    component.fechaRegistro.toString().split(' ')[0]),
                const SizedBox(height: 16),
                const Text('Descripción:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(component.descripcion ?? 'Sin descripción'),
                const SizedBox(height: 16),
                _buildConnectionsInfo(component, provider),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildConnectionsInfo(
      ComponenteTopologia component, ComponentesProvider provider) {
    final conexiones = provider.getConexionesPorComponente(component.id);
    final conexionesEnergia =
        provider.getConexionesEnergiaPorComponente(component.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Conexiones:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (conexiones.isEmpty && conexionesEnergia.isEmpty)
          const Text('Sin conexiones registradas')
        else ...[
          if (conexiones.isNotEmpty) ...[
            const Text('Datos:', style: TextStyle(fontWeight: FontWeight.w500)),
            ...conexiones.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${c.nombreOrigen} ↔ ${c.nombreDestino}'),
                )),
          ],
          if (conexionesEnergia.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Energía:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            ...conexionesEnergia.map((c) => Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${c.nombreOrigen} → ${c.nombreDestino}'),
                )),
          ],
        ],
      ],
    );
  }

  void _showElementContextMenu(BuildContext context, Offset position,
      FlowElement element, ComponentesProvider provider) {
    // TODO: Implementar menú contextual con opciones reales
  }

  void _handleNewConnection(
      FlowElement source, FlowElement target, ComponentesProvider provider) {
    // TODO: Implementar creación de nueva conexión en la base de datos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Conexión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Conectar desde: ${(source.data as Map)['name']}'),
            Text('Hacia: ${(target.data as Map)['name']}'),
            const SizedBox(height: 16),
            const Text('Funcionalidad próximamente...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leyenda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(const Color(0xFF2196F3), 'MDF', Icons.router),
          _buildLegendItem(const Color(0xFF4CAF50), 'IDF Activo', Icons.hub),
          _buildLegendItem(
              const Color(0xFFFF9800), 'IDF Advertencia', Icons.hub),
          _buildLegendItem(
              const Color(0xFF9C27B0), 'Switch', Icons.network_check),
          _buildLegendItem(const Color(0xFFFF5722), 'Router', Icons.router),
          _buildLegendItem(const Color(0xFFE91E63), 'Servidor', Icons.dns),
          const SizedBox(height: 6),
          _buildLegendItem(Colors.cyan, 'Fibra Óptica', Icons.cable),
          _buildLegendItem(Colors.yellow, 'Cable UTP', Icons.cable),
          _buildLegendItem(Colors.green, 'Conexión General', Icons.cable),
          _buildLegendItem(Colors.red, 'Alimentación', Icons.power),
          _buildLegendItem(Colors.grey, 'Inactivo', Icons.clear),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms).slideX(begin: 0.3);
  }

  Widget _buildLegendItem(Color color, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(ComponentesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Arrastra los nodos para reposicionar',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const Text(
            '• Haz clic en un nodo para ver detalles',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const Text(
            '• Usa zoom con scroll del mouse',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 8),
          Text(
            'Datos desde: ${provider.negocioSeleccionadoNombre}',
            style: const TextStyle(color: Colors.cyan, fontSize: 9),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideX(begin: -0.3);
  }

  Widget _buildProblemasPanel(ComponentesProvider provider) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                'Alertas de Topología',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...provider.problemasTopologia.take(3).map((problema) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $problema',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              )),
          if (provider.problemasTopologia.length > 3)
            Text(
              '... y ${provider.problemasTopologia.length - 3} más',
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.3);
  }

  Widget _buildRackView(bool isMediumScreen, ComponentesProvider provider) {
    return RackViewWidget(
      isMediumScreen: isMediumScreen,
      provider: provider,
    );
  }

  Widget _buildFloorPlanView(
      bool isMediumScreen, ComponentesProvider provider) {
    return FloorPlanViewWidget(
      isMediumScreen: isMediumScreen,
      provider: provider,
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'MDF':
        return Icons.router;
      case 'IDF':
        return Icons.hub;
      case 'Switch':
        return Icons.network_check;
      case 'Server':
        return Icons.dns;
      case 'Router':
        return Icons.router;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'MDF':
        return const Color(0xFF2196F3);
      case 'IDF':
        return const Color(0xFF4CAF50);
      case 'Switch':
        return const Color(0xFF9C27B0);
      case 'Server':
        return const Color(0xFFE91E63);
      case 'Router':
        return const Color(0xFFFF5722);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return '🟢 Activo';
      case 'warning':
        return '🟡 Advertencia';
      case 'error':
        return '🔴 Error';
      case 'disconnected':
        return '⚫ Desconectado';
      default:
        return '❓ Desconocido';
    }
  }

  Future<void> _loadTopologyData() async {
    final provider = Provider.of<ComponentesProvider>(context, listen: false);

    if (provider.negocioSeleccionadoId != null) {
      setState(() {
        _isLoading = true;
      });

      await provider.getTopologiaPorNegocio(provider.negocioSeleccionadoId!);

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTopology(ComponentesProvider provider) async {
    if (provider.negocioSeleccionadoId != null) {
      setState(() {
        _isLoading = true;
      });

      await provider.getTopologiaPorNegocio(provider.negocioSeleccionadoId!);

      setState(() {
        _isLoading = false;
      });
    }
  }
}
