import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/theme/theme.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String _selectedFilter = 'todos';

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
          child: Consumer<ComponentesProvider>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final componentesProvider = context.read<ComponentesProvider>();
          final negocioId = componentesProvider.negocioSeleccionadoId;
          final negocioParam = negocioId != null ? '?negocioId=$negocioId' : '';
          context.go('/componente/crear$negocioParam');
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
              Expanded(
                child: Text(
                  'Inventario',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryText,
                  ),
                ),
              ),
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
                  onPressed: () => context.go('/scanner'),
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
              _buildFilterChip('Racks', 'racks', theme),
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
              'No se encontraron componentes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta cambiar los filtros o agregar componentes',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.secondaryBackground,
      elevation: 2,
      child: InkWell(
        onTap: () => context.go('/componente/${componente.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getComponentIcon(componente.categoriaId.toString()),
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          componente.descripcion ?? componente.nombre,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Categoría: ${componente.categoriaId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (componente.rfid?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 12,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'RFID',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (componente.rfid?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.tertiaryBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'RFID: ${componente.rfid}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.secondaryText,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusChip(
                    componente.enUso ? 'En Uso' : 'Disponible',
                    componente.enUso ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  if (componente.ubicacion?.isNotEmpty == true)
                    Expanded(
                      child: Text(
                        'Ubicación: ${componente.ubicacion}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
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

  IconData _getComponentIcon(String? categoria) {
    switch (categoria?.toLowerCase()) {
      case '1': // switch
      case 'switch':
      case 'switches':
        return Icons.hub;
      case '2': // cable
      case 'cable':
      case 'cables':
        return Icons.cable;
      case '3': // rack
      case 'rack':
      case 'racks':
        return Icons.developer_board;
      case '4': // servidor
      case 'servidor':
      case 'servidores':
        return Icons.dns;
      case '5': // router
      case 'router':
      case 'routers':
        return Icons.router;
      default:
        return Icons.memory;
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
        filtered = filtered.where((c) => c.categoriaId == 2).toList();
        break;
      case 'switches':
        filtered = filtered.where((c) => c.categoriaId == 1).toList();
        break;
      case 'racks':
        filtered = filtered.where((c) => c.categoriaId == 3).toList();
        break;
      case 'todos':
      default:
        break;
    }

    return filtered;
  }
}
