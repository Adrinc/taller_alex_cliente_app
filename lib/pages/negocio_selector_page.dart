import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/models/nethive/negocio_model.dart';
import 'package:nethive_neo/theme/theme.dart';

class NegocioSelectorPage extends StatefulWidget {
  final String empresaId;

  const NegocioSelectorPage({
    super.key,
    required this.empresaId,
  });

  @override
  State<NegocioSelectorPage> createState() => _NegocioSelectorPageState();
}

class _NegocioSelectorPageState extends State<NegocioSelectorPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  List<Negocio> _filteredNegocios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadNegocios();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNegocios() async {
    final provider =
        Provider.of<EmpresasNegociosProvider>(context, listen: false);

    try {
      await provider.getNegocios(empresaId: widget.empresaId);
      setState(() {
        _filteredNegocios = provider.negocios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar sucursales: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterNegocios(String query) {
    final provider =
        Provider.of<EmpresasNegociosProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredNegocios = provider.negocios;
      } else {
        _filteredNegocios = provider.negocios
            .where((negocio) =>
                negocio.nombre.toLowerCase().contains(query.toLowerCase()) ||
                negocio.direccion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryBackground,
              theme.secondaryBackground,
              theme.tertiaryBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de retroceso
              Container(
                padding: const EdgeInsets.all(16), // Reducido de 24 a 16
                child: Column(
                  children: [
                    // Barra superior con botón atrás
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Sucursales',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 56), // Balance para centrar
                      ],
                    ),

                    const SizedBox(height: 16), // Reducido de 20 a 16

                    // Icono y título
                    Container(
                      width: 60, // Reducido de 80 a 60
                      height: 60, // Reducido de 80 a 60
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.secondaryColor, theme.tertiaryColor],
                        ),
                        borderRadius:
                            BorderRadius.circular(16), // Reducido de 20 a 16
                        boxShadow: [
                          BoxShadow(
                            color: theme.secondaryColor.withOpacity(0.3),
                            blurRadius: 15, // Reducido de 20 a 15
                            offset: const Offset(0, 6), // Reducido de 8 a 6
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_city,
                        color: Colors.white,
                        size: 28, // Reducido de 40 a 28
                      ),
                    )
                        .animate()
                        .scale(delay: 200.ms, duration: 800.ms)
                        .fadeIn(duration: 800.ms),

                    const SizedBox(height: 16), // Reducido de 20 a 16

                    Text(
                      'Selecciona la Sucursal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Tamaño fijo más pequeño
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 6), // Reducido de 8 a 6

                    Text(
                      'Elige la sucursal donde realizarás el trabajo',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14, // Tamaño fijo más pequeño
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                  ],
                ),
              ),

              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16), // Reducido de 24 a 16
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterNegocios,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar sucursal...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.all(12), // Reducido de 16 a 12
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

              const SizedBox(height: 16), // Reducido de 24 a 16

              // Lista de negocios
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(theme)
                    : _buildNegociosList(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitPulse(
            color: theme.secondaryColor,
            size: 50,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando sucursales...',
            style: theme.bodyText1.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNegociosList(AppTheme theme) {
    if (_filteredNegocios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron sucursales',
              style: theme.bodyText1.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredNegocios.length,
      itemBuilder: (context, index) {
        final negocio = _filteredNegocios[index];
        return _buildNegocioCard(negocio, index, theme);
      },
    );
  }

  Widget _buildNegocioCard(Negocio negocio, int index, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Reducido de 16 a 12
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16), // Reducido de 20 a 16
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8, // Reducido de 10 a 8
            offset: const Offset(0, 3), // Reducido de 4 a 3
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navegamos al home del técnico con el negocioId
            context.go('/home?negocioId=${negocio.id}');
          },
          borderRadius: BorderRadius.circular(16), // Reducido de 20 a 16
          child: Padding(
            padding: const EdgeInsets.all(14), // Reducido de 20 a 14
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar del negocio
                    Container(
                      width: 50, // Reducido de 60 a 50
                      height: 50, // Reducido de 60 a 50
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.tertiaryColor, theme.primaryColor],
                        ),
                        borderRadius:
                            BorderRadius.circular(12), // Reducido de 16 a 12
                      ),
                      child: negocio.logoUrl?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  12), // Reducido de 16 a 12
                              child: Image.network(
                                negocio.logoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 24, // Reducido de 30 a 24
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 24, // Reducido de 30 a 24
                            ),
                    ),

                    const SizedBox(
                        width:
                            12), // Reducido de 16 a 12                    // Información básica
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            negocio.nombre,
                            style: theme.subtitle1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Agregado tamaño específico
                            ),
                          ),
                          const SizedBox(height: 3), // Reducido de 4 a 3
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, // Reducido de 8 a 6
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.secondaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              negocio.tipoLocal,
                              style: theme.bodyText3.copyWith(
                                color: theme.secondaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 11, // Agregado tamaño específico
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icono de flecha
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.6),
                      size: 18, // Reducido de 20 a 18
                    ),
                  ],
                ),

                const SizedBox(height: 12), // Reducido de 16 a 12

                // Dirección con icono
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withOpacity(0.6),
                      size: 14, // Reducido de 16 a 14
                    ),
                    const SizedBox(width: 6), // Reducido de 8 a 6
                    Expanded(
                      child: Text(
                        negocio.direccion.isNotEmpty
                            ? negocio.direccion
                            : 'Dirección no especificada',
                        style: theme.bodyText2.copyWith(
                          color: Colors.white60,
                          fontSize: 13, // Agregado tamaño específico
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Coordenadas
                const SizedBox(height: 6), // Reducido de 8 a 6
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      color: theme.primaryColor.withOpacity(0.8),
                      size: 14, // Reducido de 16 a 14
                    ),
                    const SizedBox(width: 6), // Reducido de 8 a 6
                    Text(
                      'Lat: ${negocio.latitud.toStringAsFixed(4)}, Lng: ${negocio.longitud.toStringAsFixed(4)}',
                      style: theme.bodyText3.copyWith(
                        color: theme.primaryColor,
                        fontSize: 11, // Agregado tamaño específico
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)))
        .slideX(begin: 0.3, end: 0, duration: 600.ms)
        .shimmer(delay: Duration(milliseconds: 800 + (index * 100)));
  }
}
