import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/nethive/navigation_provider.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/dashboard_widgets/dashboard_widgets.dart';

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
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<NavigationProvider, ComponentesProvider>(
        builder: (context, navigationProvider, componentesProvider, child) {
          return Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la página usando el widget separado
                  DashboardPageTitle(isSmallScreen: isSmallScreen),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Tarjetas de estadísticas usando el widget separado
                  DashboardStatsCards(
                    componentesProvider: componentesProvider,
                    isLargeScreen: isLargeScreen,
                    isMediumScreen: isMediumScreen,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Sección de gráficos usando el widget separado
                  DashboardChartsSection(
                    componentesProvider: componentesProvider,
                    isLargeScreen: isLargeScreen,
                    isMediumScreen: isMediumScreen,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Sección de contenido (componentes y alertas) usando el widget separado
                  DashboardContentSection(
                    componentesProvider: componentesProvider,
                    isLargeScreen: isLargeScreen,
                    isMediumScreen: isMediumScreen,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Métricas de rendimiento mejoradas usando el widget separado
                  DashboardEnhancedPerformanceMetrics(
                    componentesProvider: componentesProvider,
                    isSmallScreen: isSmallScreen,
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Feed de actividad usando el widget separado
                  DashboardActivityFeed(
                    isLargeScreen: isLargeScreen,
                    isMediumScreen: isMediumScreen,
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
