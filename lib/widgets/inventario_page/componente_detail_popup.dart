import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class ComponenteDetailPopup extends StatefulWidget {
  final Componente componente;

  const ComponenteDetailPopup({
    super.key,
    required this.componente,
  });

  @override
  State<ComponenteDetailPopup> createState() => _ComponenteDetailPopupState();
}

class _ComponenteDetailPopupState extends State<ComponenteDetailPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Map<String, dynamic>? _detalleComponente;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cargarDetalleComponente();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarDetalleComponente() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final String tableName =
          _getDetalleTableName(widget.componente.categoriaId);

      print(
          'Cargando detalles desde tabla: $tableName para componente: ${widget.componente.id}');

      final response = await supabaseLU
          .from(tableName)
          .select('*')
          .eq('componente_id', widget.componente.id)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _detalleComponente = response;
          _isLoading = false;
        });
        print('Detalles cargados: $response');
      } else {
        setState(() {
          _detalleComponente = null;
          _isLoading = false;
        });
        print('No se encontraron detalles para este componente');
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar detalles: $e';
        _isLoading = false;
      });
      print('Error cargando detalles del componente: $e');
    }
  }

  String _getDetalleTableName(int categoriaId) {
    switch (categoriaId) {
      case 1: // Cable
        return 'detalle_cable';
      case 2: // Switch
        return 'detalle_switch';
      case 3: // Patch Panel
        return 'detalle_patch_panel';
      case 4: // Rack
        return 'detalle_rack';
      case 5: // UPS
        return 'detalle_ups';
      default:
        throw Exception('Tipo de componente no soportado: $categoriaId');
    }
  }

  String _getCategoryName(int categoriaId) {
    switch (categoriaId) {
      case 1:
        return 'Cable';
      case 2:
        return 'Switch';
      case 3:
        return 'Patch Panel';
      case 4:
        return 'Rack';
      case 5:
        return 'UPS';
      default:
        return 'Componente';
    }
  }

  IconData _getCategoryIcon(int categoriaId) {
    switch (categoriaId) {
      case 1:
        return Icons.cable;
      case 2:
        return Icons.hub;
      case 3:
        return Icons.dashboard;
      case 4:
        return Icons.developer_board;
      case 5:
        return Icons.battery_charging_full;
      default:
        return Icons.memory;
    }
  }

  Color _getCategoryColor(int categoriaId) {
    switch (categoriaId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.green;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryBackground,
              theme.secondaryBackground,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header del popup
            _buildHeader(theme),

            // Contenido
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(theme)
                  : _error != null
                      ? _buildErrorState(theme)
                      : _buildContent(theme),
            ),

            // Botones de acción
            _buildActionButtons(theme),
          ],
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 300.ms),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    final categoryColor = _getCategoryColor(widget.componente.categoriaId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [categoryColor.withOpacity(0.8), categoryColor],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(widget.componente.categoriaId),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.componente.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryName(widget.componente.categoriaId),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.3, end: 0, duration: 500.ms)
        .fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _getCategoryColor(widget.componente.categoriaId),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando detalles...',
            style: TextStyle(
              color: theme.primaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar detalles',
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Error desconocido',
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cargarDetalleComponente,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _getCategoryColor(widget.componente.categoriaId),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppTheme theme) {
    if (_detalleComponente == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                color: theme.secondaryText,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Sin detalles específicos',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este componente no tiene detalles técnicos registrados.',
                style: TextStyle(
                  color: theme.secondaryText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del componente
          _buildComponentImage(theme),

          const SizedBox(height: 20),

          // Información básica del componente
          _buildBasicInfo(theme),

          const SizedBox(height: 20),

          // Detalles específicos según la categoría
          _buildCategorySpecificDetails(theme),
        ],
      ),
    );
  }

  Widget _buildComponentImage(AppTheme theme) {
    final categoryColor = _getCategoryColor(widget.componente.categoriaId);
    final categoryIcon = _getCategoryIcon(widget.componente.categoriaId);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withOpacity(0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.componente.imagenUrl?.isNotEmpty == true
            ? Stack(
                children: [
                  // Imagen principal
                  Image.network(
                    "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/componentes/${widget.componente.imagenUrl!}",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder(
                          categoryIcon, categoryColor, theme);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildImagePlaceholder(
                          categoryIcon, categoryColor, theme,
                          isLoading: true);
                    },
                  ),
                  // Overlay con información de categoría
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcon,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getCategoryName(widget.componente.categoriaId),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _buildImagePlaceholder(categoryIcon, categoryColor, theme),
      ),
    )
        .animate()
        .slideY(begin: -0.2, end: 0, duration: 500.ms)
        .fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Widget _buildImagePlaceholder(IconData icon, Color color, AppTheme theme,
      {bool isLoading = false}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.2),
          ],
        ),
      ),
      child: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: color,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cargando imagen...',
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color.withOpacity(0.6),
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  _getCategoryName(widget.componente.categoriaId),
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sin imagen disponible',
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBasicInfo(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _getCategoryColor(widget.componente.categoriaId).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información General',
            style: TextStyle(
              color: theme.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.componente.descripcion?.isNotEmpty == true) ...[
            _buildDetailRow(
                'Descripción', widget.componente.descripcion!, theme),
            const SizedBox(height: 8),
          ],
          if (widget.componente.ubicacion?.isNotEmpty == true) ...[
            _buildDetailRow('Ubicación', widget.componente.ubicacion!, theme),
            const SizedBox(height: 8),
          ],
          if (widget.componente.rfid?.isNotEmpty == true) ...[
            _buildDetailRow('RFID', widget.componente.rfid!, theme),
            const SizedBox(height: 8),
          ],
          _buildDetailRow(
            'Estado',
            widget.componente.enUso ? 'En Uso' : 'Disponible',
            theme,
            valueColor: widget.componente.enUso ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Fecha de Registro',
            _formatDate(widget.componente.fechaRegistro),
            theme,
          ),
        ],
      ),
    )
        .animate()
        .slideX(begin: -0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildCategorySpecificDetails(AppTheme theme) {
    switch (widget.componente.categoriaId) {
      case 1: // Cable
        return _buildCableDetails(theme);
      case 2: // Switch
        return _buildSwitchDetails(theme);
      case 3: // Patch Panel
        return _buildPatchPanelDetails(theme);
      case 4: // Rack
        return _buildRackDetails(theme);
      case 5: // UPS
        return _buildUpsDetails(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSwitchDetails(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Especificaciones del Switch',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_detalleComponente!['marca']?.isNotEmpty == true)
            _buildDetailRow('Marca', _detalleComponente!['marca'], theme),
          if (_detalleComponente!['modelo']?.isNotEmpty == true)
            _buildDetailRow('Modelo', _detalleComponente!['modelo'], theme),
          if (_detalleComponente!['numero_serie']?.isNotEmpty == true)
            _buildDetailRow(
                'Número de Serie', _detalleComponente!['numero_serie'], theme),
          if (_detalleComponente!['cantidad_puertos'] != null)
            _buildDetailRow('Cantidad de Puertos',
                '${_detalleComponente!['cantidad_puertos']} puertos', theme),
          if (_detalleComponente!['velocidad_puertos']?.isNotEmpty == true)
            _buildDetailRow('Velocidad de Puertos',
                _detalleComponente!['velocidad_puertos'], theme),
          if (_detalleComponente!['tipo_puertos']?.isNotEmpty == true)
            _buildDetailRow(
                'Tipo de Puertos', _detalleComponente!['tipo_puertos'], theme),
          if (_detalleComponente!['direccion_ip']?.isNotEmpty == true)
            _buildDetailRow(
                'Dirección IP', _detalleComponente!['direccion_ip'], theme),
          if (_detalleComponente!['firmware']?.isNotEmpty == true)
            _buildDetailRow('Firmware', _detalleComponente!['firmware'], theme),
          _buildBooleanRow(
              'Administrable', _detalleComponente!['administrable'], theme),
          _buildBooleanRow('PoE', _detalleComponente!['poe'], theme),
        ],
      ),
    )
        .animate()
        .slideX(begin: 0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildCableDetails(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cable, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Especificaciones del Cable',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_detalleComponente!['tipo_cable']?.isNotEmpty == true)
            _buildDetailRow(
                'Tipo de Cable', _detalleComponente!['tipo_cable'], theme),
          if (_detalleComponente!['color']?.isNotEmpty == true)
            _buildDetailRow('Color', _detalleComponente!['color'], theme),
          if (_detalleComponente!['tamaño'] != null)
            _buildDetailRow(
                'Tamaño', '${_detalleComponente!['tamaño']} metros', theme),
          if (_detalleComponente!['tipo_conector']?.isNotEmpty == true)
            _buildDetailRow('Tipo de Conector',
                _detalleComponente!['tipo_conector'], theme),
        ],
      ),
    )
        .animate()
        .slideX(begin: 0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildRackDetails(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_board, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Especificaciones del Rack',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_detalleComponente!['tipo']?.isNotEmpty == true)
            _buildDetailRow('Tipo', _detalleComponente!['tipo'], theme),
          if (_detalleComponente!['altura_u'] != null)
            _buildDetailRow(
                'Altura', '${_detalleComponente!['altura_u']} U', theme),
          if (_detalleComponente!['profundidad_cm'] != null)
            _buildDetailRow('Profundidad',
                '${_detalleComponente!['profundidad_cm']} cm', theme),
          if (_detalleComponente!['ancho_cm'] != null)
            _buildDetailRow(
                'Ancho', '${_detalleComponente!['ancho_cm']} cm', theme),
          if (_detalleComponente!['color']?.isNotEmpty == true)
            _buildDetailRow('Color', _detalleComponente!['color'], theme),
          _buildBooleanRow('Ventilación Integrada',
              _detalleComponente!['ventilacion_integrada'], theme),
          _buildBooleanRow('Puertas con Llave',
              _detalleComponente!['puertas_con_llave'], theme),
          _buildBooleanRow('Ruedas', _detalleComponente!['ruedas'], theme),
        ],
      ),
    )
        .animate()
        .slideX(begin: 0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildPatchPanelDetails(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Especificaciones del Patch Panel',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_detalleComponente!['tipo_conector']?.isNotEmpty == true)
            _buildDetailRow('Tipo de Conector',
                _detalleComponente!['tipo_conector'], theme),
          if (_detalleComponente!['numero_puertos'] != null)
            _buildDetailRow('Número de Puertos',
                '${_detalleComponente!['numero_puertos']} puertos', theme),
          if (_detalleComponente!['categoria']?.isNotEmpty == true)
            _buildDetailRow(
                'Categoría', _detalleComponente!['categoria'], theme),
          if (_detalleComponente!['tipo_montaje']?.isNotEmpty == true)
            _buildDetailRow(
                'Tipo de Montaje', _detalleComponente!['tipo_montaje'], theme),
          _buildBooleanRow('Numeración Frontal',
              _detalleComponente!['numeracion_frontal'], theme),
          _buildBooleanRow(
              'Panel Ciego', _detalleComponente!['panel_ciego'], theme),
        ],
      ),
    )
        .animate()
        .slideX(begin: 0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildUpsDetails(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Especificaciones del UPS',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_detalleComponente!['tipo']?.isNotEmpty == true)
            _buildDetailRow('Tipo', _detalleComponente!['tipo'], theme),
          if (_detalleComponente!['marca']?.isNotEmpty == true)
            _buildDetailRow('Marca', _detalleComponente!['marca'], theme),
          if (_detalleComponente!['modelo']?.isNotEmpty == true)
            _buildDetailRow('Modelo', _detalleComponente!['modelo'], theme),
          if (_detalleComponente!['voltaje_entrada']?.isNotEmpty == true)
            _buildDetailRow('Voltaje de Entrada',
                _detalleComponente!['voltaje_entrada'], theme),
          if (_detalleComponente!['voltaje_salida']?.isNotEmpty == true)
            _buildDetailRow('Voltaje de Salida',
                _detalleComponente!['voltaje_salida'], theme),
          if (_detalleComponente!['capacidad_va'] != null)
            _buildDetailRow('Capacidad',
                '${_detalleComponente!['capacidad_va']} VA', theme),
          if (_detalleComponente!['autonomia_minutos'] != null)
            _buildDetailRow('Autonomía',
                '${_detalleComponente!['autonomia_minutos']} minutos', theme),
          if (_detalleComponente!['cantidad_tomas'] != null)
            _buildDetailRow('Cantidad de Tomas',
                '${_detalleComponente!['cantidad_tomas']} tomas', theme),
          _buildBooleanRow(
              'Rackeable', _detalleComponente!['rackeable'], theme),
        ],
      ),
    )
        .animate()
        .slideX(begin: 0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildDetailRow(String label, String value, AppTheme theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? theme.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanRow(String label, bool? value, AppTheme theme) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: value
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.cancel,
                  color: value ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  value ? 'Sí' : 'No',
                  style: TextStyle(
                    color: value ? Colors.green : Colors.red,
                    fontSize: 12,
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

  Widget _buildActionButtons(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.tertiaryBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Cerrar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.secondaryText,
                side: BorderSide(color: theme.secondaryText.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar edición del componente
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _getCategoryColor(widget.componente.categoriaId),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 600.ms)
        .fadeIn(delay: 400.ms, duration: 400.ms);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
