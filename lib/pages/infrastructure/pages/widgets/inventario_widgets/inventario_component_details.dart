import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'inventario_status_indicator.dart';
import 'inventario_enhanced_detail_card.dart';

class InventarioComponentDetails extends StatelessWidget {
  final dynamic componente;
  final ComponentesProvider provider;
  final Function(dynamic componente, ComponentesProvider provider)
      onEditComponent;
  final Function(dynamic componente, ComponentesProvider provider)
      onDeleteComponent;
  final Function(String categoryName) getCategoryIcon;

  const InventarioComponentDetails({
    Key? key,
    required this.componente,
    required this.provider,
    required this.onEditComponent,
    required this.onDeleteComponent,
    required this.getCategoryIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (componente == null) return const SizedBox.shrink();

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

    return Dialog(
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
                ? _buildDesktopDetailLayout(context, categoria, imagenUrl)
                : _buildMobileDetailLayout(context, categoria, imagenUrl),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopDetailLayout(
      BuildContext context, dynamic categoria, String? imagenUrl) {
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
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: imagenUrl != null && imagenUrl.isNotEmpty
                        ? Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.1),
                                child: Icon(
                                  getCategoryIcon(categoria?.nombre ?? ''),
                                  color: Colors.white,
                                  size: 80,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.1),
                            child: Icon(
                              getCategoryIcon(categoria?.nombre ?? ''),
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
                        Icon(
                          getCategoryIcon(categoria.nombre),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoria.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                    InventarioStatusIndicator(
                      text: componente.activo ? 'Activo' : 'Inactivo',
                      icon:
                          componente.activo ? Icons.check_circle : Icons.cancel,
                      color: componente.activo ? Colors.green : Colors.red,
                    ),
                    InventarioStatusIndicator(
                      text: componente.enUso ? 'En Uso' : 'Libre',
                      icon: componente.enUso
                          ? Icons.trending_up
                          : Icons.trending_flat,
                      color: componente.enUso ? Colors.orange : Colors.grey,
                    ),
                  ],
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
                      'Información Detallada',
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                        fontSize: 18,
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
                          InventarioEnhancedDetailCard(
                            title: 'Ubicación',
                            value: componente.ubicacion!,
                            icon: Icons.location_on,
                            color: Colors.blue,
                          ),
                        if (componente.descripcion != null &&
                            componente.descripcion!.isNotEmpty)
                          InventarioEnhancedDetailCard(
                            title: 'Descripción',
                            value: componente.descripcion!,
                            icon: Icons.description,
                            color: Colors.purple,
                          ),
                        InventarioEnhancedDetailCard(
                          title: 'Fecha de Registro',
                          value: componente.fechaRegistro
                                  ?.toString()
                                  .split(' ')[0] ??
                              'No disponible',
                          icon: Icons.calendar_today,
                          color: Colors.green,
                        ),
                        InventarioEnhancedDetailCard(
                          title: 'ID del Componente',
                          value: componente.id.substring(0, 8) + '...',
                          icon: Icons.fingerprint,
                          color: Colors.indigo,
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
                          onEditComponent(componente, provider);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDeleteComponent(componente, provider);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
      BuildContext context, dynamic categoria, String? imagenUrl) {
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
                              child: Icon(
                                getCategoryIcon(categoria?.nombre ?? ''),
                                color: Colors.white,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.1),
                          child: Icon(
                            getCategoryIcon(categoria?.nombre ?? ''),
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
                      child: InventarioStatusIndicator(
                        text: componente.activo ? 'Activo' : 'Inactivo',
                        icon: componente.activo
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: componente.activo ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InventarioStatusIndicator(
                        text: componente.enUso ? 'En Uso' : 'Libre',
                        icon: componente.enUso
                            ? Icons.trending_up
                            : Icons.trending_flat,
                        color: componente.enUso ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (componente.ubicacion != null &&
                    componente.ubicacion!.isNotEmpty)
                  InventarioEnhancedDetailCard(
                    title: 'Ubicación',
                    value: componente.ubicacion!,
                    icon: Icons.location_on,
                    color: Colors.blue,
                  ),

                if (componente.descripcion != null &&
                    componente.descripcion!.isNotEmpty)
                  InventarioEnhancedDetailCard(
                    title: 'Descripción',
                    value: componente.descripcion!,
                    icon: Icons.description,
                    color: Colors.purple,
                  ),

                InventarioEnhancedDetailCard(
                  title: 'Fecha de Registro',
                  value: componente.fechaRegistro?.toString().split(' ')[0] ??
                      'No disponible',
                  icon: Icons.calendar_today,
                  color: Colors.green,
                ),

                InventarioEnhancedDetailCard(
                  title: 'ID del Componente',
                  value: componente.id.substring(0, 8) + '...',
                  icon: Icons.fingerprint,
                  color: Colors.indigo,
                ),

                const SizedBox(height: 20),

                // Botones de acción para móvil
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEditComponent(componente, provider);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDeleteComponent(componente, provider);
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Eliminar',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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

  static void show(
    BuildContext context, {
    required dynamic componente,
    required ComponentesProvider provider,
    required Function(dynamic componente, ComponentesProvider provider)
        onEditComponent,
    required Function(dynamic componente, ComponentesProvider provider)
        onDeleteComponent,
    required Function(String categoryName) getCategoryIcon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InventarioComponentDetails(
        componente: componente,
        provider: provider,
        onEditComponent: onEditComponent,
        onDeleteComponent: onDeleteComponent,
        getCategoryIcon: getCategoryIcon,
      ),
    );
  }
}
