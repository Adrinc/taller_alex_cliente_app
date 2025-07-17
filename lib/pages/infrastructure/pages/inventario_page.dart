import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({Key? key}) : super(key: key);

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<ComponentesProvider>(
        builder: (context, componentesProvider, child) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de inventario
                _buildInventoryHeader(componentesProvider),

                const SizedBox(height: 24),

                // Estadísticas rápidas
                _buildQuickStats(componentesProvider),

                const SizedBox(height: 24),

                // Tabla de componentes (como en la imagen de referencia)
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
          // Botón para añadir componente
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: () {
                // TODO: Abrir dialog para añadir componente
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de añadir componente próximamente'),
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

          // Tabla de componentes con PlutoGrid (como en la imagen de referencia)
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
                        gridBorderColor: Colors.grey.withOpacity(0.3),
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
                        columnTextStyle: TextStyle(
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
                        rowHeight: 55,
                      ),
                      columnFilter: const PlutoGridColumnFilterConfig(
                        filters: [
                          ...FilterHelper.defaultFilters,
                        ],
                      ),
                    ),
                    columns: [
                      PlutoColumn(
                        title: 'ID',
                        field: 'id',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.center,
                        width: 100,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Text(
                            rendererContext.cell.value
                                    .toString()
                                    .substring(0, 8) +
                                '...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.of(context).primaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                      PlutoColumn(
                        title: 'Componente',
                        field: 'nombre',
                        titleTextAlign: PlutoColumnTextAlign.center,
                        textAlign: PlutoColumnTextAlign.left,
                        width: 200,
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
                        width: 140,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  rendererContext.cell.value.toString(),
                                  style: TextStyle(
                                    color: AppTheme.of(context).primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                        width: 100,
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
                        width: 100,
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
                        width: 180,
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
                        width: 200,
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
                        width: 120,
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
                        width: 120,
                        type: PlutoColumnType.text(),
                        enableEditingMode: false,
                        backgroundColor: AppTheme.of(context).primaryColor,
                        enableContextMenu: false,
                        enableDropToResize: false,
                        renderer: (rendererContext) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Botón ver detalles
                              Tooltip(
                                message: 'Ver detalles',
                                child: InkWell(
                                  onTap: () {
                                    // TODO: Implementar vista de detalles
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Ver detalles próximamente'),
                                      ),
                                    );
                                  },
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
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Editar componente próximamente'),
                                      ),
                                    );
                                  },
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
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Eliminar componente próximamente'),
                                      ),
                                    );
                                  },
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
                      stateManager.setPageSize(15, notify: false);
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
}
