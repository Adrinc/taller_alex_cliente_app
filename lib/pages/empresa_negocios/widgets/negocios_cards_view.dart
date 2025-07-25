import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class NegociosCardsView extends StatelessWidget {
  final EmpresasNegociosProvider provider;

  const NegociosCardsView({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (provider.empresaSeleccionada == null) {
      return _buildEmptyState(context);
    }

    if (provider.negocios.isEmpty) {
      return _buildNoDataState(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: provider.negocios.length,
        itemBuilder: (context, index) {
          final negocio = provider.negocios[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.of(context).secondaryBackground,
                          AppTheme.of(context).tertiaryBackground,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.of(context)
                              .primaryColor
                              .withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showNegocioDetails(context, negocio);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header con logo y nombre
                                Row(
                                  children: [
                                    // Logo del negocio
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.of(context)
                                            .primaryGradient,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: negocio.logoUrl != null &&
                                              negocio.logoUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.network(
                                                "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/logos/${negocio.logoUrl}",
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    'assets/images/placeholder_no_image.jpg',
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                              ),
                                            )
                                          : Icon(
                                              Icons.store,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Información principal
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            negocio.nombre,
                                            style: TextStyle(
                                              color: AppTheme.of(context)
                                                  .primaryText,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: AppTheme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                            child: Text(
                                              negocio.tipoLocal.isNotEmpty
                                                  ? negocio.tipoLocal
                                                  : 'Sucursal',
                                              style: TextStyle(
                                                color: AppTheme.of(context)
                                                    .primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Botón de acciones
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                      color: AppTheme.of(context)
                                          .secondaryBackground,
                                      onSelected: (value) {
                                        _handleMenuAction(
                                            context, value, negocio);
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: AppTheme.of(context)
                                                      .primaryColor),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Editar',
                                                style: TextStyle(
                                                    color: AppTheme.of(context)
                                                        .primaryText),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'components',
                                          child: Row(
                                            children: [
                                              Icon(Icons.inventory_2,
                                                  color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Ver Componentes',
                                                style: TextStyle(
                                                    color: AppTheme.of(context)
                                                        .primaryText),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: Colors.red),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Eliminar',
                                                style: TextStyle(
                                                    color: AppTheme.of(context)
                                                        .primaryText),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Información de ubicación
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .primaryBackground
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: AppTheme.of(context)
                                                .primaryColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Ubicación',
                                            style: TextStyle(
                                              color: AppTheme.of(context)
                                                  .primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        negocio.direccion.isNotEmpty
                                            ? negocio.direccion
                                            : 'Sin dirección',
                                        style: TextStyle(
                                          color:
                                              AppTheme.of(context).primaryText,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Coordenadas y estadísticas
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoChip(
                                        context,
                                        icon: Icons.gps_fixed,
                                        label: 'Coordenadas',
                                        value:
                                            '${negocio.latitud.toStringAsFixed(4)}, ${negocio.longitud.toStringAsFixed(4)}',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInfoChip(
                                        context,
                                        icon: Icons.people,
                                        label: 'Empleados',
                                        value: negocio.tipoLocal == 'Sucursal'
                                            ? '95'
                                            : '120',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Fecha de creación
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppTheme.of(context).secondaryText,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Creado: ${negocio.fechaCreacion.toString().split(' ')[0]}',
                                      style: TextStyle(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.of(context).primaryColor.withOpacity(0.1),
            AppTheme.of(context).tertiaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.of(context).primaryColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.of(context).primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_center,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona una empresa',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón de empresas para seleccionar una y ver sus sucursales',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.store_mall_directory,
              size: 60,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin sucursales',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Esta empresa aún no tiene sucursales registradas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNegocioDetails(BuildContext context, dynamic negocio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Contenido del modal
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de la Sucursal',
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Aquí puedes agregar más detalles específicos
                      Text(
                        'Información adicional de ${negocio.nombre}',
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, dynamic negocio) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Función de edición próximamente')),
        );
        break;
      case 'components':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ver componentes de ${negocio.nombre}')),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, negocio);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, dynamic negocio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.of(context).primaryBackground,
        title: Text(
          'Confirmar eliminación',
          style: TextStyle(color: AppTheme.of(context).primaryText),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la sucursal "${negocio.nombre}"?',
          style: TextStyle(color: AppTheme.of(context).secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.of(context).secondaryText),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Cerrar el diálogo antes de la operación asíncrona
              Navigator.pop(context);

              // Mostrar indicador de carga
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.of(context).primaryColor,
                    ),
                  ),
                );
              }

              try {
                final success = await provider.eliminarNegocio(negocio.id);

                // Cerrar indicador de carga
                if (context.mounted) {
                  Navigator.pop(context);
                }

                // Mostrar resultado solo si el contexto sigue válido
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            success ? Icons.check_circle : Icons.error,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            success
                                ? 'Sucursal eliminada correctamente'
                                : 'Error al eliminar la sucursal',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                // Cerrar indicador de carga en caso de error
                if (context.mounted) {
                  Navigator.pop(context);
                }

                // Mostrar error solo si el contexto sigue válido
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error: $e',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
