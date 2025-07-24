import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/models/nethive/conexion_componente_model.dart';

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

  // Elementos para referencias
  late FlowElement mdfElement;
  late FlowElement idf1Element;
  late FlowElement idf2Element;
  late FlowElement switch1Element;
  late FlowElement switch2Element;
  late FlowElement switch3Element;
  late FlowElement switch4Element;
  late FlowElement serverElement;

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
      _loadRealTopologyData();
    });
  }

  void _initializeDashboard() {
    dashboard = Dashboard(
      blockDefaultZoomGestures: false,
      minimumZoomFactor: 0.25,
    );
  }

  void _buildNetworkTopology() {
    dashboard.removeAllElements();

    // MDF Principal
    mdfElement = FlowElement(
      position: const Offset(400, 100),
      size: const Size(160, 120),
      text: 'MDF\nPrincipal',
      textColor: Colors.white,
      textSize: 14,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF2196F3),
      borderColor: const Color(0xFF1976D2),
      borderThickness: 3,
      elevation: 8,
      data: {
        'type': 'MDF',
        'name': 'MDF Principal',
        'status': 'active',
        'ports': '2/48',
        'description':
            'Main Distribution Frame\nSwitch Principal 48p\nPatch Panel 48p\nUPS Respaldo'
      },
      handlers: [
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );

    // IDF 1
    idf1Element = FlowElement(
      position: const Offset(200, 300),
      size: const Size(140, 100),
      text: 'IDF 1\nPiso 1',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF4CAF50),
      borderColor: const Color(0xFF388E3C),
      borderThickness: 2,
      elevation: 6,
      data: {
        'type': 'IDF',
        'name': 'IDF Piso 1',
        'status': 'active',
        'ports': '32/48',
        'description':
            'Intermediate Distribution Frame\nSwitch 48p\nPatch Panel\nUPS'
      },
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );

    // IDF 2
    idf2Element = FlowElement(
      position: const Offset(600, 300),
      size: const Size(140, 100),
      text: 'IDF 2\nPiso 2',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFFFF9800),
      borderColor: const Color(0xFFF57C00),
      borderThickness: 2,
      elevation: 6,
      data: {
        'type': 'IDF',
        'name': 'IDF Piso 2',
        'status': 'warning',
        'ports': '45/48',
        'description':
            'Intermediate Distribution Frame\nSwitch 48p\nPatch Panel\nUPS\n⚠️ Alta utilización'
      },
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );

    // Switches de Acceso
    switch1Element = FlowElement(
      position: const Offset(125, 500),
      size: const Size(120, 80),
      text: 'Switch\nAcceso A1',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF9C27B0),
      borderColor: const Color(0xFF7B1FA2),
      borderThickness: 2,
      elevation: 4,
      data: {
        'type': 'AccessSwitch',
        'name': 'Switch Acceso A1',
        'status': 'active',
        'ports': '16/24',
        'description': 'Switch de Acceso\n24 puertos\nEn línea'
      },
      handlers: [
        Handler.topCenter,
      ],
    );

    switch2Element = FlowElement(
      position: const Offset(275, 500),
      size: const Size(120, 80),
      text: 'Switch\nAcceso A2',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF9C27B0),
      borderColor: const Color(0xFF7B1FA2),
      borderThickness: 2,
      elevation: 4,
      data: {
        'type': 'AccessSwitch',
        'name': 'Switch Acceso A2',
        'status': 'active',
        'ports': '20/24',
        'description': 'Switch de Acceso\n24 puertos\nEn línea'
      },
      handlers: [
        Handler.topCenter,
      ],
    );

    switch3Element = FlowElement(
      position: const Offset(525, 500),
      size: const Size(120, 80),
      text: 'Switch\nAcceso B1',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF9C27B0),
      borderColor: const Color(0xFF7B1FA2),
      borderThickness: 2,
      elevation: 4,
      data: {
        'type': 'AccessSwitch',
        'name': 'Switch Acceso B1',
        'status': 'active',
        'ports': '18/24',
        'description': 'Switch de Acceso\n24 puertos\nEn línea'
      },
      handlers: [
        Handler.topCenter,
      ],
    );

    switch4Element = FlowElement(
      position: const Offset(675, 500),
      size: const Size(120, 80),
      text: 'Switch\nAcceso B2',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: false,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF757575),
      borderColor: const Color(0xFF424242),
      borderThickness: 2,
      elevation: 2,
      data: {
        'type': 'AccessSwitch',
        'name': 'Switch Acceso B2',
        'status': 'disconnected',
        'ports': '0/24',
        'description': 'Switch de Acceso\n24 puertos\n🔴 Desconectado'
      },
      handlers: [
        Handler.topCenter,
      ],
    );

    // Servidor Principal
    serverElement = FlowElement(
      position: const Offset(400, 650),
      size: const Size(150, 90),
      text: 'Servidor\nPrincipal',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFFE91E63),
      borderColor: const Color(0xFFC2185B),
      borderThickness: 3,
      elevation: 6,
      data: {
        'type': 'Server',
        'name': 'Servidor Principal',
        'status': 'active',
        'description':
            'Servidor Principal\nWindows Server 2022\nRAM: 32GB\nStorage: 2TB SSD'
      },
      handlers: [
        Handler.topCenter,
      ],
    );

    // Agregar elementos al dashboard
    dashboard.addElement(mdfElement);
    dashboard.addElement(idf1Element);
    dashboard.addElement(idf2Element);
    dashboard.addElement(switch1Element);
    dashboard.addElement(switch2Element);
    dashboard.addElement(switch3Element);
    dashboard.addElement(switch4Element);
    dashboard.addElement(serverElement);

    // Crear conexiones
    _createConnections();
  }

  void _createConnections() {
    // MDF -> IDF1 (Fibra)
    mdfElement.next = [
      ConnectionParams(
        destElementId: idf1Element.id,
        arrowParams: ArrowParams(
          color: Colors.cyan,
          thickness: 4,
        ),
      ),
    ];

    // MDF -> IDF2 (Fibra)
    mdfElement.next = [
      ...mdfElement.next ?? [],
      ConnectionParams(
        destElementId: idf2Element.id,
        arrowParams: ArrowParams(
          color: Colors.cyan,
          thickness: 4,
        ),
      ),
    ];

    // IDF1 -> Switch A1 (UTP)
    idf1Element.next = [
      ConnectionParams(
        destElementId: switch1Element.id,
        arrowParams: ArrowParams(
          color: Colors.yellow,
          thickness: 3,
        ),
      ),
    ];

    // IDF1 -> Switch A2 (UTP)
    idf1Element.next = [
      ...idf1Element.next ?? [],
      ConnectionParams(
        destElementId: switch2Element.id,
        arrowParams: ArrowParams(
          color: Colors.yellow,
          thickness: 3,
        ),
      ),
    ];

    // IDF2 -> Switch B1 (UTP)
    idf2Element.next = [
      ConnectionParams(
        destElementId: switch3Element.id,
        arrowParams: ArrowParams(
          color: Colors.yellow,
          thickness: 3,
        ),
      ),
    ];

    // IDF2 -> Switch B2 (UTP - Desconectado)
    idf2Element.next = [
      ...idf2Element.next ?? [],
      ConnectionParams(
        destElementId: switch4Element.id,
        arrowParams: ArrowParams(
          color: Colors.grey,
          thickness: 2,
        ),
      ),
    ];

    // MDF -> Servidor (Dedicado)
    mdfElement.next = [
      ...mdfElement.next ?? [],
      ConnectionParams(
        destElementId: serverElement.id,
        arrowParams: ArrowParams(
          color: Colors.purple,
          thickness: 5,
        ),
      ),
    ];
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
          if (_isLoading) {
            return _buildLoadingView();
          }

          return Container(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header profesional
                _buildProfessionalHeader(),
                const SizedBox(height: 24),

                // Controles avanzados
                if (isMediumScreen) ...[
                  _buildAdvancedControls(),
                  const SizedBox(height: 24),
                ],

                // Vista principal profesional
                Expanded(
                  child: _buildProfessionalTopologyView(isMediumScreen),
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
            'Construyendo infraestructura profesional',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildProfessionalHeader() {
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
          )
              .animate()
              .scale(duration: 600.ms)
              .then(delay: 200.ms)
              .rotate(begin: 0, end: 0.1)
              .then()
              .rotate(begin: 0.1, end: 0),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Topología Interactiva de Red',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3, end: 0),
                Text(
                  'Diagrama profesional con flutter_flow_chart',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.3, end: 0),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'FLOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(delay: 700.ms).scale(),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.3, end: 0);
  }

  Widget _buildAdvancedControls() {
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

          // Controles de la topología
          Row(
            children: [
              Text(
                'Controles:',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  setState(() {
                    _buildNetworkTopology();
                  });
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar topología',
              ),
              IconButton(
                onPressed: () {
                  dashboard.setZoomFactor(1.0);
                },
                icon: const Icon(Icons.center_focus_strong),
                tooltip: 'Centrar vista',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0);
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

  Widget _buildProfessionalTopologyView(bool isMediumScreen) {
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
              _buildInteractiveFlowChart()
            else if (_selectedView == 'rack')
              _buildRackView(isMediumScreen)
            else if (_selectedView == 'floor')
              _buildFloorPlanView(isMediumScreen),

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
                child: _buildInfoPanel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFlowChart() {
    return FlowChart(
      dashboard: dashboard,
      onElementPressed: (context, position, element) {
        _showElementDetails(element);
      },
      onElementLongPressed: (context, position, element) {
        _showElementContextMenu(context, position, element);
      },
      onNewConnection: (source, target) {
        _handleNewConnection(source, target);
      },
      onDashboardTapped: (context, position) {
        // Limpiar selecciones
      },
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95));
  }

  void _showElementDetails(FlowElement element) {
    final data = element.data as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: ${data['type']}'),
              const SizedBox(height: 8),
              Text('Estado: ${_getStatusText(data['status'])}'),
              if (data['ports'] != null) ...[
                const SizedBox(height: 8),
                Text('Puertos: ${data['ports']}'),
              ],
              const SizedBox(height: 12),
              const Text('Descripción:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(data['description']),
            ],
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

  void _showElementContextMenu(
      BuildContext context, Offset position, FlowElement element) {
    // Implementar menú contextual
  }

  void _handleNewConnection(FlowElement source, FlowElement target) {
    // Mostrar diálogo para configurar nueva conexión
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
            const Text('Seleccione el tipo de conexión:'),
            // Aquí podrías agregar controles para seleccionar tipo de cable
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Crear la conexión manualmente
              final newConnection = ConnectionParams(
                destElementId: target.id,
                arrowParams: ArrowParams(
                  color: Colors.green,
                  thickness: 3,
                ),
              );

              source.next = [...source.next ?? [], newConnection];
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('Conectar'),
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
              const Color(0xFF9C27B0), 'Switch Acceso', Icons.network_check),
          _buildLegendItem(const Color(0xFFE91E63), 'Servidor', Icons.dns),
          const SizedBox(height: 6),
          _buildLegendItem(Colors.cyan, 'Fibra Óptica', Icons.cable),
          _buildLegendItem(Colors.yellow, 'Cable UTP', Icons.cable),
          _buildLegendItem(Colors.purple, 'Conexión Dedicada', Icons.cable),
          _buildLegendItem(Colors.grey, 'Desconectado', Icons.cable),
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

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Arrastra los nodos para reposicionar',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            '• Haz clic en un nodo para ver detalles',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            '• Arrastra desde los puntos de conexión',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            '• Usa zoom con scroll del mouse',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms).slideX(begin: -0.3);
  }

  Widget _buildRackView(bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Text(
          'Vista de Racks - En desarrollo',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildFloorPlanView(bool isMediumScreen) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Text(
          'Plano de Planta - En desarrollo',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'MDF':
        return Icons.router;
      case 'IDF':
        return Icons.hub;
      case 'AccessSwitch':
        return Icons.network_check;
      case 'Server':
        return Icons.dns;
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
      case 'AccessSwitch':
        return const Color(0xFF9C27B0);
      case 'Server':
        return const Color(0xFFE91E63);
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

  Future<void> _loadRealTopologyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final componentesProvider =
          Provider.of<ComponentesProvider>(context, listen: false);

      // Verificar que hay un negocio seleccionado en el provider
      if (componentesProvider.negocioSeleccionadoId == null) {
        // Si no hay negocio seleccionado, mostrar mensaje
        setState(() {
          _isLoading = false;
        });
        _showNoBusinessSelectedDialog();
        return;
      }

      // Construir la topología con datos reales del negocio seleccionado
      await _buildRealNetworkTopology();
    } catch (e) {
      print('Error al cargar datos de topología: ${e.toString()}');
      _showErrorDialog('Error al cargar la topología: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buildRealNetworkTopology() async {
    dashboard.removeAllElements();

    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);

    // Obtener componentes agrupados por tipo
    final mdfComponents = componentesProvider.getComponentesPorTipo('mdf');
    final idfComponents = componentesProvider.getComponentesPorTipo('idf');
    final switchesAcceso = componentesProvider
        .getComponentesPorTipo('switch')
        .where((s) => !mdfComponents.contains(s) && !idfComponents.contains(s))
        .toList();
    final routers = componentesProvider.getComponentesPorTipo('router');
    final servidores = componentesProvider.getComponentesPorTipo('servidor');

    print('Componentes encontrados:');
    print('- MDF: ${mdfComponents.length}');
    print('- IDF: ${idfComponents.length}');
    print('- Switches de acceso: ${switchesAcceso.length}');
    print('- Routers: ${routers.length}');
    print('- Servidores: ${servidores.length}');

    double currentX = 100;
    double currentY = 100;
    const double espacioX = 200;
    const double espacioY = 150;

    Map<String, FlowElement> elementosMap = {};

    // Crear elementos MDF
    if (mdfComponents.isNotEmpty) {
      final mdfElement = _createMDFElement(
          mdfComponents, Offset(currentX + espacioX * 2, currentY));
      dashboard.addElement(mdfElement);
      elementosMap[mdfComponents.first.id] = mdfElement;
      currentY += espacioY;
    }

    // Crear elementos IDF
    double idfX = currentX;
    for (var idfComp in idfComponents) {
      final idfElement =
          _createIDFElement(idfComp, Offset(idfX, currentY + espacioY));
      dashboard.addElement(idfElement);
      elementosMap[idfComp.id] = idfElement;
      idfX += espacioX;
    }

    // Crear switches de acceso
    double switchX = currentX;
    currentY += espacioY * 2;
    for (var switchComp in switchesAcceso) {
      final switchElement =
          _createSwitchElement(switchComp, Offset(switchX, currentY));
      dashboard.addElement(switchElement);
      elementosMap[switchComp.id] = switchElement;
      switchX += espacioX * 0.8;
    }

    // Crear servidores
    if (servidores.isNotEmpty) {
      currentY += espacioY;
      double serverX = currentX + espacioX;
      for (var servidor in servidores) {
        final serverElement =
            _createServerElement(servidor, Offset(serverX, currentY));
        dashboard.addElement(serverElement);
        elementosMap[servidor.id] = serverElement;
        serverX += espacioX * 0.8;
      }
    }

    // Crear routers/firewalls
    if (routers.isNotEmpty) {
      double routerX = currentX;
      for (var router in routers) {
        final routerElement = _createRouterElement(
            router, Offset(routerX, currentY - espacioY * 3));
        dashboard.addElement(routerElement);
        elementosMap[router.id] = routerElement;
        routerX += espacioX;
      }
    }

    // Crear conexiones basadas en la base de datos
    await _createRealConnections(elementosMap, componentesProvider);

    // Si no hay elementos reales, mostrar mensaje
    if (elementosMap.isEmpty) {
      _showNoComponentsMessage();
    }

    setState(() {});
  }

  FlowElement _createMDFElement(
      List<Componente> mdfComponents, Offset position) {
    final mainComponent = mdfComponents.first;
    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);
    final categoria =
        componentesProvider.getCategoriaById(mainComponent.categoriaId);

    return FlowElement(
      position: position,
      size: const Size(180, 140),
      text: 'MDF\n${mainComponent.nombre}',
      textColor: Colors.white,
      textSize: 14,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFF2196F3),
      borderColor: const Color(0xFF1976D2),
      borderThickness: 3,
      elevation: 8,
      data: {
        'type': 'MDF',
        'componenteId': mainComponent.id,
        'name': mainComponent.nombre,
        'status': mainComponent.activo ? 'active' : 'disconnected',
        'description': mainComponent.descripcion ?? 'Main Distribution Frame',
        'ubicacion': mainComponent.ubicacion ?? 'Sin ubicación',
        'categoria': categoria?.nombre ?? 'Sin categoría',
        'componentes': mdfComponents.length,
      },
      handlers: [
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createIDFElement(Componente idfComponent, Offset position) {
    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);
    final categoria =
        componentesProvider.getCategoriaById(idfComponent.categoriaId);

    return FlowElement(
      position: position,
      size: const Size(160, 120),
      text: 'IDF\n${idfComponent.nombre}',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: idfComponent.enUso
          ? const Color(0xFF4CAF50)
          : const Color(0xFFFF9800),
      borderColor: idfComponent.enUso
          ? const Color(0xFF388E3C)
          : const Color(0xFFF57C00),
      borderThickness: 2,
      elevation: 6,
      data: {
        'type': 'IDF',
        'componenteId': idfComponent.id,
        'name': idfComponent.nombre,
        'status': idfComponent.activo
            ? (idfComponent.enUso ? 'active' : 'warning')
            : 'disconnected',
        'description':
            idfComponent.descripcion ?? 'Intermediate Distribution Frame',
        'ubicacion': idfComponent.ubicacion ?? 'Sin ubicación',
        'categoria': categoria?.nombre ?? 'Sin categoría',
        'enUso': idfComponent.enUso,
      },
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createSwitchElement(
      Componente switchComponent, Offset position) {
    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);
    final categoria =
        componentesProvider.getCategoriaById(switchComponent.categoriaId);

    return FlowElement(
      position: position,
      size: const Size(140, 100),
      text: 'Switch\n${switchComponent.nombre}',
      textColor: Colors.white,
      textSize: 10,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: switchComponent.activo
          ? const Color(0xFF9C27B0)
          : const Color(0xFF757575),
      borderColor: switchComponent.activo
          ? const Color(0xFF7B1FA2)
          : const Color(0xFF424242),
      borderThickness: 2,
      elevation: switchComponent.activo ? 4 : 2,
      data: {
        'type': 'AccessSwitch',
        'componenteId': switchComponent.id,
        'name': switchComponent.nombre,
        'status': switchComponent.activo ? 'active' : 'disconnected',
        'description': switchComponent.descripcion ?? 'Switch de Acceso',
        'ubicacion': switchComponent.ubicacion ?? 'Sin ubicación',
        'categoria': categoria?.nombre ?? 'Sin categoría',
      },
      handlers: [
        Handler.topCenter,
      ],
    );
  }

  FlowElement _createServerElement(
      Componente serverComponent, Offset position) {
    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);
    final categoria =
        componentesProvider.getCategoriaById(serverComponent.categoriaId);

    return FlowElement(
      position: position,
      size: const Size(160, 100),
      text: 'Servidor\n${serverComponent.nombre}',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFFE91E63),
      borderColor: const Color(0xFFC2185B),
      borderThickness: 3,
      elevation: 6,
      data: {
        'type': 'Server',
        'componenteId': serverComponent.id,
        'name': serverComponent.nombre,
        'status': serverComponent.activo ? 'active' : 'disconnected',
        'description': serverComponent.descripcion ?? 'Servidor',
        'ubicacion': serverComponent.ubicacion ?? 'Sin ubicación',
        'categoria': categoria?.nombre ?? 'Sin categoría',
      },
      handlers: [
        Handler.topCenter,
      ],
    );
  }

  FlowElement _createRouterElement(
      Componente routerComponent, Offset position) {
    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);
    final categoria =
        componentesProvider.getCategoriaById(routerComponent.categoriaId);

    return FlowElement(
      position: position,
      size: const Size(160, 100),
      text: 'Router\n${routerComponent.nombre}',
      textColor: Colors.white,
      textSize: 12,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: const Color(0xFFFF5722),
      borderColor: const Color(0xFFD84315),
      borderThickness: 3,
      elevation: 6,
      data: {
        'type': 'Router',
        'componenteId': routerComponent.id,
        'name': routerComponent.nombre,
        'status': routerComponent.activo ? 'active' : 'disconnected',
        'description': routerComponent.descripcion ?? 'Router/Firewall',
        'ubicacion': routerComponent.ubicacion ?? 'Sin ubicación',
        'categoria': categoria?.nombre ?? 'Sin categoría',
      },
      handlers: [
        Handler.bottomCenter,
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  Future<void> _createRealConnections(Map<String, FlowElement> elementosMap,
      ComponentesProvider componentesProvider) async {
    // Obtener conexiones reales de la base de datos
    final conexiones = componentesProvider.conexiones;

    print('Creando ${conexiones.length} conexiones...');

    for (var conexion in conexiones) {
      final origenElement = elementosMap[conexion.componenteOrigenId];
      final destinoElement = elementosMap[conexion.componenteDestinoId];

      if (origenElement != null && destinoElement != null) {
        // Determinar el color y grosor de la conexión basado en los tipos de componentes
        final colorConexion =
            _getConnectionColor(conexion, componentesProvider);
        final grosorConexion =
            _getConnectionThickness(conexion, componentesProvider);

        print('Conectando: ${origenElement.text} -> ${destinoElement.text}');

        // Agregar la conexión al elemento origen
        origenElement.next = [
          ...origenElement.next ?? [],
          ConnectionParams(
            destElementId: destinoElement.id,
            arrowParams: ArrowParams(
              color: colorConexion,
              thickness: grosorConexion,
            ),
          ),
        ];
      }
    }

    // Si no hay conexiones en la BD, crear conexiones automáticas basadas en la ubicación
    if (conexiones.isEmpty) {
      print('No hay conexiones en BD, creando automáticas...');
      _createAutomaticConnections(elementosMap, componentesProvider);
    }
  }

  Color _getConnectionColor(
      ConexionComponente conexion, ComponentesProvider componentesProvider) {
    // Obtener los componentes origen y destino
    final origenComp =
        componentesProvider.getComponenteById(conexion.componenteOrigenId);
    final destinoComp =
        componentesProvider.getComponenteById(conexion.componenteDestinoId);

    if (origenComp == null || destinoComp == null) return Colors.grey;

    // Determinar el tipo de conexión basado en las ubicaciones
    final origenUbicacion = origenComp.ubicacion?.toUpperCase() ?? '';
    final destinoUbicacion = destinoComp.ubicacion?.toUpperCase() ?? '';

    // MDF a IDF = Fibra (cyan)
    if (origenUbicacion.contains('MDF') && destinoUbicacion.contains('IDF')) {
      return Colors.cyan;
    }

    // IDF a Switch = UTP (yellow)
    if (origenUbicacion.contains('IDF')) {
      return Colors.yellow;
    }

    // Servidor = Dedicado (purple)
    final origenCategoria =
        componentesProvider.getCategoriaById(origenComp.categoriaId);
    final destinoCategoria =
        componentesProvider.getCategoriaById(destinoComp.categoriaId);

    if ((origenCategoria?.nombre?.toLowerCase().contains('servidor') ??
            false) ||
        (destinoCategoria?.nombre?.toLowerCase().contains('servidor') ??
            false)) {
      return Colors.purple;
    }

    return Colors.green; // Por defecto
  }

  double _getConnectionThickness(
      ConexionComponente conexion, ComponentesProvider componentesProvider) {
    final origenComp =
        componentesProvider.getComponenteById(conexion.componenteOrigenId);
    final destinoComp =
        componentesProvider.getComponenteById(conexion.componenteDestinoId);

    if (origenComp == null || destinoComp == null) return 2.0;

    final origenUbicacion = origenComp.ubicacion?.toUpperCase() ?? '';
    final destinoUbicacion = destinoComp.ubicacion?.toUpperCase() ?? '';

    // Conexiones principales más gruesas
    if (origenUbicacion.contains('MDF') && destinoUbicacion.contains('IDF')) {
      return 4.0;
    }

    return conexion.activo ? 3.0 : 2.0;
  }

  void _createAutomaticConnections(Map<String, FlowElement> elementosMap,
      ComponentesProvider componentesProvider) {
    // Crear conexiones automáticas cuando no hay datos en la BD
    final mdfElements = elementosMap.values
        .where((e) => (e.data as Map)['type'] == 'MDF')
        .toList();
    final idfElements = elementosMap.values
        .where((e) => (e.data as Map)['type'] == 'IDF')
        .toList();
    final switchElements = elementosMap.values
        .where((e) => (e.data as Map)['type'] == 'AccessSwitch')
        .toList();

    print('Creando conexiones automáticas...');
    print(
        'MDF: ${mdfElements.length}, IDF: ${idfElements.length}, Switches: ${switchElements.length}');

    // Conectar MDF a IDFs
    for (var mdf in mdfElements) {
      for (var idf in idfElements) {
        mdf.next = [
          ...mdf.next ?? [],
          ConnectionParams(
            destElementId: idf.id,
            arrowParams: ArrowParams(
              color: Colors.cyan,
              thickness: 4,
            ),
          ),
        ];
      }
    }

    // Conectar IDFs a Switches
    for (int i = 0; i < idfElements.length && i < switchElements.length; i++) {
      final idf = idfElements[i];
      final switchesParaEsteIdf = switchElements.skip(i * 2).take(2);

      for (var switch_ in switchesParaEsteIdf) {
        idf.next = [
          ...idf.next ?? [],
          ConnectionParams(
            destElementId: switch_.id,
            arrowParams: ArrowParams(
              color: Colors.yellow,
              thickness: 3,
            ),
          ),
        ];
      }
    }
  }

  void _showNoComponentsMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sin componentes'),
        content: const Text(
          'No se encontraron componentes de red para este negocio.\n\n'
          'Para ver una topología completa, agregue componentes en el módulo de Inventario con ubicaciones como "MDF", "IDF", etc.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ir al módulo de inventario (esto depende de tu estructura de navegación)
              // context.go('/infrastructure/inventory');
            },
            child: const Text('Ir a Inventario'),
          ),
        ],
      ),
    );
  }

  void _showNoBusinessSelectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Negocio no seleccionado'),
        content: const Text(
          'No se ha seleccionado ningún negocio. Por favor, regrese a la página de negocios y seleccione "Acceder a Infraestructura" en la tabla.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Regresar a la página de empresas/negocios
              context.go('/empresa-negocios');
            },
            child: const Text('Ir a Negocios'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
