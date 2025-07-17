import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/pages/widgets/animated_hover_button.dart';
import 'package:nethive_neo/theme/theme.dart';

class NegociosTable extends StatelessWidget {
  final EmpresasNegociosProvider provider;

  const NegociosTable({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
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
          scrollBarColor: AppTheme.of(context).primaryColor.withOpacity(0.7),
          scrollBarTrackColor: Colors.grey.withOpacity(0.2),
          scrollbarRadius: const Radius.circular(8),
          scrollbarRadiusWhileDragging: const Radius.circular(10),
        ),
        style: PlutoGridStyleConfig(
          gridBorderColor: Colors.grey.withOpacity(0.3),
          activatedBorderColor: AppTheme.of(context).primaryColor,
          inactivatedBorderColor: Colors.grey.withOpacity(0.3),
          gridBackgroundColor: AppTheme.of(context).primaryBackground,
          rowColor: AppTheme.of(context).secondaryBackground,
          activatedColor: AppTheme.of(context).primaryColor.withOpacity(0.1),
          checkedColor: AppTheme.of(context).primaryColor.withOpacity(0.2),
          cellTextStyle: TextStyle(
            color: AppTheme.of(context).primaryText,
            fontSize: 14,
          ),
          columnTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          menuBackgroundColor: AppTheme.of(context).secondaryBackground,
          gridBorderRadius: BorderRadius.circular(8),
          rowHeight: 60,
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
              rendererContext.cell.value.toString().substring(0, 8) + '...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Nombre de Sucursal',
          field: 'nombre',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
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
                  // Logo del negocio
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        rendererContext.row.cells['logo_url']?.value != null &&
                                rendererContext.row.cells['logo_url']!.value
                                    .toString()
                                    .isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  rendererContext.row.cells['logo_url']!.value
                                      .toString(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/placeholder_no_image.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              )
                            : Image.asset(
                                'assets/images/placeholder_no_image.jpg',
                                fit: BoxFit.cover,
                              ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rendererContext.cell.value.toString(),
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 14,
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
          title: 'Ciudad',
          field: 'direccion',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 180,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          backgroundColor: AppTheme.of(context).primaryColor,
          enableContextMenu: false,
          enableDropToResize: false,
          renderer: (rendererContext) {
            // Extraer solo la ciudad de la dirección completa
            String direccionCompleta = rendererContext.cell.value.toString();
            String ciudad = _extraerCiudad(direccionCompleta);
            return Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                ciudad,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Empleados',
          field: 'tipo_local',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 120,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          backgroundColor: AppTheme.of(context).primaryColor,
          enableContextMenu: false,
          enableDropToResize: false,
          renderer: (rendererContext) {
            // Simulamos cantidad de empleados basado en el tipo de local
            String empleados =
                rendererContext.cell.value.toString() == 'Sucursal'
                    ? '95'
                    : '120';
            return Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                '$empleados empleados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Dirección Completa',
          field: 'direccion_completa',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 280,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          backgroundColor: AppTheme.of(context).primaryColor,
          enableContextMenu: false,
          enableDropToResize: false,
          renderer: (rendererContext) {
            // Usamos la dirección del row en lugar del cell
            String direccion =
                rendererContext.row.cells['direccion']?.value.toString() ?? '';
            return Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                direccion,
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Coordenadas',
          field: 'latitud',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 150,
          type: PlutoColumnType.text(),
          enableEditingMode: false,
          backgroundColor: AppTheme.of(context).primaryColor,
          enableContextMenu: false,
          enableDropToResize: false,
          renderer: (rendererContext) {
            final latitud = rendererContext.row.cells['latitud']?.value ?? '0';
            final longitud =
                rendererContext.row.cells['longitud']?.value ?? '0';
            return Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lat: ${double.parse(latitud.toString()).toStringAsFixed(4)}',
                    style: TextStyle(
                      color: AppTheme.of(context).primaryText,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Lng: ${double.parse(longitud.toString()).toStringAsFixed(4)}',
                    style: TextStyle(
                      color: AppTheme.of(context).primaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        PlutoColumn(
          title: 'Infraestructura',
          field: 'acceder_infraestructura',
          titleTextAlign: PlutoColumnTextAlign.center,
          textAlign: PlutoColumnTextAlign.center,
          width: 200,
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade600,
                        Colors.deepOrange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final negocioId =
                            rendererContext.row.cells['id']?.value;
                        final negocioNombre =
                            rendererContext.row.cells['nombre']?.value;

                        if (negocioId != null) {
                          // Navegar al layout principal con el negocio seleccionado
                          context.go('/infrastructure/$negocioId');
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.developer_board,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Acceder a\nInfraestructura',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                // Botón editar
                Tooltip(
                  message: 'Editar negocio',
                  child: InkWell(
                    onTap: () {
                      // TODO: Implementar edición
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Función de edición próximamente')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón ver componentes
                Tooltip(
                  message: 'Ver componentes',
                  child: InkWell(
                    onTap: () {
                      // TODO: Navegar a componentes
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Navegando a componentes de ${rendererContext.row.cells['nombre']?.value}',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botón eliminar
                Tooltip(
                  message: 'Eliminar negocio',
                  child: InkWell(
                    onTap: () {
                      _showDeleteDialog(
                        context,
                        rendererContext.row.cells['id']?.value,
                        rendererContext.row.cells['nombre']?.value,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
      rows: provider.negociosRows,
      onLoaded: (event) {
        provider.negociosStateManager = event.stateManager;
      },
      createFooter: (stateManager) {
        stateManager.setPageSize(10, notify: false);
        return PlutoPagination(stateManager);
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, String? negocioId, String? nombre) {
    if (negocioId == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).primaryBackground,
          title: const Text('Confirmar eliminación'),
          content: Text(
              '¿Estás seguro de que deseas eliminar la sucursal "$nombre"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.of(context).secondaryText),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await provider.eliminarNegocio(negocioId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Sucursal eliminada correctamente'
                            : 'Error al eliminar la sucursal',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  String _extraerCiudad(String direccionCompleta) {
    // Lógica para extraer la ciudad de la dirección completa
    // Suponiendo que la ciudad es la segunda palabra en la dirección
    List<String> partes = direccionCompleta.split(',');
    return partes.length > 1 ? partes[1].trim() : direccionCompleta;
  }
}
