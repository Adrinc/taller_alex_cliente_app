import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/pages/infrastructure/widgets/componentes_cards_view.dart';
import 'package:nethive_neo/pages/infrastructure/widgets/edit_componente_dialog.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/inventario_widgets/inventario_widgets.dart';
import 'package:nethive_neo/theme/theme.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // GlobalKey para manejar el overlay de manera segura
  OverlayEntry? _loadingOverlay;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
    // Limpiar el overlay si existe antes de dispose
    _removeLoadingOverlay();
    _animationController.dispose();
    super.dispose();
  }

  // Método para mostrar overlay de loading de manera segura
  void _showLoadingOverlay(String message) {
    _removeLoadingOverlay(); // Remover cualquier overlay existente

    if (mounted) {
      _loadingOverlay = OverlayEntry(
        builder: (context) => Material(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_loadingOverlay!);
    }
  }

  // Método para remover overlay de manera segura
  void _removeLoadingOverlay() {
    if (_loadingOverlay != null) {
      try {
        _loadingOverlay!.remove();
      } catch (e) {
        // Ignorar errores si el overlay ya fue removido
      }
      _loadingOverlay = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;
    final isMobileScreen = MediaQuery.of(context).size.width <= 800;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<ComponentesProvider>(
        builder: (context, componentesProvider, child) {
          // Vista móvil con tarjetas
          if (isMobileScreen) {
            return const ComponentesCardsView();
          }

          // Vista de escritorio con tabla
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de inventario
                InventarioHeader(componentesProvider: componentesProvider),

                const SizedBox(height: 24),

                // Estadísticas rápidas (solo en escritorio)
                if (isLargeScreen) ...[
                  InventarioQuickStats(
                      componentesProvider: componentesProvider),
                  const SizedBox(height: 24),
                ],

                // Tabla de componentes (escritorio/tablet)
                Expanded(
                  child: InventarioComponentsTable(
                    componentesProvider: componentesProvider,
                    onShowDetails: _showComponentDetails,
                    onEditComponent: _editComponent,
                    onDeleteComponent: _deleteComponent,
                    getCategoryIcon: InventarioUtils.getCategoryIcon,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Métodos para manejar las acciones de los botones
  void _showComponentDetails(dynamic componente, ComponentesProvider provider) {
    InventarioComponentDetails.show(
      context,
      componente: componente,
      provider: provider,
      onEditComponent: _editComponent,
      onDeleteComponent: _deleteComponent,
      getCategoryIcon: InventarioUtils.getCategoryIcon,
    );
  }

  void _editComponent(dynamic componente, ComponentesProvider provider) {
    if (componente == null) return;

    showDialog(
      context: context,
      builder: (context) => EditComponenteDialog(
        provider: provider,
        componente: componente,
      ),
    );
  }

  void _deleteComponent(dynamic componente, ComponentesProvider provider) {
    if (componente == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).primaryBackground,
        title: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              'Eliminar Componente',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${componente.nombre}"?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(
            color: AppTheme.of(context).primaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Cerrar el diálogo de confirmación
              Navigator.of(context).pop();

              // Capturar el ScaffoldMessenger antes de la operación asíncrona
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              try {
                // Mostrar loading de manera segura
                _showLoadingOverlay('Eliminando componente...');

                // Realizar la eliminación
                final success =
                    await provider.eliminarComponente(componente.id);

                // Remover loading de manera segura
                _removeLoadingOverlay();

                // Verificar que el widget sigue montado antes de mostrar mensajes
                if (!mounted) return;

                // Mostrar resultado usando el ScaffoldMessenger capturado
                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Componente eliminado exitosamente',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Error al eliminar el componente',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                // Asegurar que el overlay se remueva en caso de error
                _removeLoadingOverlay();

                // Verificar que el widget sigue montado antes de mostrar error
                if (!mounted) return;

                // Mostrar error usando el ScaffoldMessenger capturado
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Error: $e',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
