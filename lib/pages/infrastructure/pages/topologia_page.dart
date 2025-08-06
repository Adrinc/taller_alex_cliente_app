import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/models/nethive/topologia_completa_model.dart';
import 'package:nethive_neo/models/nethive/vista_topologia_por_negocio_model.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/topologia_page_widgets/rack_view_widget.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/topologia_page_widgets/floor_plan_view_widget.dart';
import 'package:nethive_neo/helpers/globals.dart';

// Clase para agrupar componentes por distribución
class DistribucionAgrupada {
  final String id;
  final String nombre;
  final String tipo;
  final List<VistaTopologiaPorNegocio> componentes;

  DistribucionAgrupada({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.componentes,
  });

  int get componentesActivos => componentes.where((c) => c.activo).length;
  int get componentesEnUso => componentes.where((c) => c.enUso).length;

  bool get esMDF => tipo.toUpperCase() == 'MDF';
  bool get esIDF => tipo.toUpperCase() == 'IDF';

  String get estadoDistribucion {
    if (componentesActivos == 0) return 'inactivo';
    if (componentesEnUso == componentesActivos) return 'optimo';
    if (componentesEnUso > 0) return 'parcial';
    return 'disponible';
  }
}

class TopologiaPage extends StatefulWidget {
  const TopologiaPage({super.key});

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
            const Icon(
              Icons.business,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Selecciona un Negocio',
              style: TextStyle(
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
    // Limpiar completamente el dashboard y mapa de elementos
    dashboard.removeAllElements();
    elementosMap.clear();

    // Asegurar que el dashboard esté completamente limpio
    await Future.delayed(const Duration(milliseconds: 50));

    // Cargar datos separando componentes con y sin distribución
    final topologiaOptimizada = await _cargarTopologiaOptimizada(provider);
    final componentesIndividuales =
        await _cargarComponentesSinDistribucion(provider);

    print('Construyendo topología:');
    print('- Distribuciones encontradas: ${topologiaOptimizada.length}');
    print(
        '- Componentes individuales (sin distribución): ${componentesIndividuales.length}');

    double currentX = 150;
    double currentY = 100;
    const double espacioX = 250;
    const double espacioY = 200;

    // Procesar distribuciones ordenadas por prioridad
    final distribucionesOrdenadas =
        _ordenarDistribucionesPorTipo(topologiaOptimizada);

    for (var distribucion in distribucionesOrdenadas) {
      print(
          '- ${distribucion.tipo}: ${distribucion.nombre} (${distribucion.componentes.length} componentes)');

      // Verificar que no existe ya un elemento con este ID
      if (elementosMap.containsKey(distribucion.id)) {
        print(
            'ADVERTENCIA: Distribución duplicada detectada: ${distribucion.id}');
        continue;
      }

      FlowElement elemento;

      if (distribucion.tipo == 'MDF') {
        elemento = _createDistribucionMDFElement(
            distribucion, Offset(currentX, currentY));
        currentY += espacioY;
      } else if (distribucion.tipo == 'IDF') {
        elemento = _createDistribucionIDFElement(
            distribucion, Offset(currentX, currentY));
        currentX += espacioX;

        // Si hay muchos IDF, pasar a la siguiente fila
        if (currentX > 800) {
          currentX = 150;
          currentY += espacioY;
        }
      } else {
        // Otros tipos de distribución
        elemento = _createDistribucionGeneralElement(
            distribucion, Offset(currentX, currentY));
        currentX += espacioX * 0.8;
      }

      dashboard.addElement(elemento);
      elementosMap[distribucion.id] = elemento;
    }

    // Agregar componentes individuales (sin distribución)
    for (var componente in componentesIndividuales) {
      print('- Componente individual: ${componente.componenteNombre}');

      // Verificar que no existe ya un elemento con este ID
      if (elementosMap.containsKey(componente.componenteId)) {
        print(
            'ADVERTENCIA: Componente duplicado detectado: ${componente.componenteId}');
        continue;
      }

      final elemento = _createComponenteIndividualElement(
          componente, Offset(currentX, currentY));

      dashboard.addElement(elemento);
      elementosMap[componente.componenteId] = elemento;

      currentX += espacioX * 0.7;

      // Si hay muchos componentes individuales, pasar a la siguiente fila
      if (currentX > 900) {
        currentX = 150;
        currentY += espacioY;
      }
    }

    // Crear conexiones entre distribuciones y componentes individuales
    _createDistributionConnections(
        provider, distribucionesOrdenadas, componentesIndividuales);

    print(
        'Elementos creados: ${elementosMap.length} (${distribucionesOrdenadas.length} distribuciones + ${componentesIndividuales.length} individuales)');
  }

  Future<List<DistribucionAgrupada>> _cargarTopologiaOptimizada(
      ComponentesProvider provider) async {
    try {
      final response = await supabaseLU
          .from('vista_topologia_por_negocio')
          .select()
          .eq('negocio_id', provider.negocioSeleccionadoId!)
          .not('distribucion_id', 'is',
              null) // Solo componentes CON distribución
          .order('tipo_distribucion')
          .order('distribucion_nombre');

      // Agrupar componentes por distribución
      final Map<String, DistribucionAgrupada> distribucionesMap = {};

      for (var item in response) {
        final vista = VistaTopologiaPorNegocio.fromMap(item);

        final distribId = vista.distribucionId!;
        final distribNombre = vista.distribucionNombre!;
        final distribTipo = vista.tipoDistribucion!;

        if (!distribucionesMap.containsKey(distribId)) {
          distribucionesMap[distribId] = DistribucionAgrupada(
            id: distribId,
            nombre: distribNombre,
            tipo: distribTipo,
            componentes: [],
          );
        }

        distribucionesMap[distribId]!.componentes.add(vista);
      }

      return distribucionesMap.values.toList();
    } catch (e) {
      print('Error al cargar distribuciones agrupadas: $e');
      return [];
    }
  }

  Future<List<VistaTopologiaPorNegocio>> _cargarComponentesSinDistribucion(
      ComponentesProvider provider) async {
    try {
      final response = await supabaseLU
          .from('vista_topologia_por_negocio')
          .select()
          .eq('negocio_id', provider.negocioSeleccionadoId!)
          .is_('distribucion_id', null) // Solo componentes SIN distribución
          .order('categoria_componente')
          .order('componente_nombre');

      return (response as List<dynamic>)
          .map((item) => VistaTopologiaPorNegocio.fromMap(item))
          .toList();
    } catch (e) {
      print('Error al cargar componentes individuales: $e');
      return [];
    }
  }

  FlowElement _createComponenteIndividualElement(
      VistaTopologiaPorNegocio componente, Offset position) {
    // Obtener colores basados en la categoría del componente
    final coloresComponente = _getColoresPorCategoria(
        componente.categoriaComponente, componente.colorCategoria);

    // Si el componente no está activo, usar colores grises
    Color backgroundColor = componente.activo
        ? coloresComponente['background']!
        : const Color(0xFF757575);
    Color borderColor = componente.activo
        ? coloresComponente['border']!
        : const Color(0xFF424242);

    // Crear texto del elemento con indicadores de estado
    final statusIcon =
        componente.activo ? (componente.enUso ? '🟢' : '🟡') : '🔴';

    final elementText = '${componente.componenteNombre}\n\n'
        'Categoría: ${componente.categoriaComponente}\n'
        'Estado: $statusIcon\n'
        '${componente.ubicacion ?? "Sin ubicación"}';

    return FlowElement(
      position: position,
      size: const Size(160, 140),
      text: elementText,
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderThickness: 2,
      elevation: 6,
      data: _buildComponenteIndividualElementData(componente),
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  Map<String, Color> _getColoresPorCategoria(
      String categoria, String? colorCategoria) {
    // Si la categoría tiene un color específico definido, usarlo
    if (colorCategoria != null && colorCategoria.isNotEmpty) {
      try {
        final colorHex = colorCategoria.replaceAll('#', '');
        final colorValue = int.parse('FF$colorHex', radix: 16);
        final backgroundColor = Color(colorValue);
        final borderColor = Color(colorValue).withOpacity(0.8);

        return {
          'background': backgroundColor,
          'border': borderColor,
        };
      } catch (e) {
        print('Error parsing color for category $categoria: $colorCategoria');
      }
    }

    // Colores por defecto basados en el nombre de la categoría
    final categoriaLower = categoria.toLowerCase();

    if (categoriaLower.contains('switch')) {
      return {
        'background': const Color(0xFF9C27B0), // Morado
        'border': const Color(0xFF7B1FA2),
      };
    } else if (categoriaLower.contains('router') ||
        categoriaLower.contains('firewall')) {
      return {
        'background': const Color(0xFFFF5722), // Naranja rojizo
        'border': const Color(0xFFE64A19),
      };
    } else if (categoriaLower.contains('servidor') ||
        categoriaLower.contains('server')) {
      return {
        'background': const Color(0xFFE91E63), // Rosa
        'border': const Color(0xFFC2185B),
      };
    } else if (categoriaLower.contains('patch') ||
        categoriaLower.contains('panel')) {
      return {
        'background': const Color(0xFF607D8B), // Azul gris
        'border': const Color(0xFF455A64),
      };
    } else if (categoriaLower.contains('rack')) {
      return {
        'background': const Color(0xFF795548), // Marrón
        'border': const Color(0xFF5D4037),
      };
    } else if (categoriaLower.contains('ups')) {
      return {
        'background': const Color(0xFFFFC107), // Amarillo
        'border': const Color(0xFFFFA000),
      };
    } else if (categoriaLower.contains('cable')) {
      return {
        'background': const Color(0xFF4CAF50), // Verde
        'border': const Color(0xFF388E3C),
      };
    } else if (categoriaLower.contains('organizador')) {
      return {
        'background': const Color(0xFF9E9E9E), // Gris
        'border': const Color(0xFF757575),
      };
    } else {
      return {
        'background': const Color(0xFF2196F3), // Azul por defecto
        'border': const Color(0xFF1976D2),
      };
    }
  }

  Map<String, dynamic> _buildComponenteIndividualElementData(
      VistaTopologiaPorNegocio componente) {
    return {
      'type': 'INDIVIDUAL',
      'componenteId': componente.componenteId,
      'name': componente.componenteNombre,
      'categoria': componente.categoriaComponente,
      'enUso': componente.enUso,
      'activo': componente.activo,
      'ubicacion': componente.ubicacion,
      'descripcion': componente.descripcion,
      'imagenUrl': componente.imagenUrl,
      'rfid': componente.rfid,
      'colorCategoria': componente.colorCategoria,
      'status': componente.activo
          ? (componente.enUso ? 'active' : 'available')
          : 'inactive',
    };
  }

  void _createDistributionConnections(
      ComponentesProvider provider,
      List<DistribucionAgrupada> distribuciones,
      List<VistaTopologiaPorNegocio> componentesIndividuales) {
    // Crear conexiones lógicas entre distribuciones
    final mdfDistribuciones =
        distribuciones.where((d) => d.tipo == 'MDF').toList();
    final idfDistribuciones =
        distribuciones.where((d) => d.tipo == 'IDF').toList();
    final otrasDistribuciones = distribuciones
        .where((d) => d.tipo != 'MDF' && d.tipo != 'IDF')
        .toList();

    // Conectar cada IDF con el MDF principal (si existe)
    if (mdfDistribuciones.isNotEmpty) {
      final mdfPrincipal = mdfDistribuciones.first;
      final mdfElement = elementosMap[mdfPrincipal.id];

      if (mdfElement != null) {
        for (var idf in idfDistribuciones) {
          final idfElement = elementosMap[idf.id];

          if (idfElement != null) {
            final connectionParams = ConnectionParams(
              destElementId: idfElement.id,
              arrowParams: ArrowParams(
                color: Colors.cyan,
                thickness: 3,
              ),
            );

            mdfElement.next = [...mdfElement.next, connectionParams];
          }
        }
      }
    }

    // Determinar el elemento principal para conectar otros elementos
    final distribucionPrincipal = mdfDistribuciones.isNotEmpty
        ? mdfDistribuciones.first
        : (idfDistribuciones.isNotEmpty ? idfDistribuciones.first : null);

    // Conectar otras distribuciones al elemento principal
    if (distribucionPrincipal != null && otrasDistribuciones.isNotEmpty) {
      final elementoPrincipal = elementosMap[distribucionPrincipal.id];

      if (elementoPrincipal != null) {
        for (var otra in otrasDistribuciones) {
          final otroElement = elementosMap[otra.id];

          if (otroElement != null) {
            final connectionParams = ConnectionParams(
              destElementId: otroElement.id,
              arrowParams: ArrowParams(
                color: Colors.yellow,
                thickness: 2,
              ),
            );

            elementoPrincipal.next = [
              ...elementoPrincipal.next,
              connectionParams
            ];
          }
        }
      }
    }

    // Conectar componentes individuales importantes al elemento principal
    if (distribucionPrincipal != null) {
      final elementoPrincipal = elementosMap[distribucionPrincipal.id];

      if (elementoPrincipal != null) {
        // Solo conectar componentes individuales importantes (switches, routers, servidores)
        final componentesImportantes = componentesIndividuales
            .where((c) =>
                c.tipoComponentePrincipal == 'switch' ||
                c.tipoComponentePrincipal == 'router' ||
                c.tipoComponentePrincipal == 'servidor')
            .toList();

        for (var componente in componentesImportantes) {
          final componenteElement = elementosMap[componente.componenteId];

          if (componenteElement != null) {
            final connectionParams = ConnectionParams(
              destElementId: componenteElement.id,
              arrowParams: ArrowParams(
                color: Colors.orange,
                thickness: 2,
              ),
            );

            elementoPrincipal.next = [
              ...elementoPrincipal.next,
              connectionParams
            ];
          }
        }
      }
    } else if (componentesIndividuales.isNotEmpty) {
      // Si no hay distribuciones principales, conectar entre componentes individuales importantes
      final switches = componentesIndividuales
          .where((c) => c.tipoComponentePrincipal == 'switch')
          .toList();
      final routers = componentesIndividuales
          .where((c) => c.tipoComponentePrincipal == 'router')
          .toList();

      // Conectar routers a switches si existen ambos
      if (routers.isNotEmpty && switches.isNotEmpty) {
        final routerPrincipal = routers.first;
        final routerElement = elementosMap[routerPrincipal.componenteId];

        if (routerElement != null) {
          for (var switchComp in switches) {
            final switchElement = elementosMap[switchComp.componenteId];

            if (switchElement != null) {
              final connectionParams = ConnectionParams(
                destElementId: switchElement.id,
                arrowParams: ArrowParams(
                  color: Colors.green,
                  thickness: 2,
                ),
              );

              routerElement.next = [...routerElement.next, connectionParams];
            }
          }
        }
      }
    }
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

  List<DistribucionAgrupada> _ordenarDistribucionesPorTipo(
      List<DistribucionAgrupada> distribuciones) {
    distribuciones.sort((a, b) {
      // Primero MDF, luego IDF, luego otros
      final prioridadA = _getPrioridadDistribucion(a.tipo);
      final prioridadB = _getPrioridadDistribucion(b.tipo);

      if (prioridadA != prioridadB) {
        return prioridadA.compareTo(prioridadB);
      }

      // Dentro del mismo tipo, ordenar por nombre
      return a.nombre.compareTo(b.nombre);
    });

    return distribuciones;
  }

  int _getPrioridadDistribucion(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'MDF':
        return 1;
      case 'IDF':
        return 2;
      default:
        return 3;
    }
  }

  FlowElement _createDistribucionMDFElement(
      DistribucionAgrupada distribucion, Offset position) {
    final componentesActivos =
        distribucion.componentes.where((c) => c.activo).length;
    final componentesEnUso =
        distribucion.componentes.where((c) => c.enUso).length;

    // Crear resumen de tipos de componentes
    final tiposComponentes =
        _getTiposComponentesResumen(distribucion.componentes);

    return FlowElement(
      position: position,
      size: const Size(200, 160),
      text:
          '${distribucion.tipo}\n${distribucion.nombre}\n\n${distribucion.componentes.length} componentes\n$tiposComponentes',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF1565C0), // Azul más oscuro para MDF
      borderColor: const Color(0xFF0D47A1),
      borderThickness: 4,
      elevation: 10,
      data: _buildDistribucionElementData(distribucion, 'MDF'),
      handlers: [
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createDistribucionIDFElement(
      DistribucionAgrupada distribucion, Offset position) {
    final componentesActivos =
        distribucion.componentes.where((c) => c.activo).length;
    final componentesEnUso =
        distribucion.componentes.where((c) => c.enUso).length;

    // Determinar estado del IDF basado en sus componentes
    Color backgroundColor;
    Color borderColor;

    if (componentesActivos == 0) {
      backgroundColor = const Color(0xFF757575); // Gris - inactivo
      borderColor = const Color(0xFF424242);
    } else if (componentesEnUso == componentesActivos) {
      backgroundColor = const Color(0xFF2E7D32); // Verde - todo en uso
      borderColor = const Color(0xFF1B5E20);
    } else if (componentesEnUso > 0) {
      backgroundColor =
          const Color(0xFFE65100); // Naranja - parcialmente en uso
      borderColor = const Color(0xFFBF360C);
    } else {
      backgroundColor =
          const Color(0xFFF57C00); // Amarillo - activo pero no en uso
      borderColor = const Color(0xFFE65100);
    }

    final tiposComponentes =
        _getTiposComponentesResumen(distribucion.componentes);

    return FlowElement(
      position: position,
      size: const Size(180, 140),
      text:
          '${distribucion.tipo}\n${distribucion.nombre}\n\n${distribucion.componentes.length} componentes\n$tiposComponentes',
      textColor: Colors.white,
      textSize: 11,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderThickness: 3,
      elevation: 8,
      data: _buildDistribucionElementData(distribucion, 'IDF'),
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createDistribucionGeneralElement(
      DistribucionAgrupada distribucion, Offset position) {
    final tiposComponentes =
        _getTiposComponentesResumen(distribucion.componentes);

    return FlowElement(
      position: position,
      size: const Size(160, 120),
      text:
          '${distribucion.nombre}\n\n${distribucion.componentes.length} componentes\n$tiposComponentes',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF5D4037), // Marrón para otros
      borderColor: const Color(0xFF3E2723),
      borderThickness: 2,
      elevation: 6,
      data: _buildDistribucionElementData(distribucion, 'OTRO'),
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
      ],
    );
  }

  String _getTiposComponentesResumen(
      List<VistaTopologiaPorNegocio> componentes) {
    final Map<String, int> conteoTipos = {};

    for (var componente in componentes.where((c) => c.activo)) {
      final tipo = _getTipoComponenteSimplificado(componente);
      conteoTipos[tipo] = (conteoTipos[tipo] ?? 0) + 1;
    }

    // Mostrar solo los 3 tipos más comunes
    final tiposOrdenados = conteoTipos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final resumen = tiposOrdenados
        .take(3)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');

    return resumen.isNotEmpty ? resumen : 'Sin componentes';
  }

  String _getTipoComponenteSimplificado(VistaTopologiaPorNegocio componente) {
    final categoria = componente.categoriaComponente.toLowerCase();
    final nombre = componente.componenteNombre.toLowerCase();

    if (categoria.contains('switch') || nombre.contains('switch')) return 'SW';
    if (categoria.contains('router') ||
        nombre.contains('router') ||
        categoria.contains('firewall')) return 'RT';
    if (categoria.contains('patch') || nombre.contains('patch')) return 'PP';
    if (categoria.contains('rack') || nombre.contains('rack')) return 'RK';
    if (categoria.contains('ups') || nombre.contains('ups')) return 'UPS';
    if (categoria.contains('cable') || nombre.contains('cable')) return 'CBL';
    if (categoria.contains('servidor') || nombre.contains('servidor'))
      return 'SRV';

    return 'OTR';
  }

  Map<String, dynamic> _buildDistribucionElementData(
      DistribucionAgrupada distribucion, String displayType) {
    return {
      'type': displayType,
      'distribucionId': distribucion.id,
      'name': distribucion.nombre,
      'tipoDistribucion': distribucion.tipo,
      'componentCount': distribucion.componentes.length,
      'activeComponents':
          distribucion.componentes.where((c) => c.activo).length,
      'usedComponents': distribucion.componentes.where((c) => c.enUso).length,
      'componentes': distribucion.componentes,
      'ubicaciones': distribucion.componentes
          .map((c) => c.ubicacion)
          .where((u) => u != null)
          .toSet()
          .join(', '),
    };
  }
}
