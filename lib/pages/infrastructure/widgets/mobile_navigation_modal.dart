import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/nethive/navigation_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class MobileNavigationModal extends StatefulWidget {
  const MobileNavigationModal({Key? key}) : super(key: key);

  @override
  State<MobileNavigationModal> createState() => _MobileNavigationModalState();
}

class _MobileNavigationModalState extends State<MobileNavigationModal>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Consumer<NavigationProvider>(
          builder: (context, navigationProvider, child) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header del modal
                  /*       _buildModalHeader(navigationProvider), */

                  // Lista de opciones de navegación
                  _buildNavigationOptions(navigationProvider),

                  // Información del negocio
                  _buildBusinessInfo(navigationProvider),

                  // Botón para cerrar
                  _buildCloseButton(),

                  // Padding adicional para evitar overflow
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModalHeader(NavigationProvider navigationProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
        decoration: BoxDecoration(
          gradient: AppTheme.of(context).primaryGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
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
            // Logo animado
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/favicon.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.8)],
                    ).createShader(bounds),
                    child: const Text(
                      'NETHIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Text(
                    'Infraestructura MDF/IDF',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Botón de cerrar
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationOptions(NavigationProvider navigationProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de sección
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(
                  Icons.navigation,
                  color: AppTheme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Módulos de Infraestructura',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de opciones
          ...navigationProvider.menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final menuItem = entry.value;
            final isSelected =
                navigationProvider.selectedMenuIndex == menuItem.index;
            final isSpecial = menuItem.isSpecial;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: _buildNavigationItem(
                      menuItem,
                      isSelected,
                      isSpecial,
                      navigationProvider,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    NavigationMenuItem menuItem,
    bool isSelected,
    bool isSpecial,
    NavigationProvider navigationProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? AppTheme.of(context).primaryGradient
            : isSpecial
                ? LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.deepOrange.withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      AppTheme.of(context).secondaryBackground,
                      AppTheme.of(context).tertiaryBackground,
                    ],
                  ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : isSpecial
                  ? Colors.orange.withOpacity(0.3)
                  : AppTheme.of(context).primaryColor.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.of(context).primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: isSelected ? 15 : 8,
            offset: Offset(0, isSelected ? 8 : 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleMenuTap(menuItem, navigationProvider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono del módulo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : isSpecial
                            ? Colors.orange.withOpacity(0.2)
                            : AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    menuItem.icon,
                    color: isSelected
                        ? Colors.white
                        : isSpecial
                            ? Colors.orange
                            : AppTheme.of(context).primaryColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del módulo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem.title,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isSpecial
                                  ? Colors.orange
                                  : AppTheme.of(context).primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMenuItemDescription(menuItem),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : isSpecial
                                  ? Colors.orange.withOpacity(0.8)
                                  : AppTheme.of(context).secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador de selección
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isSpecial
                        ? Colors.orange.withOpacity(0.6)
                        : AppTheme.of(context).secondaryText,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfo(NavigationProvider navigationProvider) {
    final negocio = navigationProvider.negocioSeleccionado;
    final empresa = navigationProvider.empresaSeleccionada;

    if (negocio == null || empresa == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryColor.withOpacity(0.1),
            AppTheme.of(context).tertiaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.of(context).primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ubicación Actual',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Información de la empresa
          Text(
            empresa.nombre,
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Información del negocio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  negocio.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.of(context).modernGradient,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text(
              'Cerrar Menú',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getMenuItemDescription(NavigationMenuItem menuItem) {
    switch (menuItem.title) {
      case 'Dashboard':
        return 'Métricas y estadísticas generales';
      case 'Inventario':
        return 'Gestión de componentes de red';
      case 'Topología':
        return 'Visualización de infraestructura';
      case 'Alertas':
        return 'Notificaciones del sistema';
      case 'Configuración':
        return 'Parámetros y ajustes';
      case 'Empresas':
        return 'Volver a gestión empresarial';
      default:
        return 'Módulo de infraestructura';
    }
  }

  void _handleMenuTap(
    NavigationMenuItem menuItem,
    NavigationProvider navigationProvider,
  ) {
    if (menuItem.isSpecial) {
      // Si es "Empresas", regresar a la página de empresas
      navigationProvider.clearSelection();
      context.go('/');
    } else {
      // Cambiar la selección del menú
      navigationProvider.setSelectedMenuIndex(menuItem.index);
    }

    // Cerrar el modal después de la selección
    Navigator.of(context).pop();
  }
}
