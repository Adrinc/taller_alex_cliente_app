import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/widgets/inventario_page/componente_detail_popup.dart';

class InventarioPage extends StatefulWidget {
  final String? negocioId;

  const InventarioPage({super.key, this.negocioId});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String _selectedFilter = 'todos';
  String? _negocioId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComponentes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadComponentes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Usar el negocioId del constructor directamente
      _negocioId = widget.negocioId;

      if (_negocioId == null) {
        // Si no se proporciona negocioId, intentar obtenerlo desde URL como fallback
        final uri = Uri.base;
        _negocioId = uri.queryParameters['negocioId'];
      }

      if (_negocioId == null) {
        throw Exception('No se proporcionó un ID de negocio válido');
      }

      final componentesProvider = context.read<ComponentesProvider>();

      print('InventarioPage: Cargando componentes para negocio: $_negocioId');

      // Cargar componentes filtrados por técnico y negocio específico
      await componentesProvider.getComponentesByTecnicoAndNegocio(
          currentUser!.id, _negocioId!);

      print(
          'Inventario cargado: ${componentesProvider.componentes.length} componentes encontrados para negocio $_negocioId');
    } catch (e) {
      print('Error cargando componentes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el inventario: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              onPressed: _loadComponentes,
              textColor: Colors.white,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
          child: _isLoading
              ? _buildLoadingState(theme)
              : Consumer<ComponentesProvider>(
                  builder: (context, componentes, child) {
                    return Column(
                      children: [
                        // Header personalizado
                        _buildHeader(theme),

                        // Panel de filtros
                        if (_showFilters)
                          _buildFiltersPanel(theme)
                              .animate()
                              .slideY(
                                  begin: -1,
                                  duration: const Duration(milliseconds: 300))
                              .fadeIn(),

                        // Estadísticas rápidas
                        _buildStatsPanel(componentes, theme),

                        // Lista de componentes
                        Expanded(
                          child: _buildComponentsList(componentes),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: () {
                final negocioParam =
                    _negocioId != null ? '?negocioId=$_negocioId' : '';
                context.go('/componente/crear$negocioParam');
              },
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando inventario...',
            style: TextStyle(
              color: theme.primaryText,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Obteniendo componentes del negocio',
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Botón de regreso al home del técnico
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () {
                    if (_negocioId != null) {
                      context.go('/home?negocioId=$_negocioId');
                    } else {
                      context.go('/home');
                    }
                  },
                  tooltip: 'Volver al home',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inventario',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                      ),
                    ),
                    if (_negocioId != null)
                      Text(
                        'Mis componentes registrados',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: theme.primaryColor),
                  onPressed: _isLoading ? null : _loadComponentes,
                  tooltip: 'Actualizar inventario',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _showFilters ? Icons.filter_list_off : Icons.filter_list,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.qr_code_scanner, color: theme.primaryColor),
                  onPressed: () {
                    final negocioParam =
                        _negocioId != null ? '?negocioId=$_negocioId' : '';
                    context.go('/scanner$negocioParam');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar componentes...',
          hintStyle: TextStyle(color: theme.secondaryText, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: theme.secondaryText, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.secondaryText, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
        ),
        style: TextStyle(color: theme.primaryText, fontSize: 14),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFiltersPanel(AppTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Todos', 'todos', theme),
              _buildFilterChip('Con RFID', 'con_rfid', theme),
              _buildFilterChip('Sin RFID', 'sin_rfid', theme),
              _buildFilterChip('En Uso', 'en_uso', theme),
              _buildFilterChip('Disponible', 'disponible', theme),
              _buildFilterChip('Cables', 'cables', theme),
              _buildFilterChip('Switches', 'switches', theme),
              _buildFilterChip('Patch Panels', 'patch_panels', theme),
              _buildFilterChip('Racks', 'racks', theme),
              _buildFilterChip('UPS', 'ups', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, AppTheme theme) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? 'todos' : value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.primaryColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsPanel(ComponentesProvider componentes, AppTheme theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              componentes.componentes.length.toString(),
              Icons.inventory,
              theme,
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Con RFID',
              componentes.componentes
                  .where((c) => c.rfid?.isNotEmpty == true)
                  .length
                  .toString(),
              Icons.qr_code,
              theme,
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'En Uso',
              componentes.componentes.where((c) => c.enUso).length.toString(),
              Icons.play_circle_filled,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, AppTheme theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildComponentsList(ComponentesProvider componentes) {
    final filteredComponents = _getFilteredComponents(componentes.componentes);

    if (filteredComponents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No se encontraron componentes que coincidan'
                  : 'No tienes componentes registrados',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Intenta cambiar el término de búsqueda'
                  : 'Escanea un código RFID para agregar tu primer componente',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            if (_searchController.text.isEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final negocioParam =
                      _negocioId != null ? '?negocioId=$_negocioId' : '';
                  context.go('/scanner$negocioParam');
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear RFID'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredComponents.length,
      itemBuilder: (context, index) {
        final componente = filteredComponents[index];
        return _buildComponentCard(componente);
      },
    );
  }

  Widget _buildComponentCard(Componente componente) {
    final theme = AppTheme.of(context);
    final categoryColor = _getCategoryColor(componente.categoriaId);
    final categoryIcon = _getCategoryIcon(componente.categoriaId);
    final categoryName = _getCategoryName(componente.categoriaId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.secondaryBackground,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => ComponenteDetailPopup(componente: componente),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Imagen del componente
                Container(
                  width: 100,
                  constraints: const BoxConstraints(
                    minHeight: 120,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    color: categoryColor.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: componente.imagenUrl?.isNotEmpty == true
                        ? Image.network(
                            "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/componentes/${componente.imagenUrl!}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder(
                                  categoryIcon, categoryColor);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildImagePlaceholder(
                                  categoryIcon, categoryColor);
                            },
                          )
                        : _buildImagePlaceholder(categoryIcon, categoryColor),
                  ),
                ),

                // Contenido principal
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header con icono y categoría
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                categoryIcon,
                                color: categoryColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: categoryColor,
                                ),
                              ),
                            ),
                            if (componente.rfid?.isNotEmpty == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.qr_code,
                                      size: 10,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'RFID',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Nombre del componente
                        Text(
                          componente.nombre,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Descripción si existe
                        if (componente.descripcion?.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            componente.descripcion!,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.secondaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 6),

                        // Status y ubicación
                        Row(
                          children: [
                            _buildStatusChip(
                              componente.enUso ? 'En Uso' : 'Disponible',
                              componente.enUso ? Colors.orange : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            if (componente.ubicacion?.isNotEmpty == true)
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 12,
                                      color: theme.secondaryText,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        componente.ubicacion!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: theme.secondaryText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // RFID info si existe
                        if (componente.rfid?.isNotEmpty == true) ...[
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.tertiaryBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RFID: ${componente.rfid}',
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.secondaryText,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon, Color color) {
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
      child: Icon(
        icon,
        color: color.withOpacity(0.6),
        size: 40,
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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

  List<Componente> _getFilteredComponents(List<Componente> componentes) {
    List<Componente> filtered = componentes;

    // Filtrar por búsqueda
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((componente) {
        return (componente.descripcion?.toLowerCase().contains(query) ==
                true) ||
            (componente.nombre.toLowerCase().contains(query)) ||
            (componente.rfid?.toLowerCase().contains(query) == true) ||
            (componente.ubicacion?.toLowerCase().contains(query) == true);
      }).toList();
    }

    // Filtrar por categoría/estado
    switch (_selectedFilter) {
      case 'con_rfid':
        filtered = filtered.where((c) => c.rfid?.isNotEmpty == true).toList();
        break;
      case 'sin_rfid':
        filtered = filtered.where((c) => c.rfid?.isEmpty != false).toList();
        break;
      case 'en_uso':
        filtered = filtered.where((c) => c.enUso).toList();
        break;
      case 'disponible':
        filtered = filtered.where((c) => !c.enUso).toList();
        break;
      case 'cables':
        filtered = filtered.where((c) => c.categoriaId == 1).toList(); // Cable
        break;
      case 'switches':
        filtered = filtered.where((c) => c.categoriaId == 2).toList(); // Switch
        break;
      case 'racks':
        filtered = filtered.where((c) => c.categoriaId == 4).toList(); // Rack
        break;
      case 'patch_panels':
        filtered =
            filtered.where((c) => c.categoriaId == 3).toList(); // Patch Panel
        break;
      case 'ups':
        filtered = filtered.where((c) => c.categoriaId == 5).toList(); // UPS
        break;
      case 'todos':
      default:
        break;
    }

    return filtered;
  }
}
