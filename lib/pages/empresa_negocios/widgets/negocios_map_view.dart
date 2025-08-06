import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/models/nethive/negocio_model.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class NegociosMapView extends StatefulWidget {
  final EmpresasNegociosProvider provider;

  const NegociosMapView({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<NegociosMapView> createState() => _NegociosMapViewState();
}

class _NegociosMapViewState extends State<NegociosMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _markerAnimationController;
  late AnimationController _tooltipAnimationController;
  late Animation<double> _markerAnimation;
  late Animation<double> _tooltipAnimation;
  late Animation<Offset> _tooltipSlideAnimation;

  String? _hoveredNegocioId;
  Offset? _tooltipPosition;
  bool _showTooltip = false;
  String? _lastEmpresaId; // Para detectar cambios de empresa

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tooltipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _markerAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _markerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _tooltipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tooltipAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _tooltipSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _tooltipAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Centrar el mapa después de que se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMapIfNeeded();
    });
  }

  @override
  void didUpdateWidget(NegociosMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Detectar si cambió la empresa seleccionada o si cambiaron los negocios
    if (oldWidget.provider.empresaSeleccionadaId !=
            widget.provider.empresaSeleccionadaId ||
        oldWidget.provider.negocios.length != widget.provider.negocios.length) {
      _initializeMapIfNeeded();
    }
  }

  // Nuevo método que verifica si debe inicializar el mapa
  void _initializeMapIfNeeded() {
    final currentEmpresaId = widget.provider.empresaSeleccionadaId;

    // Inicializar si hay empresa seleccionada y negocios, y si cambió la empresa o es la primera vez
    if (currentEmpresaId != null && widget.provider.negocios.isNotEmpty) {
      // Si es la primera vez o cambió la empresa
      if (_lastEmpresaId != currentEmpresaId) {
        _lastEmpresaId = currentEmpresaId;
        _initializeMap();
      }
      // O si ya teníamos la misma empresa pero ahora hay negocios (caso de carga inicial)
      else if (_lastEmpresaId == currentEmpresaId &&
          widget.provider.negocios.isNotEmpty) {
        _initializeMap();
      }
    }
  }

  // Nuevo método para inicializar el mapa con refresh forzado
  void _initializeMap() async {
    // Esperar un poco más para asegurar que el widget esté completamente construido
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      _centerMapOnNegocios();

      // Forzar un refresh del mapa después de centrar
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _forceMapRefresh();
      }
    }
  }

  // Método para forzar el refresh del mapa
  void _forceMapRefresh() {
    // Hacer un pequeño movimiento para forzar el renderizado de los tiles
    final currentCenter = _mapController.camera.center;
    final currentZoom = _mapController.camera.zoom;

    // Mover ligeramente y regresar a la posición original
    _mapController.move(
      LatLng(currentCenter.latitude + 0.0001, currentCenter.longitude + 0.0001),
      currentZoom,
    );

    // Regresar a la posición original después de un breve delay
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _mapController.move(currentCenter, currentZoom);
      }
    });
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    _tooltipAnimationController.dispose();
    super.dispose();
  }

  void _showTooltipForNegocio(String negocioId, Offset position) {
    setState(() {
      _hoveredNegocioId = negocioId;
      _tooltipPosition = Offset(
        position.dx - 300, // Más cerca del cursor
        position.dy - 500, // Más cerca del cursor
      );
      _showTooltip = true;
    });

    _markerAnimationController.forward();
    _tooltipAnimationController.forward();
  }

  void _hideTooltip() {
    _tooltipAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _hoveredNegocioId = null;
          _showTooltip = false;
          _tooltipPosition = null;
        });
      }
    });
    _markerAnimationController.reverse();
  }

  void _centerMapOnNegocios() {
    if (widget.provider.negocios.isNotEmpty) {
      final bounds = _calculateBounds();
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
          maxZoom: 8, // Reducido de 15 a 8 para aparecer más alejado
          minZoom: 2, // Zoom mínimo para evitar que se aleje demasiado
        ),
      );
    }
  }

  LatLngBounds _calculateBounds() {
    if (widget.provider.negocios.isEmpty) {
      return LatLngBounds(
        const LatLng(-90, -180),
        const LatLng(90, 180),
      );
    }

    double minLat = widget.provider.negocios.first.latitud;
    double maxLat = widget.provider.negocios.first.latitud;
    double minLng = widget.provider.negocios.first.longitud;
    double maxLng = widget.provider.negocios.first.longitud;

    for (final negocio in widget.provider.negocios) {
      minLat = minLat < negocio.latitud ? minLat : negocio.latitud;
      maxLat = maxLat > negocio.latitud ? maxLat : negocio.latitud;
      minLng = minLng < negocio.longitud ? minLng : negocio.longitud;
      maxLng = maxLng > negocio.longitud ? maxLng : negocio.longitud;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.provider.negocios.isEmpty) {
      return _buildEmptyMapState();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Listener para detectar movimientos del mouse sobre el mapa
            MouseRegion(
              onExit: (_) => _hideTooltip(),
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(19.4326, -99.1332),
                  initialZoom: 10,
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  // Capa de tiles del mapa
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.nethive.app',
                  ),

                  // Capa de marcadores
                  MarkerLayer(
                    markers: _buildMarkers(),
                  ),
                ],
              ),
            ),

            // Header del mapa con información
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: _buildMapHeader(),
            ),

            // Controles del mapa
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildMapControls(),
            ),

            // Tooltip flotante con información del negocio
            if (_showTooltip && _tooltipPosition != null)
              Positioned(
                left: _tooltipPosition!.dx
                    .clamp(20.0, MediaQuery.of(context).size.width - 280),
                top: _tooltipPosition!.dy
                    .clamp(20.0, MediaQuery.of(context).size.height - 150),
                child: _buildAnimatedTooltip(),
              ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return widget.provider.negocios.map((negocio) {
      final isHovered = _hoveredNegocioId == negocio.id;

      return Marker(
        point: LatLng(negocio.latitud, negocio.longitud),
        width: 50,
        height: 50,
        child: MouseRegion(
          cursor: SystemMouseCursors.click, // Cursor de puntero
          onEnter: (event) {
            _showTooltipForNegocio(negocio.id, event.position);
          },
          onHover: (event) {
            // Actualizar posición del tooltip sin recalcular todo
            if (_hoveredNegocioId == negocio.id) {
              setState(() {
                _tooltipPosition = Offset(
                  event.position.dx - 300, // Más cerca del cursor
                  event.position.dy - 400, // Más cerca del cursor
                );
              });
            }
          },
          child: GestureDetector(
            onTap: () {
              // Navegar a la infraestructura del negocio
              context.go('/infrastructure/${negocio.id}');
            },
            child: AnimatedBuilder(
              animation: _markerAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isHovered ? _markerAnimation.value : 1.0,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isHovered
                          ? AppTheme.of(context).primaryGradient
                          : AppTheme.of(context).modernGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.of(context)
                              .primaryColor
                              .withOpacity(0.4),
                          blurRadius: isHovered ? 15 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white,
                        width: isHovered ? 3 : 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildMarkerContent(negocio, isHovered),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMarkerContent(Negocio negocio, bool isHovered) {
    // Verificar si tiene imagen válida
    if (negocio.imagenUrl != null && negocio.imagenUrl!.isNotEmpty) {
      final imageUrl =
          "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/imagenes/${negocio.imagenUrl}";

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) {
          // Si falla la imagen, mostrar el ícono
          return _buildMarkerIcon(isHovered);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          // Mientras carga, mostrar el ícono
          return _buildMarkerIcon(isHovered);
        },
      );
    } else {
      // Si no hay imagen, mostrar el ícono
      return _buildMarkerIcon(isHovered);
    }
  }

  Widget _buildMarkerIcon(bool isHovered) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Icon(
        Icons.store,
        color: Colors.white,
        size: isHovered ? 22 : 18,
      ),
    );
  }

  Widget _buildAnimatedTooltip() {
    final negocio = widget.provider.negocios.firstWhere(
      (n) => n.id == _hoveredNegocioId,
    );

    return SlideTransition(
      position: _tooltipSlideAnimation,
      child: FadeTransition(
        opacity: _tooltipAnimation,
        child: ScaleTransition(
          scale: _tooltipAnimation,
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).modernGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con imagen y nombre
                Row(
                  children: [
                    // Imagen del negocio o ícono por defecto
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildTooltipImage(negocio),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            negocio.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              negocio.tipoLocal,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Información de ubicación
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        negocio.direccion,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Coordenadas
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lat: ${negocio.latitud.toStringAsFixed(4)}, Lng: ${negocio.longitud.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Call to action
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Clic para ver infraestructura',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipImage(Negocio negocio) {
    // Verificar si tiene imagen válida
    if (negocio.imagenUrl != null && negocio.imagenUrl!.isNotEmpty) {
      final imageUrl =
          "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/imagenes/${negocio.imagenUrl}";

      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          // Si falla la imagen, mostrar el ícono
          return _buildTooltipIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          // Mientras carga, mostrar un spinner
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        },
      );
    } else {
      // Si no hay imagen, mostrar el ícono
      return _buildTooltipIcon();
    }
  }

  Widget _buildTooltipIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.store,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildMapHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.of(context).primaryGradient,
        borderRadius: BorderRadius.circular(15),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.map,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mapa de Sucursales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.provider.negocios.length} ubicaciones de ${widget.provider.empresaSeleccionada?.nombre ?? ""}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'OpenStreetMap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _buildMapControls() {
    return Column(
      children: [
        // Botón de centrar mapa
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.of(context).primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _centerMapOnNegocios,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.center_focus_strong,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón de zoom in
        Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom + 1,
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.add,
                  color: AppTheme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Botón de zoom out
        Container(
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _mapController.move(
                  _mapController.camera.center,
                  _mapController.camera.zoom - 1,
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.remove,
                  color: AppTheme.of(context).primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMapState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.blue.withOpacity(0.3),
            AppTheme.of(context).primaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.of(context).primaryColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.of(context).modernGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.location_off,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin ubicaciones para mostrar',
              style: TextStyle(
                color: AppTheme.of(context).primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona una empresa con sucursales\npara ver sus ubicaciones en el mapa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isHovered => _hoveredNegocioId != null;
}
