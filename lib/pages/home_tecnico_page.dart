import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:nethive_neo/providers/user_provider.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/models/nethive/negocio_model.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class HomeTecnicoPage extends StatefulWidget {
  final String? negocioId;

  const HomeTecnicoPage({
    super.key,
    this.negocioId,
  });

  @override
  State<HomeTecnicoPage> createState() => _HomeTecnicoPageState();
}

class _HomeTecnicoPageState extends State<HomeTecnicoPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Negocio? _negocioActual;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadNegocio();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNegocio() async {
    if (widget.negocioId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final provider =
        Provider.of<EmpresasNegociosProvider>(context, listen: false);

    try {
      // Buscar en la lista actual de negocios
      final negocio = provider.negocios.firstWhere(
        (n) => n.id == widget.negocioId,
        orElse: () => throw Exception('Negocio no encontrado'),
      );

      // Configurar el ComponentesProvider con el negocio seleccionado
      final componentesProvider =
          Provider.of<ComponentesProvider>(context, listen: false);
      componentesProvider.setNegocioSeleccionado(negocio.id, negocio.nombre);

      print(
          'HomeTecnicoPage: Negocio configurado - ID: ${negocio.id}, Nombre: ${negocio.nombre}');

      setState(() {
        _negocioActual = negocio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar información del negocio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final userState = Provider.of<UserState>(context);

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
          child: _isLoading
              ? _buildLoadingState(theme)
              : Column(
                  children: [
                    // Header con información del técnico y negocio
                    _buildHeader(theme, userState),

                    // Dashboard de opciones
                    Expanded(
                      child: _buildDashboard(theme),
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
            'Cargando información...',
            style: theme.bodyText1.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppTheme theme, UserState userState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Barra superior con información del usuario
          Row(
            children: [
              // Avatar del usuario
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildDefaultAvatar(),
              ),

              const SizedBox(width: 12),

              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${_getUserName()}!',
                      style: theme.subtitle1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Técnico NetHive',
                      style: theme.bodyText2.copyWith(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón de configuración/logout
              IconButton(
                onPressed: () => _showOptionsMenu(context, userState),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 800.ms)
              .slideX(begin: -0.3, end: 0),

          const SizedBox(height: 16),

          // Información del negocio actual
          if (_negocioActual != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: theme.secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubicación actual',
                              style: theme.bodyText3.copyWith(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _negocioActual!.nombre,
                              style: theme.subtitle2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/empresa-selector'),
                        child: Text(
                          'Cambiar',
                          style: theme.bodyText2.copyWith(
                            color: theme.tertiaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _negocioActual!.direccion,
                          style: theme.bodyText3.copyWith(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      color: Colors.white,
      size: 30,
    );
  }

  String _getUserName() {
    final currentUser = supabaseLU.auth.currentUser;
    if (currentUser?.userMetadata?['full_name'] != null) {
      return currentUser!.userMetadata!['full_name'];
    }
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@')[0];
    }
    return 'Usuario';
  }

  Widget _buildDashboard(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panel de Trabajo',
            style: theme.title2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18, // Reducido de 20 a 18
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms),

          const SizedBox(height: 16),

          // Grid de opciones principales
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildDashboardCard(
                  theme: theme,
                  icon: Icons.qr_code_scanner,
                  title: 'Escanear RFID',
                  subtitle: 'Escanear etiquetas',
                  onTap: () => context.push('/scanner'),
                  gradient: [
                    const Color(0xFF6366F1), // Indigo vibrante
                    const Color(0xFF8B5CF6), // Violet
                  ],
                  delay: 1000,
                ),
                _buildDashboardCard(
                  theme: theme,
                  icon: Icons.inventory_2,
                  title: 'Inventario',
                  subtitle: 'Gestionar componentes',
                  onTap: () => context.push('/inventario'),
                  gradient: [
                    const Color(0xFF10B981), // Emerald
                    const Color(0xFF059669), // Emerald dark
                  ],
                  delay: 1100,
                ),
                _buildDashboardCard(
                  theme: theme,
                  icon: Icons.cable,
                  title: 'Conexiones',
                  subtitle: 'Gestionar conectividad',
                  onTap: () => context.push('/conexiones'),
                  gradient: [
                    const Color(0xFFF59E0B), // Amber
                    const Color(0xFFEF4444), // Red
                  ],
                  delay: 1200,
                ),
                _buildDashboardCard(
                  theme: theme,
                  icon: Icons.account_tree,
                  title: 'Distribuciones',
                  subtitle: 'MDF, IDF y ubicaciones técnicas',
                  onTap: () {
                    final negocioParam = _negocioActual?.id != null
                        ? '?negocioId=${_negocioActual!.id}'
                        : '';
                    context.push('/distribuciones$negocioParam');
                  },
                  gradient: [
                    const Color(0xFF7C3AED), // Purple
                    const Color(0xFF3B82F6), // Blue
                  ],
                  delay: 1250,
                ),
                _buildDashboardCard(
                  theme: theme,
                  icon: Icons.assignment,
                  title: 'Mis Trabajos',
                  subtitle: 'Asignaciones pendientes',
                  onTap: () {
                    // TODO: Implementar lista de trabajos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente: Lista de trabajos'),
                      ),
                    );
                  },
                  gradient: [
                    const Color(0xFF06B6D4), // Cyan
                    const Color(0xFF3B82F6), // Blue
                  ],
                  delay: 1300,
                ),
              ],
            ),
          ),

          // Estadísticas rápidas
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.check_circle,
                  value: '12',
                  label: 'Completados',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.pending,
                  value: '5',
                  label: 'Pendientes',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.schedule,
                  value: '2',
                  label: 'En progreso',
                  color: Colors.blue,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 1400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required AppTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> gradient,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.subtitle2.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.bodyText3.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .shimmer(delay: Duration(milliseconds: delay + 500), duration: 1000.ms);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, UserState userState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar página de perfil
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar configuración
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await supabaseLU.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
