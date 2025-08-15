import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/widgets/common/custom_app_bar.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';

class InventarioPage extends StatefulWidget {
  const InventarioPage({super.key});

  @override
  State<InventarioPage> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventarioPage>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _selectedFilter = 'todos';
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inventario',
        actions: [
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.go('/scanner'),
          ),
        ],
      ),
      body: Consumer<ComponentesProvider>(
        builder: (context, componentes, child) {
          return Column(
            children: [
              // Barra de búsqueda
              _buildSearchBar(),

              // Panel de filtros
              if (_showFilters)
                _buildFiltersPanel()
                    .animate()
                    .slideY(
                        begin: -1, duration: const Duration(milliseconds: 300))
                    .fadeIn(),

              // Estadísticas rápidas
              _buildStatsPanel(componentes),

              // Lista de componentes
              Expanded(
                child: _buildComponentsList(componentes),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/componente/crear'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar componentes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onChanged: (value) {
          setState(() {});
          // TODO: Implementar búsqueda en tiempo real
        },
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Todos', 'todos'),
              _buildFilterChip('Con RFID', 'con_rfid'),
              _buildFilterChip('Sin RFID', 'sin_rfid'),
              _buildFilterChip('En Uso', 'en_uso'),
              _buildFilterChip('Disponible', 'disponible'),
              _buildFilterChip('Cables', 'cables'),
              _buildFilterChip('Switches', 'switches'),
              _buildFilterChip('Racks', 'racks'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.blue.shade700,
          fontSize: 12,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'todos';
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildStatsPanel(ComponentesProvider componentes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
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
            ),
          ),
          Container(
            height: 40,
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
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'En Uso',
              componentes.componentes.where((c) => c.enUso).length.toString(),
              Icons.play_circle_filled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
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
      padding: const EdgeInsets.all(16),
      itemCount: filteredComponents.length,
      itemBuilder: (context, index) {
        final component = filteredComponents[index];
        return _buildComponentCard(component, index);
      },
    );
  }

  Widget _buildComponentCard(Componente componente, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/componente/${componente.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con nombre y estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(componente.categoriaId)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(componente.categoriaId),
                      color: _getCategoryColor(componente.categoriaId),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          componente.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (componente.descripcion?.isNotEmpty == true)
                          Text(
                            componente.descripcion!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Estados
                  Column(
                    children: [
                      if (componente.rfid?.isNotEmpty == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'RFID',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: componente.enUso ? Colors.orange : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          componente.enUso ? 'EN USO' : 'LIBRE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Información adicional
              Row(
                children: [
                  if (componente.ubicacion?.isNotEmpty == true) ...[
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        componente.ubicacion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (componente.rfid?.isNotEmpty == true) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.qr_code,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      componente.rfid!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .slideX(begin: -0.1, duration: const Duration(milliseconds: 300))
        .fadeIn();
  }

  List<Componente> _getFilteredComponents(List<Componente> components) {
    var filtered = components.where((component) {
      // Filtro de búsqueda
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!component.nombre.toLowerCase().contains(query) &&
            !(component.descripcion?.toLowerCase().contains(query) ?? false) &&
            !(component.rfid?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filtros por categoría/estado
      switch (_selectedFilter) {
        case 'con_rfid':
          return component.rfid?.isNotEmpty == true;
        case 'sin_rfid':
          return component.rfid?.isEmpty ?? true;
        case 'en_uso':
          return component.enUso;
        case 'disponible':
          return !component.enUso;
        case 'cables':
          return component.categoriaId == 1; // Asumiendo que 1 es cables
        case 'switches':
          return component.categoriaId == 2; // Asumiendo que 2 es switches
        case 'racks':
          return component.categoriaId == 3; // Asumiendo que 3 es racks
        default:
          return true;
      }
    }).toList();

    // Ordenar por nombre
    filtered.sort((a, b) => a.nombre.compareTo(b.nombre));

    return filtered;
  }

  IconData _getCategoryIcon(int categoriaId) {
    switch (categoriaId) {
      case 1:
        return Icons.cable;
      case 2:
        return Icons.hub;
      case 3:
        return Icons.inventory_2;
      case 4:
        return Icons.grid_view;
      case 5:
        return Icons.power;
      case 6:
        return Icons.router;
      default:
        return Icons.memory;
    }
  }

  Color _getCategoryColor(int categoriaId) {
    switch (categoriaId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;
      case 5:
        return Colors.red;
      case 6:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
