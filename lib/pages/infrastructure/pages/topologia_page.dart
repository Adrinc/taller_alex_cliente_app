import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';

class TopologiaPage extends StatefulWidget {
  const TopologiaPage({Key? key}) : super(key: key);

  @override
  State<TopologiaPage> createState() => _TopologiaPageState();
}

class _TopologiaPageState extends State<TopologiaPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedView = 'rack'; // rack, network, floor
  double _zoomLevel = 1.0;

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

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<ComponentesProvider>(
        builder: (context, componentesProvider, child) {
          return Container(
            padding: EdgeInsets.all(isMediumScreen ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header mejorado
                _buildTopologyHeader(),

                const SizedBox(height: 24),

                // Controles de vista y zoom
                if (isMediumScreen) ...[
                  _buildTopologyControls(),
                  const SizedBox(height: 24),
                ],

                // Vista principal de topología
                Expanded(
                  child:
                      _buildTopologyView(componentesProvider, isMediumScreen),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopologyHeader() {
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Topología de Red MDF/IDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Visualización interactiva de la infraestructura de telecomunicaciones',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
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
              'V2.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyControls() {
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
                _buildViewButton('rack', 'Rack', Icons.dns),
                const SizedBox(width: 8),
                _buildViewButton('network', 'Red', Icons.hub),
                const SizedBox(width: 8),
                _buildViewButton('floor', 'Planta', Icons.map),
              ],
            ),
          ),

          // Controles de zoom
          Row(
            children: [
              Text(
                'Zoom:',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(
                    () => _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 2.0)),
                icon: const Icon(Icons.zoom_out),
                tooltip: 'Alejar',
              ),
              Text(
                '${(_zoomLevel * 100).round()}%',
                style: TextStyle(
                  color: AppTheme.of(context).secondaryText,
                  fontSize: 12,
                ),
              ),
              IconButton(
                onPressed: () => setState(
                    () => _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 2.0)),
                icon: const Icon(Icons.zoom_in),
                tooltip: 'Acercar',
              ),
              IconButton(
                onPressed: () => setState(() => _zoomLevel = 1.0),
                icon: const Icon(Icons.center_focus_strong),
                tooltip: 'Restablecer zoom',
              ),
            ],
          ),
        ],
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

  Widget _buildTopologyView(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Fondo con patrón de cuadrícula
            _buildGridBackground(),

            // Contenido principal según la vista seleccionada
            Transform.scale(
              scale: _zoomLevel,
              child: _buildViewContent(componentesProvider, isMediumScreen),
            ),

            // Leyenda flotante
            if (isMediumScreen)
              Positioned(
                top: 16,
                right: 16,
                child: _buildLegend(),
              ),

            // Controles móviles
            if (!isMediumScreen)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildMobileControls(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(
        color: AppTheme.of(context).primaryColor.withOpacity(0.1),
      ),
      child: Container(),
    );
  }

  Widget _buildViewContent(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    switch (_selectedView) {
      case 'rack':
        return _buildRackView(componentesProvider, isMediumScreen);
      case 'network':
        return _buildNetworkView(componentesProvider, isMediumScreen);
      case 'floor':
        return _buildFloorView(componentesProvider, isMediumScreen);
      default:
        return _buildRackView(componentesProvider, isMediumScreen);
    }
  }

  Widget _buildRackView(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    final racks = componentesProvider.componentes
        .where((c) =>
            componentesProvider
                .getCategoriaById(c.categoriaId)
                ?.nombre
                ?.toLowerCase()
                .contains('rack') ??
            false)
        .toList();

    if (racks.isEmpty) {
      return _buildEmptyRackView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: isMediumScreen
          ? _buildDesktopRackLayout(racks, componentesProvider)
          : _buildMobileRackLayout(racks, componentesProvider),
    );
  }

  Widget _buildEmptyRackView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dns,
              size: 48,
              color: AppTheme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay racks configurados',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agregue racks desde el inventario para visualizar la topología',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRackLayout(
      List<dynamic> racks, ComponentesProvider componentesProvider) {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: racks
          .map((rack) => _buildRackWidget(rack, componentesProvider, true))
          .toList(),
    );
  }

  Widget _buildMobileRackLayout(
      List<dynamic> racks, ComponentesProvider componentesProvider) {
    return Column(
      children: racks
          .map((rack) => Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: _buildRackWidget(rack, componentesProvider, false),
              ))
          .toList(),
    );
  }

  Widget _buildRackWidget(
      dynamic rack, ComponentesProvider componentesProvider, bool isDesktop) {
    // Obtener componentes que están en este rack
    final rackComponents = componentesProvider.componentes
        .where((c) =>
            c.ubicacion?.toLowerCase().contains(rack.nombre.toLowerCase()) ??
            false)
        .toList();

    return Container(
      width: isDesktop ? 280 : double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[600]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del rack
          Row(
            children: [
              Icon(
                Icons.dns,
                color: Colors.blue[300],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rack.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: rack.activo ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rack.activo ? 'ACTIVO' : 'INACTIVO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Unidades del rack (simulación visual)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: _buildRackUnits(rackComponents, componentesProvider),
          ),

          const SizedBox(height: 12),

          // Información del rack
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${rackComponents.length} componentes',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                ),
              ),
              if (rack.ubicacion != null)
                Text(
                  rack.ubicacion!,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRackUnits(
      List<dynamic> components, ComponentesProvider componentesProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(4),
      itemCount:
          (components.length + 1).clamp(1, 10), // Máximo 10 unidades visuales
      itemBuilder: (context, index) {
        if (index < components.length) {
          final component = components[index];
          final categoria =
              componentesProvider.getCategoriaById(component.categoriaId);
          return Container(
            height: 16,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: _getComponentColor(categoria?.nombre),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey[600]!, width: 0.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: 4),
                Icon(
                  _getComponentIcon(categoria?.nombre),
                  size: 10,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    component.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Unidad vacía
          return Container(
            height: 16,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.grey[700]!, width: 0.5),
            ),
          );
        }
      },
    );
  }

  Widget _buildNetworkView(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildNetworkDiagram(componentesProvider, isMediumScreen),
      ),
    );
  }

  Widget _buildNetworkDiagram(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    final switches = componentesProvider.componentes
        .where((c) =>
            componentesProvider
                .getCategoriaById(c.categoriaId)
                ?.nombre
                ?.toLowerCase()
                .contains('switch') ??
            false)
        .toList();

    final routers = componentesProvider.componentes
        .where((c) =>
            componentesProvider
                .getCategoriaById(c.categoriaId)
                ?.nombre
                ?.toLowerCase()
                .contains('router') ??
            false)
        .toList();

    return Column(
      children: [
        // Capa de routers/firewall
        if (routers.isNotEmpty) ...[
          Text(
            'Capa de Enrutamiento',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: routers
                .map((router) => _buildNetworkNode(
                      router,
                      Icons.router,
                      Colors.red[400]!,
                      componentesProvider,
                    ))
                .toList(),
          ),
          const SizedBox(height: 32),

          // Líneas de conexión
          Container(
            height: 2,
            width: isMediumScreen ? 200 : 150,
            color: AppTheme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 32),
        ],

        // Capa de switches
        if (switches.isNotEmpty) ...[
          Text(
            'Capa de Conmutación',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: switches
                .map((switch_) => _buildNetworkNode(
                      switch_,
                      Icons.hub,
                      Colors.blue[400]!,
                      componentesProvider,
                    ))
                .toList(),
          ),
        ],

        if (switches.isEmpty && routers.isEmpty) _buildEmptyNetworkView(),
      ],
    );
  }

  Widget _buildNetworkNode(dynamic component, IconData icon, Color color,
      ComponentesProvider componentesProvider) {
    return GestureDetector(
      onTap: () => _showComponentDetails(component, componentesProvider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              component.nombre,
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (component.ubicacion != null)
              Text(
                component.ubicacion!,
                style: TextStyle(
                  color: AppTheme.of(context).secondaryText,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: component.activo ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                component.activo ? 'ON' : 'OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorView(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _buildFloorPlan(componentesProvider, isMediumScreen),
      ),
    );
  }

  Widget _buildFloorPlan(
      ComponentesProvider componentesProvider, bool isMediumScreen) {
    return Container(
      width: isMediumScreen ? 600 : double.infinity,
      height: isMediumScreen ? 400 : 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Stack(
        children: [
          // Representación simple de planta
          _buildFloorLayout(),

          // Componentes distribuidos en la planta
          ..._buildFloorComponents(componentesProvider),
        ],
      ),
    );
  }

  Widget _buildFloorLayout() {
    return CustomPaint(
      painter: FloorPlanPainter(),
      child: Container(),
    );
  }

  List<Widget> _buildFloorComponents(ComponentesProvider componentesProvider) {
    final components = componentesProvider.componentes
        .take(6)
        .toList(); // Límite para visualización
    final positions = [
      const Offset(0.2, 0.3),
      const Offset(0.8, 0.3),
      const Offset(0.2, 0.7),
      const Offset(0.8, 0.7),
      const Offset(0.5, 0.2),
      const Offset(0.5, 0.8),
    ];

    return components.asMap().entries.map((entry) {
      final index = entry.key;
      final component = entry.value;
      final position = positions[index % positions.length];

      return Positioned(
        left: position.dx * 580 + 10, // Ajuste por padding
        top: position.dy * 380 + 10,
        child: _buildFloorComponent(component, componentesProvider),
      );
    }).toList();
  }

  Widget _buildFloorComponent(
      dynamic component, ComponentesProvider componentesProvider) {
    final categoria =
        componentesProvider.getCategoriaById(component.categoriaId);

    return GestureDetector(
      onTap: () => _showComponentDetails(component, componentesProvider),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getComponentColor(categoria?.nombre),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getComponentIcon(categoria?.nombre),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              component.nombre.length > 8
                  ? '${component.nombre.substring(0, 8)}...'
                  : component.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNetworkView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.hub,
            size: 48,
            color: AppTheme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No hay equipos de red configurados',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Agregue switches y routers desde el inventario',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.of(context).secondaryText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leyenda',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(Icons.router, 'Router/Firewall', Colors.red[400]!),
          _buildLegendItem(Icons.hub, 'Switch', Colors.blue[400]!),
          _buildLegendItem(Icons.dns, 'Rack', Colors.grey[600]!),
          _buildLegendItem(Icons.cable, 'Cable', Colors.orange[400]!),
          _buildLegendItem(
              Icons.electrical_services, 'UPS', Colors.yellow[700]!),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector de vista móvil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMobileViewButton('rack', 'Rack', Icons.dns),
              _buildMobileViewButton('network', 'Red', Icons.hub),
              _buildMobileViewButton('floor', 'Planta', Icons.map),
            ],
          ),
          const SizedBox(height: 12),

          // Controles de zoom móvil
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(
                    () => _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 2.0)),
                icon: const Icon(Icons.zoom_out),
                iconSize: 20,
              ),
              Text(
                '${(_zoomLevel * 100).round()}%',
                style: TextStyle(
                  color: AppTheme.of(context).secondaryText,
                  fontSize: 12,
                ),
              ),
              IconButton(
                onPressed: () => setState(
                    () => _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 2.0)),
                icon: const Icon(Icons.zoom_in),
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileViewButton(String value, String label, IconData icon) {
    final isSelected = _selectedView == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected ? Colors.white : AppTheme.of(context).primaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.of(context).primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComponentDetails(
      dynamic component, ComponentesProvider componentesProvider) {
    final categoria =
        componentesProvider.getCategoriaById(component.categoriaId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getComponentIcon(categoria?.nombre),
              color: AppTheme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                component.nombre,
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Categoría', categoria?.nombre ?? 'N/A'),
            _buildDetailRow('Estado', component.activo ? 'Activo' : 'Inactivo'),
            _buildDetailRow('En uso', component.enUso ? 'Sí' : 'No'),
            if (component.ubicacion != null)
              _buildDetailRow('Ubicación', component.ubicacion!),
            if (component.descripcion != null)
              _buildDetailRow('Descripción', component.descripcion!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getComponentColor(String? categoryName) {
    if (categoryName == null) return Colors.grey[600]!;

    final name = categoryName.toLowerCase();
    if (name.contains('switch')) return Colors.blue[600]!;
    if (name.contains('router') || name.contains('firewall'))
      return Colors.red[600]!;
    if (name.contains('cable')) return Colors.orange[600]!;
    if (name.contains('rack')) return Colors.grey[700]!;
    if (name.contains('ups')) return Colors.yellow[700]!;
    if (name.contains('patch') || name.contains('panel'))
      return Colors.purple[600]!;
    return Colors.teal[600]!;
  }

  IconData _getComponentIcon(String? categoryName) {
    if (categoryName == null) return Icons.device_unknown;

    final name = categoryName.toLowerCase();
    if (name.contains('switch')) return Icons.hub;
    if (name.contains('router') || name.contains('firewall'))
      return Icons.router;
    if (name.contains('cable')) return Icons.cable;
    if (name.contains('rack')) return Icons.dns;
    if (name.contains('ups')) return Icons.electrical_services;
    if (name.contains('patch') || name.contains('panel'))
      return Icons.view_module;
    return Icons.memory;
  }
}

// Painter personalizado para la cuadrícula de fondo
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 20.0;

    // Líneas verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter para el plano de planta
class FloorPlanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibujar habitaciones/áreas
    final rect1 =
        Rect.fromLTWH(20, 20, size.width * 0.4 - 20, size.height * 0.6);
    final rect2 = Rect.fromLTWH(
        size.width * 0.6, 20, size.width * 0.4 - 20, size.height * 0.6);
    final rect3 = Rect.fromLTWH(
        20, size.height * 0.7, size.width - 40, size.height * 0.3 - 20);

    canvas.drawRect(rect1, paint);
    canvas.drawRect(rect2, paint);
    canvas.drawRect(rect3, paint);

    // Etiquetas de áreas
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'MDF',
      style: TextStyle(
          color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(rect1.center.dx - textPainter.width / 2, rect1.center.dy));

    textPainter.text = const TextSpan(
      text: 'IDF',
      style: TextStyle(
          color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(rect2.center.dx - textPainter.width / 2, rect2.center.dy));

    textPainter.text = const TextSpan(
      text: 'Área de Trabajo',
      style: TextStyle(
          color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(rect3.center.dx - textPainter.width / 2, rect3.center.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
