import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/models/nethive/vista_topologia_por_negocio_model.dart';
import 'package:nethive_neo/models/nethive/vista_conexiones_por_cables_model.dart';

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
    mdfElement.next!.add(
      ConnectionParams(
        destElementId: idf2Element.id,
        arrowParams: ArrowParams(
          color: Colors.cyan,
          thickness: 4,
        ),
      ),
    );

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
    idf1Element.next!.add(
      ConnectionParams(
        destElementId: switch2Element.id,
        arrowParams: ArrowParams(
          color: Colors.yellow,
          thickness: 3,
        ),
      ),
    );

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
    idf2Element.next!.add(
      ConnectionParams(
        destElementId: switch4Element.id,
        arrowParams: ArrowParams(
          color: Colors.grey,
          thickness: 2,
        ),
      ),
    );

    // MDF -> Servidor (Dedicado)
    mdfElement.next!.add(
      ConnectionParams(
        destElementId: serverElement.id,
        arrowParams: ArrowParams(
          color: Colors.purple,
          thickness: 5,
        ),
      ),
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
      case 'AccessSwitch':
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

      // Cargar toda la topología del negocio seleccionado usando el método optimizado
      await componentesProvider.cargarTopologiaCompletaOptimizada(
          componentesProvider.negocioSeleccionadoId!);

      // Mostrar estadísticas detalladas para debug
      _mostrarEstadisticasComponentes();

      // Construir la topología con datos reales del negocio seleccionado
      await _buildRealNetworkTopologyOptimized();
    } catch (e) {
      print('Error al cargar datos de topología: ${e.toString()}');
      _showErrorDialog('Error al cargar la topología: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buildRealNetworkTopologyOptimized() async {
    dashboard.removeAllElements();

    final componentesProvider =
        Provider.of<ComponentesProvider>(context, listen: false);

    // Usar los datos optimizados
    final mdfComponents = componentesProvider.getComponentesMDFOptimizados();
    final idfComponents = componentesProvider.getComponentesIDFOptimizados();
    final switchesAcceso = componentesProvider
        .getComponentesPorTipoOptimizado('switch')
        .where((s) => !s.esMDF && !s.esIDF)
        .toList();
    final routers =
        componentesProvider.getComponentesPorTipoOptimizado('router');
    final servidores =
        componentesProvider.getComponentesPorTipoOptimizado('servidor');

    print('Componentes optimizados encontrados:');
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

    // Crear elementos MDF usando datos optimizados
    if (mdfComponents.isNotEmpty) {
      final mdfElement = _createMDFElementOptimized(
          mdfComponents, Offset(currentX + espacioX * 2, currentY));
      dashboard.addElement(mdfElement);
      elementosMap[mdfComponents.first.componenteId] = mdfElement;
      currentY += espacioY;
    }

    // Crear elementos IDF usando datos optimizados
    double idfX = currentX;
    for (var idfComp in idfComponents) {
      final idfElement = _createIDFElementOptimized(
          idfComp, Offset(idfX, currentY + espacioY));
      dashboard.addElement(idfElement);
      elementosMap[idfComp.componenteId] = idfElement;
      idfX += espacioX;
    }

    // Crear switches de acceso usando datos optimizados
    double switchX = currentX;
    currentY += espacioY * 2;
    for (var switchComp in switchesAcceso) {
      final switchElement =
          _createSwitchElementOptimized(switchComp, Offset(switchX, currentY));
      dashboard.addElement(switchElement);
      elementosMap[switchComp.componenteId] = switchElement;
      switchX += espacioX * 0.8;
    }

    // Crear servidores usando datos optimizados
    if (servidores.isNotEmpty) {
      currentY += espacioY;
      double serverX = currentX + espacioX;
      for (var servidor in servidores) {
        final serverElement =
            _createServerElementOptimized(servidor, Offset(serverX, currentY));
        dashboard.addElement(serverElement);
        elementosMap[servidor.componenteId] = serverElement;
        serverX += espacioX * 0.8;
      }
    }

    // Crear routers/firewalls usando datos optimizados
    if (routers.isNotEmpty) {
      double routerX = currentX;
      for (var router in routers) {
        final routerElement = _createRouterElementOptimized(
            router, Offset(routerX, currentY - espacioY * 3));
        dashboard.addElement(routerElement);
        elementosMap[router.componenteId] = routerElement;
        routerX += espacioX;
      }
    }

    // Crear conexiones basadas en la vista optimizada de cables
    await _createOptimizedConnections(elementosMap, componentesProvider);

    // Si no hay elementos reales, mostrar mensaje
    if (elementosMap.isEmpty) {
      _showNoComponentsMessage();
    }

    setState(() {});
  }

  FlowElement _createMDFElementOptimized(
      List<VistaTopologiaPorNegocio> mdfComponents, Offset position) {
    final mainComponent = mdfComponents.first;

    return FlowElement(
      position: position,
      size: const Size(180, 140),
      text: 'MDF\n${mainComponent.componenteNombre}',
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
        'componenteId': mainComponent.componenteId,
        'name': mainComponent.componenteNombre,
        'status': mainComponent.activo ? 'active' : 'disconnected',
        'description': mainComponent.descripcion ?? 'Main Distribution Frame',
        'ubicacion': mainComponent.ubicacion ?? 'Sin ubicación',
        'categoria': mainComponent.categoriaComponente,
        'componentes': mdfComponents.length,
        'distribucion': mainComponent.distribucionNombre ?? 'MDF Principal',
      },
      handlers: [
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createIDFElementOptimized(
      VistaTopologiaPorNegocio idfComponent, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(160, 120),
      text: 'IDF\n${idfComponent.componenteNombre}',
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
        'componenteId': idfComponent.componenteId,
        'name': idfComponent.componenteNombre,
        'status': idfComponent.activo
            ? (idfComponent.enUso ? 'active' : 'warning')
            : 'disconnected',
        'description':
            idfComponent.descripcion ?? 'Intermediate Distribution Frame',
        'ubicacion': idfComponent.ubicacion ?? 'Sin ubicación',
        'categoria': idfComponent.categoriaComponente,
        'enUso': idfComponent.enUso,
        'distribucion': idfComponent.distribucionNombre ?? 'IDF',
      },
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createSwitchElementOptimized(
      VistaTopologiaPorNegocio switchComponent, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(140, 100),
      text: 'Switch\n${switchComponent.componenteNombre}',
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
        'componenteId': switchComponent.componenteId,
        'name': switchComponent.componenteNombre,
        'status': switchComponent.activo ? 'active' : 'disconnected',
        'description': switchComponent.descripcion ?? 'Switch de Acceso',
        'ubicacion': switchComponent.ubicacion ?? 'Sin ubicación',
        'categoria': switchComponent.categoriaComponente,
        'enUso': switchComponent.enUso,
      },
      handlers: [
        Handler.topCenter,
      ],
    );
  }

  FlowElement _createServerElementOptimized(
      VistaTopologiaPorNegocio serverComponent, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(150, 100),
      text: 'Servidor\n${serverComponent.componenteNombre}',
      textColor: Colors.white,
      textSize: 11,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: serverComponent.activo
          ? const Color(0xFFE91E63)
          : const Color(0xFF757575),
      borderColor: serverComponent.activo
          ? const Color(0xFFC2185B)
          : const Color(0xFF424242),
      borderThickness: 3,
      elevation: serverComponent.activo ? 6 : 2,
      data: {
        'type': 'Server',
        'componenteId': serverComponent.componenteId,
        'name': serverComponent.componenteNombre,
        'status': serverComponent.activo ? 'active' : 'disconnected',
        'description': serverComponent.descripcion ?? 'Servidor de red',
        'ubicacion': serverComponent.ubicacion ?? 'Sin ubicación',
        'categoria': serverComponent.categoriaComponente,
        'enUso': serverComponent.enUso,
      },
      handlers: [
        Handler.topCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  FlowElement _createRouterElementOptimized(
      VistaTopologiaPorNegocio routerComponent, Offset position) {
    return FlowElement(
      position: position,
      size: const Size(160, 100),
      text: 'Router\n${routerComponent.componenteNombre}',
      textColor: Colors.white,
      textSize: 11,
      textIsBold: true,
      kind: ElementKind.rectangle,
      backgroundColor: routerComponent.activo
          ? const Color(0xFFFF5722)
          : const Color(0xFF757575),
      borderColor: routerComponent.activo
          ? const Color(0xFFE64A19)
          : const Color(0xFF424242),
      borderThickness: 3,
      elevation: routerComponent.activo ? 6 : 2,
      data: {
        'type': 'Router',
        'componenteId': routerComponent.componenteId,
        'name': routerComponent.componenteNombre,
        'status': routerComponent.activo ? 'active' : 'disconnected',
        'description': routerComponent.descripcion ?? 'Router/Firewall',
        'ubicacion': routerComponent.ubicacion ?? 'Sin ubicación',
        'categoria': routerComponent.categoriaComponente,
        'enUso': routerComponent.enUso,
      },
      handlers: [
        Handler.topCenter,
        Handler.bottomCenter,
        Handler.leftCenter,
        Handler.rightCenter,
      ],
    );
  }

  Future<void> _createOptimizedConnections(
      Map<String, FlowElement> elementosMap,
      ComponentesProvider componentesProvider) async {
    try {
      print('Creando conexiones optimizadas...');
      print(
          'Conexiones con cables encontradas: ${componentesProvider.conexionesConCables.length}');

      for (var conexionCable in componentesProvider.conexionesConCables) {
        if (!conexionCable.activo) continue;

        final elementoOrigen = elementosMap[conexionCable.origenId];
        final elementoDestino = elementosMap[conexionCable.destinoId];

        if (elementoOrigen != null && elementoDestino != null) {
          // Usar la información real del cable para determinar color y grosor
          final colorConexion = _getColorFromCableData(conexionCable);
          final grosorConexion = _getThicknessFromCableData(conexionCable);

          print(
              'Creando conexión: ${conexionCable.componenteOrigen} -> ${conexionCable.componenteDestino}');
          if (conexionCable.tipoCable != null) {
            print(
                '  Cable: ${conexionCable.tipoCable} (${conexionCable.color ?? 'sin color'})');
          }

          // Crear la conexión en el FlowChart
          elementoOrigen.next ??= [];

          elementoOrigen.next!.add(
            ConnectionParams(
              destElementId: elementoDestino.id,
              arrowParams: ArrowParams(
                color: colorConexion,
                thickness: grosorConexion,
              ),
            ),
          );
        } else {
          print(
              'Elementos no encontrados para conexión: ${conexionCable.origenId} -> ${conexionCable.destinoId}');
        }
      }

      setState(() {});
    } catch (e) {
      print('Error en _createOptimizedConnections: ${e.toString()}');
    }
  }

  Color _getColorFromCableData(VistaConexionesPorCables conexionCable) {
    // Usar el método del modelo para obtener el color
    final colorHex = conexionCable.getColorForVisualization();
    return _hexToColor(colorHex);
  }

  double _getThicknessFromCableData(VistaConexionesPorCables conexionCable) {
    // Usar el método del modelo para obtener el grosor
    return conexionCable.getThicknessForVisualization();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _showNoBusinessSelectedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.business, color: Colors.orange),
            SizedBox(width: 8),
            Text('Negocio no seleccionado'),
          ],
        ),
        content: const Text(
          'Para visualizar la topología de red, primero debe seleccionar un negocio desde la página de empresas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a la página de empresas
              // router.pushNamed('/infrastructure/empresas');
            },
            child: const Text('Ir a Empresas'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showNoComponentsMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sin componentes'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se encontraron componentes de infraestructura para este negocio.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Para visualizar la topología, necesita:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Registrar componentes (switches, routers, etc.)'),
            const Text('• Configurar distribuciones (MDF/IDF)'),
            const Text('• Crear conexiones entre componentes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a la página de componentes
              // router.pushNamed('/infrastructure/componentes');
            },
            child: const Text('Gestionar Componentes'),
          ),
        ],
      ),
    );
  }

  // Método para mostrar estadísticas detalladas de componentes
  void _mostrarEstadisticasComponentes() {
    final provider = Provider.of<ComponentesProvider>(context, listen: false);
    print('\n=== ESTADÍSTICAS DETALLADAS DE COMPONENTES ===');
    print('Total de componentes cargados: ${provider.topologiaOptimizada.length}');

    if (provider.topologiaOptimizada.isEmpty) {
      print('❌ No hay componentes cargados');
      return;
    }

    // Agrupar por categoría
    final componentesPorCategoria = <String, List<VistaTopologiaPorNegocio>>{};
    for (final componente in provider.topologiaOptimizada) {
      final categoria = componente.categoriaComponente;
      componentesPorCategoria.putIfAbsent(categoria, () => []).add(componente);
    }

    print('\n📊 Componentes por categoría:');
    componentesPorCategoria.forEach((categoria, lista) {
      print('  - $categoria: ${lista.length} componentes');
      for (final comp in lista) {
        print('    • ${comp.componenteNombre} (${comp.tipoComponentePrincipal}) - Activo: ${comp.activo}');
      }
    });

    // Clasificación por tipo principal
    final mdfComponents = provider.getComponentesMDFOptimizados();
    final idfComponents = provider.getComponentesIDFOptimizados();
    final switchComponents = provider.getComponentesPorTipoOptimizado('switch');
    final routerComponents = provider.getComponentesPorTipoOptimizado('router');
    final servidorComponents = provider.getComponentesPorTipoOptimizado('servidor');

    print('\n🔧 Clasificación por tipo:');
    print('  - MDF: ${mdfComponents.length}');
    print('  - IDF: ${idfComponents.length}');
    print('  - Switches: ${switchComponents.length}');
    print('  - Routers: ${routerComponents.length}');
    print('  - Servidores: ${servidorComponents.length}');

    print('\n🔗 Conexiones disponibles: ${provider.conexionesConCables.length}');
    print('===============================================\n');
  }
}
