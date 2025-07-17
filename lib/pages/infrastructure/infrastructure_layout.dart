import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/nethive/navigation_provider.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/pages/infrastructure/widgets/infrastructure_sidemenu.dart';
import 'package:nethive_neo/pages/infrastructure/pages/dashboard_page.dart';
import 'package:nethive_neo/pages/infrastructure/pages/inventario_page.dart';
import 'package:nethive_neo/pages/infrastructure/pages/topologia_page.dart';
import 'package:nethive_neo/pages/infrastructure/pages/alertas_page.dart';
import 'package:nethive_neo/pages/infrastructure/pages/configuracion_page.dart';
import 'package:nethive_neo/theme/theme.dart';

class InfrastructureLayout extends StatefulWidget {
  final String negocioId;

  const InfrastructureLayout({
    Key? key,
    required this.negocioId,
  }) : super(key: key);

  @override
  State<InfrastructureLayout> createState() => _InfrastructureLayoutState();
}

class _InfrastructureLayoutState extends State<InfrastructureLayout>
    with TickerProviderStateMixin {
  bool _isSidebarExpanded = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Establecer el negocio seleccionado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NavigationProvider>()
          .setNegocioSeleccionado(widget.negocioId);
      context
          .read<ComponentesProvider>()
          .setNegocioSeleccionado(widget.negocioId);
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;

    // Ajustar sidebar basado en tamaño de pantalla
    if (!isLargeScreen && _isSidebarExpanded) {
      _isSidebarExpanded = false;
    }

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.of(context).darkBackgroundGradient,
          ),
          child: Consumer<NavigationProvider>(
            builder: (context, navigationProvider, child) {
              if (navigationProvider.negocioSeleccionado == null) {
                return _buildLoadingScreen();
              }

              if (isMediumScreen) {
                // Vista desktop/tablet
                return Row(
                  children: [
                    // Sidebar
                    InfrastructureSidemenu(
                      isExpanded: _isSidebarExpanded,
                      onToggle: () {
                        setState(() {
                          _isSidebarExpanded = !_isSidebarExpanded;
                        });
                      },
                    ),

                    // Área principal
                    Expanded(
                      child: Column(
                        children: [
                          // Header superior
                          _buildHeader(navigationProvider),

                          // Contenido principal
                          Expanded(
                            child: _buildMainContent(navigationProvider),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // Vista móvil
                return Column(
                  children: [
                    // Header móvil
                    _buildMobileHeader(navigationProvider),

                    // Contenido principal
                    Expanded(
                      child: _buildMainContent(navigationProvider),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),

      // Drawer para móvil
      drawer: MediaQuery.of(context).size.width <= 800
          ? Drawer(
              backgroundColor: Colors.transparent,
              child: InfrastructureSidemenu(
                isExpanded: true,
                onToggle: () => Navigator.of(context).pop(),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando infraestructura...',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(NavigationProvider navigationProvider) {
    final negocio = navigationProvider.negocioSeleccionado!;
    final empresa = navigationProvider.empresaSeleccionada!;
    final currentMenuItem = navigationProvider.getMenuItemByIndex(
      navigationProvider.selectedMenuIndex,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.of(context).primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo solo de Nethive
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/images/logo_nh.png',
              width: 24,
              height: 24,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 20),

          // Breadcrumb mejorado
          Expanded(
            child: Row(
              children: [
                // Empresa
                Text(
                  empresa.nombre,
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.of(context).secondaryText,
                ),
                const SizedBox(width: 8),

                // Negocio (cuadro verde como en la imagen de referencia)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        negocio.nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(${empresa.nombre})',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.of(context).secondaryText,
                ),
                const SizedBox(width: 8),

                // Página actual
                Text(
                  currentMenuItem.title,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Buscador (conservado como en la referencia)
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.of(context).formBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: TextField(
              style: TextStyle(color: AppTheme.of(context).primaryText),
              decoration: InputDecoration(
                hintText: 'Buscar en infraestructura...',
                hintStyle: TextStyle(
                  color: AppTheme.of(context).hintText,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.of(context).primaryColor,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(NavigationProvider navigationProvider) {
    final negocio = navigationProvider.negocioSeleccionado!;
    final currentMenuItem = navigationProvider.getMenuItemByIndex(
      navigationProvider.selectedMenuIndex,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Botón de menú
              IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, color: Colors.white),
              ),

              // Logo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/logo_nh.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NETHIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentMenuItem.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Info del negocio
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    negocio.nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(NavigationProvider navigationProvider) {
    switch (navigationProvider.selectedMenuIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const InventarioPage();
      case 2:
        return const TopologiaPage();
      case 3:
        return const AlertasPage();
      case 4:
        return const ConfiguracionPage();
      default:
        return const DashboardPage();
    }
  }
}
