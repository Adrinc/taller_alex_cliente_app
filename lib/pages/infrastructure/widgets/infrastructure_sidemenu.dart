import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/nethive/navigation_provider.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class InfrastructureSidemenu extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const InfrastructureSidemenu({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<InfrastructureSidemenu> createState() => _InfrastructureSidemenuState();
}

class _InfrastructureSidemenuState extends State<InfrastructureSidemenu>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer2<NavigationProvider, ThemeConfigProvider>(
        builder: (context, navigationProvider, themeProvider, child) {
          return Container(
            width: widget.isExpanded ? 280 : 80,
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).darkBackgroundGradient,
              border: Border(
                right: BorderSide(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header con logo y toggle
                _buildHeader(navigationProvider),

                // Información del negocio seleccionado
                if (widget.isExpanded &&
                    navigationProvider.negocioSeleccionado != null)
                  _buildBusinessInfo(navigationProvider),

                // Lista de opciones del menú
                Expanded(
                  child: _buildMenuItems(navigationProvider),
                ),

                // Footer con información adicional
                if (widget.isExpanded) _buildFooter(),
                // Footer compacto cuando está contraído (solo switch de tema)
                if (!widget.isExpanded) _buildCompactFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(NavigationProvider navigationProvider) {
    return Container(
      padding: EdgeInsets.all(widget.isExpanded ? 20 : 15),
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
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
          // Toggle button
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.isExpanded ? Icons.menu_open : Icons.menu,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          if (widget.isExpanded) ...[
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.8)],
                    ).createShader(bounds),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/favicon.png',
                          width: 32,
                          height: 32,
                        ),
                        const Gap(8),
                        const Text(
                          'NETHIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Infraestructura',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBusinessInfo(NavigationProvider navigationProvider) {
    final negocio = navigationProvider.negocioSeleccionado!;
    final empresa = navigationProvider.empresaSeleccionada!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryColor.withOpacity(0.1),
            AppTheme.of(context).tertiaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  empresa.nombre,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  negocio.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '(${negocio.tipoLocal})',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(NavigationProvider navigationProvider) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: widget.isExpanded ? 16 : 8,
      ),
      itemCount: navigationProvider.menuItems.length,
      itemBuilder: (context, index) {
        final menuItem = navigationProvider.menuItems[index];
        final isSelected =
            navigationProvider.selectedMenuIndex == menuItem.index;
        final isSpecial = menuItem.isSpecial;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 200 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-30 * (1 - value), 0),
              child: Opacity(
                opacity: value,
                child: _buildMenuItem(
                  menuItem,
                  isSelected,
                  isSpecial,
                  navigationProvider,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuItem(
    NavigationMenuItem menuItem,
    bool isSelected,
    bool isSpecial,
    NavigationProvider navigationProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleMenuTap(menuItem, navigationProvider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(widget.isExpanded ? 12 : 8),
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
                      : null,
              borderRadius: BorderRadius.circular(12),
              border: isSpecial
                  ? Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  menuItem.icon,
                  color: isSelected
                      ? Colors.white
                      : isSpecial
                          ? Colors.orange
                          : AppTheme.of(context).primaryText,
                  size: 20,
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      menuItem.title,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isSpecial
                                ? Colors.orange
                                : AppTheme.of(context).primaryText,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.of(context).primaryBackground.withOpacity(0.0),
            AppTheme.of(context).primaryBackground,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.of(context).primaryColor.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Theme Switch para desktop
          _buildFooterThemeSwitch(),

          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppTheme.of(context).primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conexión segura',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.of(context).primaryBackground.withOpacity(0.0),
            AppTheme.of(context).primaryBackground,
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 1,
            width: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.of(context).primaryColor.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Switch de tema compacto centrado
          _buildCompactThemeSwitch(),

          const SizedBox(height: 8),

          // Indicador de conexión segura compacto
          Icon(
            Icons.shield_outlined,
            color: AppTheme.of(context).primaryColor,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactThemeSwitch() {
    final isDark = AppTheme.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () => _switchTheme(isDark ? ThemeMode.light : ThemeMode.dark),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            key: ValueKey(isDark),
            color: AppTheme.of(context).primaryColor,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterThemeSwitch() {
    final isDark = AppTheme.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFooterThemeOption(
              icon: Icons.light_mode,
              label: 'Claro',
              isSelected: !isDark,
              onTap: () => _switchTheme(ThemeMode.light),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.of(context).primaryColor.withOpacity(0.2),
          ),
          Expanded(
            child: _buildFooterThemeOption(
              icon: Icons.dark_mode,
              label: 'Oscuro',
              isSelected: isDark,
              onTap: () => _switchTheme(ThemeMode.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.of(context).primaryColor
                  : AppTheme.of(context).secondaryText,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.of(context).primaryColor
                    : AppTheme.of(context).secondaryText,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchTheme(ThemeMode mode) {
    // Usar la función de tema global para cambiar el modo
    setDarkModeSetting(context, mode);
  }

  void _handleMenuTap(
      NavigationMenuItem menuItem, NavigationProvider navigationProvider) {
    if (menuItem.isSpecial) {
      // Si es "Empresas", regresar a la página de empresas
      navigationProvider.clearSelection();
      context.go('/');
    } else {
      // Cambiar la selección del menú
      navigationProvider.setSelectedMenuIndex(menuItem.index);

      // Aquí puedes agregar navegación específica si es necesario
      // Por ahora solo cambiaremos la vista en el layout principal
    }
  }
}
