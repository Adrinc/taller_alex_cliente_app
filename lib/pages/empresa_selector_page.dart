import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/models/nethive/empresa_model.dart';
import 'package:nethive_neo/theme/theme.dart';

class EmpresaSelectorPage extends StatefulWidget {
  const EmpresaSelectorPage({super.key});

  @override
  State<EmpresaSelectorPage> createState() => _EmpresaSelectorPageState();
}

class _EmpresaSelectorPageState extends State<EmpresaSelectorPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _loadingController;
  final TextEditingController _searchController = TextEditingController();
  List<Empresa> _filteredEmpresas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadEmpresas();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmpresas() async {
    final provider =
        Provider.of<EmpresasNegociosProvider>(context, listen: false);

    try {
      await provider.getEmpresas();
      setState(() {
        _filteredEmpresas = provider.empresas;
        _isLoading = false;
      });
      _loadingController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar empresas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterEmpresas(String query) {
    final provider =
        Provider.of<EmpresasNegociosProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredEmpresas = provider.empresas;
      } else {
        _filteredEmpresas = provider.empresas
            .where((empresa) =>
                empresa.nombre.toLowerCase().contains(query.toLowerCase()))
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
              // Header con animación
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Logo animado
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.alternate],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.business,
                        color: Colors.white,
                        size: 40,
                      ),
                    )
                        .animate()
                        .scale(delay: 200.ms, duration: 800.ms)
                        .fadeIn(duration: 800.ms),

                    const SizedBox(height: 20),

                    // Título
                    Text(
                      'Selecciona tu Empresa',
                      style: theme.title1.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      'Elige la empresa donde realizarás el trabajo técnico',
                      style: theme.bodyText2.copyWith(color: Colors.white60),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                  ],
                ),
              ),

              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    onChanged: _filterEmpresas,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar empresa...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideX(begin: -0.3, end: 0),

              const SizedBox(height: 24),

              // Lista de empresas
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(theme)
                    : _buildEmpresasList(theme),
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
          SpinKitWave(
            color: theme.primaryColor,
            size: 50,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando empresas...',
            style: theme.bodyText1.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpresasList(AppTheme theme) {
    if (_filteredEmpresas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron empresas',
              style: theme.bodyText1.copyWith(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredEmpresas.length,
      itemBuilder: (context, index) {
        final empresa = _filteredEmpresas[index];
        return _buildEmpresaCard(empresa, index, theme);
      },
    );
  }

  Widget _buildEmpresaCard(Empresa empresa, int index, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.go('/negocio-selector?empresaId=${empresa.id}');
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar de empresa
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: empresa.logoUrl?.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            empresa.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.business,
                          color: Colors.white,
                          size: 30,
                        ),
                ),

                const SizedBox(width: 16),

                // Información de empresa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empresa.nombre,
                        style: theme.subtitle1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (empresa.direccion.isNotEmpty)
                        Text(
                          empresa.direccion,
                          style: theme.bodyText2.copyWith(
                            color: Colors.white60,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'RFC: ${empresa.rfc}',
                          style: theme.bodyText3.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
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
                  size: 20,
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
