import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/pages/infrastructure/widgets/componentes_cards_view.dart';
import 'package:nethive_neo/pages/infrastructure/widgets/edit_componente_dialog.dart';
import 'package:nethive_neo/pages/infrastructure/widgets/add_componente_dialog.dart';
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
                _buildInventoryHeader(componentesProvider),

                const SizedBox(height: 24),

                // Estadísticas rápidas (solo en escritorio)
                if (isLargeScreen) ...[
                  _buildQuickStats(componentesProvider),
                  const SizedBox(height: 24),
                ],

                // Tabla de componentes (escritorio/tablet)
                Expanded(
                  child: _buildComponentsTable(componentesProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryHeader(ComponentesProvider componentesProvider) {
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
              Icons.inventory_2,
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
                  'Inventario MDF/IDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Gestión de componentes de infraestructura de red',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Botón para añadir componente - ACTUALIZADO
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {
                // Verificar que tengamos un negocio seleccionado
                if (componentesProvider.negocioSeleccionadoId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Debe seleccionar un negocio antes de añadir componentes'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Abrir el diálogo para añadir componente
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AddComponenteDialog(
                    provider: componentesProvider,
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Añadir Componente',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ComponentesProvider componentesProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Componentes',
            componentesProvider.componentes.length,
            Icons.devices,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Activos',
            componentesProvider.componentes.where((c) => c.activo).length,
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'En Uso',
            componentesProvider.componentes.where((c) => c.enUso).length,
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Categorías',
            componentesProvider.categorias.length,
            Icons.category,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsTable(ComponentesProvider componentesProvider) {
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
      child: Column(
        children: [
          // Header de la tabla
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).modernGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.table_chart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Componentes de Red',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Inventario completo de infraestructura MDF/IDF',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${componentesProvider.componentesRows.length} registros',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabla de componentes con PlutoGrid
          Expanded(
            child: componentesProvider.componentesRows.isEmpty
                ? _buildEmptyState()
                : PlutoGrid(
                    key: UniqueKey(),
                    configuration: PlutoGridConfiguration(
                      enableMoveDownAfterSelecting: true,
                      enableMoveHorizontalInEditing: true,
                      localeText: const PlutoGridLocaleText.spanish(),
                      scrollbar: PlutoGridScrollbarConfig(
                        draggableScrollbar: true,
                        isAlwaysShown: false,
                        onlyDraggingThumb: true,
                        enableScrollAfterDragEnd: true,
                        scrollbarThickness: 12,
                        scrollbarThicknessWhileDragging: 16,
                        hoverWidth: 20,
                        scrollBarColor:
                            AppTheme.of(context).primaryColor.withOpacity(0.7),
                        scrollBarTrackColor: Colors.grey.withOpacity(0.2),
                        scrollbarRadius: const Radius.circular(8),
                        scrollbarRadiusWhileDragging: const Radius.circular(10),
                      ),
                      style: PlutoGridStyleConfig(
                        enableRowColorAnimation: true,
                        gridBorderColor:
                            AppTheme.of(context).primaryColor.withOpacity(0.5),
                        disabledIconColor:
                            AppTheme.of(context).alternate.withOpacity(0.3),
                        iconColor:
                            AppTheme.of(context).alternate.withOpacity(0.3),
                        activatedBorderColor: AppTheme.of(context).primaryColor,
                        inactivatedBorderColor: Colors.grey.withOpacity(0.3),
                        gridBackgroundColor:
                            AppTheme.of(context).primaryBackground,
                        rowColor: AppTheme.of(context).secondaryBackground,
                        activatedColor:
                            AppTheme.of(context).primaryColor.withOpacity(0.1),
                        checkedColor:
                            AppTheme.of(context).primaryColor.withOpacity(0.2),
                        cellTextStyle: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontSize: 13,
                        ),
                        columnTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        menuBackgroundColor:
                            AppTheme.of(context).secondaryBackground,
                        gridBorderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        rowHeight: 70,
                      ),
                      columnFilter: const PlutoGridColumnFilterConfig(
                        filters: [
                          ...FilterHelper.defaultFilters,
                        ],
                      ),
                    ),
                    columns: [
                      PlutoColumn(
                        title: 'Nu.',
                        field: 'numero_fila',
                        width: 60,
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                (rendererContext.rowIdx + 1).toString(),
                                style: TextStyle(
                                  color: AppTheme.of(context).primaryText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'RFID',
                        field: 'rfid',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        width: 150,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          final rfid = rendererContext.cell.value?.toString();
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: rfid != null && rfid.isNotEmpty
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.indigo.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.nfc,
                                            color: Colors.indigo,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            rfid,
                                            style: const TextStyle(
                                              color: Colors.indigo,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      'Sin RFID',
                                      style: TextStyle(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Componente',
                        field: 'nombre',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.left,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                // Imagen del componente
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: rendererContext.row.cells['imagen_url']
                                                  ?.value !=
                                              null &&
                                          rendererContext
                                              .row.cells['imagen_url']!.value
                                              .toString()
                                              .isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Image.network(
                                            rendererContext
                                                .row.cells['imagen_url']!.value
                                                .toString(),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.devices,
                                                color: AppTheme.of(context)
                                                    .primaryColor,
                                                size: 16,
                                              );
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.devices,
                                          color:
                                              AppTheme.of(context).primaryColor,
                                          size: 16,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    rendererContext.cell.value.toString(),
                                    style: TextStyle(
                                      color: AppTheme.of(context).primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Categoría',
                        field: 'categoria_nombre',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          final categoriaNombre =
                              rendererContext.cell.value.toString();
                          final colorCategoria = rendererContext
                              .row.cells['color_categoria']?.value
                              ?.toString();

                          print(
                              'Categoria: $categoriaNombre, Color: $colorCategoria');
                          // Convertir color hexadecimal a Color
                          Color categoriaColor =
                              AppTheme.of(context).primaryColor;
                          if (colorCategoria != null &&
                              colorCategoria.isNotEmpty) {
                            try {
                              final hexColor =
                                  colorCategoria.replaceAll('#', '');
                              categoriaColor =
                                  Color(int.parse('FF$hexColor', radix: 16));
                            } catch (e) {
                              // Si hay error al parsear el color, usar color por defecto
                              categoriaColor =
                                  AppTheme.of(context).primaryColor;
                            }
                          }

                          // Obtener icono según la categoría
                          IconData categoriaIcon =
                              _getCategoryIcon(categoriaNombre);

                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: categoriaColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: categoriaColor.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      categoriaIcon,
                                      color: categoriaColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      categoriaNombre,
                                      style: TextStyle(
                                        color: categoriaColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Estado',
                        field: 'activo',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          final isActivo =
                              rendererContext.cell.value.toString() == 'Sí';
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (isActivo ? Colors.green : Colors.red)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isActivo
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color:
                                          isActivo ? Colors.green : Colors.red,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isActivo ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        color: isActivo
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'En Uso',
                        field: 'en_uso',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          final enUso =
                              rendererContext.cell.value.toString() == 'Sí';
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (enUso ? Colors.orange : Colors.grey)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  enUso ? 'En Uso' : 'Libre',
                                  style: TextStyle(
                                    color: enUso ? Colors.orange : Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Ubicación',
                        field: 'ubicacion',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.left,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppTheme.of(context).primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    rendererContext.cell.value
                                            .toString()
                                            .isEmpty
                                        ? 'Sin ubicación'
                                        : rendererContext.cell.value.toString(),
                                    style: TextStyle(
                                      color: AppTheme.of(context).primaryText,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Descripción',
                        field: 'descripcion',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.left,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              rendererContext.cell.value.toString().isEmpty
                                  ? 'Sin descripción'
                                  : rendererContext.cell.value.toString(),
                              style: TextStyle(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Fecha Registro',
                        field: 'fecha_registro',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              rendererContext.cell.value.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Acciones',
                        field: 'editar',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          final componenteId = rendererContext
                                  .row.cells['id']?.value
                                  .toString() ??
                              '';
                          final componente = componentesProvider
                              .getComponenteById(componenteId);

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botón ver detalles
                              Tooltip(
                                message: 'Ver detalles',
                                child: InkWell(
                                  onTap: () => _showComponentDetails(
                                      componente, componentesProvider),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Botón editar
                              Tooltip(
                                message: 'Editar',
                                child: InkWell(
                                  onTap: () => _editComponent(
                                      componente, componentesProvider),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Botón eliminar
                              Tooltip(
                                message: 'Eliminar',
                                child: InkWell(
                                  onTap: () => _deleteComponent(
                                      componente, componentesProvider),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                    rows: componentesProvider.componentesRows,
                    onLoaded: (event) {
                      componentesProvider.componentesStateManager =
                          event.stateManager;
                    },
                    createFooter: (stateManager) {
                      stateManager.setPageSize(10, notify: false);
                      return PlutoPagination(stateManager);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.inventory_2,
              color: AppTheme.of(context).primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay componentes registrados',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade el primer componente para comenzar',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para manejar las acciones de los botones
  void _showComponentDetails(dynamic componente, ComponentesProvider provider) {
    if (componente == null) return;

    // Detectar el tamaño de pantalla
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isMobile = screenSize.width <= 768;

    // Obtener la URL de la imagen del componente
    final imagenUrl = provider.componentesRows
        .where((row) => row.cells['id']?.value == componente.id)
        .firstOrNull
        ?.cells['imagen_url']
        ?.value
        ?.toString();

    final categoria = provider.getCategoriaById(componente.categoriaId);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isDesktop ? 40 : 20),
        child: Container(
          width: isDesktop ? 900 : (isMobile ? screenSize.width * 0.95 : 700),
          height: isDesktop ? 650 : (isMobile ? screenSize.height * 0.8 : 600),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 10),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.of(context).primaryBackground,
                    AppTheme.of(context).secondaryBackground,
                    AppTheme.of(context).tertiaryBackground,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
              child: isDesktop
                  ? _buildDesktopDetailLayout(
                      componente, provider, categoria, imagenUrl)
                  : _buildMobileDetailLayout(
                      componente, provider, categoria, imagenUrl),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopDetailLayout(
    dynamic componente,
    ComponentesProvider provider,
    dynamic categoria,
    String? imagenUrl,
  ) {
    return Row(
      children: [
        // Panel izquierdo con imagen espectacular
        Container(
          width: 350,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.of(context).primaryColor,
                AppTheme.of(context).secondaryColor,
                AppTheme.of(context).tertiaryColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.of(context).primaryColor.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen principal del componente - MÁS GRANDE
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: imagenUrl != null && imagenUrl.isNotEmpty
                        ? Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: const Icon(
                                  Icons.devices,
                                  color: Colors.white,
                                  size: 80,
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: const Icon(
                              Icons.devices,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Título del componente
                Text(
                  componente.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Categoría con estilo
                if (categoria != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoria.nombre,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Estados con iconos
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusIndicator(
                      componente.activo ? 'Activo' : 'Inactivo',
                      componente.activo ? Icons.check_circle : Icons.cancel,
                      componente.activo ? Colors.green : Colors.red,
                    ),
                    _buildStatusIndicator(
                      componente.enUso ? 'En Uso' : 'Libre',
                      componente.enUso
                          ? Icons.trending_up
                          : Icons.trending_flat,
                      componente.enUso ? Colors.orange : Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ID con estilo
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${componente.id.substring(0, 8)}...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Panel derecho con detalles
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del panel de detalles
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Detalles del Componente',
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppTheme.of(context).secondaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Información detallada
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (componente.ubicacion != null &&
                            componente.ubicacion!.isNotEmpty)
                          _buildEnhancedDetailCard(
                            'Ubicación',
                            componente.ubicacion!,
                            Icons.location_on,
                            Colors.blue,
                          ),
                        if (componente.descripcion != null &&
                            componente.descripcion!.isNotEmpty)
                          _buildEnhancedDetailCard(
                            'Descripción',
                            componente.descripcion!,
                            Icons.description,
                            Colors.purple,
                          ),
                        _buildEnhancedDetailCard(
                          'Fecha de Registro',
                          componente.fechaRegistro?.toString().split(' ')[0] ??
                              'No disponible',
                          Icons.calendar_today,
                          Colors.green,
                        ),
                        _buildEnhancedDetailCard(
                          'Estado Operativo',
                          componente.activo
                              ? 'Componente activo y operativo'
                              : 'Componente inactivo',
                          componente.activo
                              ? Icons.power_settings_new
                              : Icons.power_off,
                          componente.activo ? Colors.green : Colors.red,
                        ),
                        _buildEnhancedDetailCard(
                          'Estado de Uso',
                          componente.enUso
                              ? 'Componente en uso actual'
                              : 'Componente disponible para uso',
                          componente.enUso ? Icons.work : Icons.work_off,
                          componente.enUso ? Colors.orange : Colors.grey,
                        ),
                        if (componente.rfid != null &&
                            componente.rfid!.isNotEmpty)
                          _buildEnhancedDetailCard(
                            'RFID',
                            componente.rfid!,
                            Icons.nfc,
                            Colors.indigo,
                          ),
                      ],
                    ),
                  ),
                ),

                // Botones de acción
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _editComponent(componente, provider);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cerrar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.of(context).secondaryText,
                          side: BorderSide(
                            color: AppTheme.of(context)
                                .secondaryText
                                .withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDetailLayout(
    dynamic componente,
    ComponentesProvider provider,
    dynamic categoria,
    String? imagenUrl,
  ) {
    return Column(
      children: [
        // Header con imagen para móvil
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.of(context).primaryColor,
                AppTheme.of(context).secondaryColor,
                AppTheme.of(context).tertiaryColor,
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Imagen del componente en móvil
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: imagenUrl != null && imagenUrl.isNotEmpty
                      ? Image.network(
                          imagenUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white.withOpacity(0.1),
                              child: const Icon(
                                Icons.devices,
                                color: Colors.white,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.1),
                          child: const Icon(
                            Icons.devices,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                componente.nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (categoria != null) ...[
                const SizedBox(height: 8),
                Text(
                  categoria.nombre,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Contenido de detalles para móvil
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusIndicator(
                        componente.activo ? 'Activo' : 'Inactivo',
                        componente.activo ? Icons.check_circle : Icons.cancel,
                        componente.activo ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusIndicator(
                        componente.enUso ? 'En Uso' : 'Libre',
                        componente.enUso
                            ? Icons.trending_up
                            : Icons.trending_flat,
                        componente.enUso ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (componente.ubicacion != null &&
                    componente.ubicacion!.isNotEmpty)
                  _buildEnhancedDetailCard(
                    'Ubicación',
                    componente.ubicacion!,
                    Icons.location_on,
                    Colors.blue,
                  ),

                if (componente.descripcion != null &&
                    componente.descripcion!.isNotEmpty)
                  _buildEnhancedDetailCard(
                    'Descripción',
                    componente.descripcion!,
                    Icons.description,
                    Colors.purple,
                  ),

                _buildEnhancedDetailCard(
                  'Fecha de Registro',
                  componente.fechaRegistro?.toString().split(' ')[0] ??
                      'No disponible',
                  Icons.calendar_today,
                  Colors.green,
                ),

                _buildEnhancedDetailCard(
                  'ID del Componente',
                  componente.id.substring(0, 8) + '...',
                  Icons.fingerprint,
                  Colors.indigo,
                ),

                const SizedBox(height: 20),

                // Botones de acción para móvil
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _editComponent(componente, provider);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Cerrar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.of(context).secondaryText,
                          side: BorderSide(
                            color: AppTheme.of(context)
                                .secondaryText
                                .withOpacity(0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDetailCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).secondaryBackground,
            AppTheme.of(context).tertiaryBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  IconData _getCategoryIcon(String categoryName) {
    // Normalizar el nombre de la categoría para mejor matching
    final normalizedName = categoryName.toLowerCase().trim();

    // Mapa de categorías a íconos basado en las categorías de tu imagen
    if (normalizedName.contains('cable')) {
      return Icons.cable;
    } else if (normalizedName.contains('switch')) {
      return Icons.hub;
    } else if (normalizedName.contains('patch') ||
        normalizedName.contains('panel')) {
      return Icons.view_module;
    } else if (normalizedName.contains('rack')) {
      return Icons.storage;
    } else if (normalizedName.contains('ups') ||
        normalizedName.contains('power')) {
      return Icons.battery_charging_full;
    } else if (normalizedName.contains('router') ||
        normalizedName.contains('firewall')) {
      return Icons.router;
    } else if (normalizedName.contains('server') ||
        normalizedName.contains('servidor')) {
      return Icons.dns;
    } else if (normalizedName.contains('access') ||
        normalizedName.contains('wifi')) {
      return Icons.wifi;
    } else if (normalizedName.contains('pc') ||
        normalizedName.contains('computer')) {
      return Icons.computer;
    } else if (normalizedName.contains('phone') ||
        normalizedName.contains('teléfono')) {
      return Icons.phone;
    } else if (normalizedName.contains('printer') ||
        normalizedName.contains('impresora')) {
      return Icons.print;
    } else if (normalizedName.contains('security') ||
        normalizedName.contains('seguridad')) {
      return Icons.security;
    } else if (normalizedName.contains('monitor') ||
        normalizedName.contains('pantalla')) {
      return Icons.monitor;
    } else if (normalizedName.contains('keyboard') ||
        normalizedName.contains('teclado')) {
      return Icons.keyboard;
    } else if (normalizedName.contains('mouse') ||
        normalizedName.contains('ratón')) {
      return Icons.mouse;
    } else {
      // Icono por defecto para categorías no reconocidas
      return Icons.devices_other;
    }
  }
}
