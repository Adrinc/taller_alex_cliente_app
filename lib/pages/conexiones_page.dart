import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nethive/connections_provider.dart';
import '../models/nethive/vista_conexiones_con_cables_model.dart';
import '../theme/theme.dart';

class ConexionesPage extends StatefulWidget {
  final String negocioId;

  const ConexionesPage({
    Key? key,
    required this.negocioId,
  }) : super(key: key);

  @override
  State<ConexionesPage> createState() => _ConexionesPageState();
}

class _ConexionesPageState extends State<ConexionesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();

    // Cargar conexiones al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConnectionsProvider>().cargarConexiones(widget.negocioId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'Conexiones',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.table_chart), text: 'Lista'),
            Tab(icon: Icon(Icons.account_tree), text: 'Diagrama'),
          ],
        ),
      ),
      body: Consumer<ConnectionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF10B981),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar conexiones',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.limpiarError();
                      provider.cargarConexiones(widget.negocioId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildHeaderWithStats(provider),
              _buildSearchAndFilters(provider, theme),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListView(provider),
                    _buildDiagramView(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateConnectionDialog(),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderWithStats(ConnectionsProvider provider) {
    final stats = provider.estadisticasDetalladas;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              stats['total'].toString(),
              Icons.cable,
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completadas',
              stats['completadas'].toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pendientes',
              stats['pendientes'].toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '% Progreso',
              '${stats['porcentajeCompletado']}%',
              Icons.trending_up,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ConnectionsProvider provider, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            onChanged: provider.actualizarBusqueda,
            decoration: InputDecoration(
              hintText: 'Buscar por componente, RFID o descripción...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        provider.actualizarBusqueda('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filtros
          Row(
            children: [
              const Text('Filtrar: ',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: FiltroConexiones.values.map((filtro) {
                      final isSelected = provider.filtroActual == filtro;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getFiltroLabel(filtro)),
                          selected: isSelected,
                          onSelected: (_) => provider.cambiarFiltro(filtro),
                          backgroundColor: Colors.grey[100],
                          selectedColor: theme.primaryColor.withOpacity(0.2),
                          checkmarkColor: theme.primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFiltroLabel(FiltroConexiones filtro) {
    switch (filtro) {
      case FiltroConexiones.todas:
        return 'Todas';
      case FiltroConexiones.completadas:
        return 'Completadas';
      case FiltroConexiones.pendientes:
        return 'Pendientes';
      case FiltroConexiones.inactivas:
        return 'Inactivas';
    }
  }

  Widget _buildListView(ConnectionsProvider provider) {
    final conexiones = provider.conexiones;

    if (conexiones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cable,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay conexiones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para crear una nueva conexión',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conexiones.length,
      itemBuilder: (context, index) {
        final conexion = conexiones[index];
        return _buildConnectionCard(conexion);
      },
    );
  }

  Widget _buildConnectionCard(VistaConexionesConCables conexion) {
    final isCompleted = conexion.rfidCable != null;
    final statusColor = !conexion.activo
        ? Colors.grey
        : isCompleted
            ? Colors.green
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showConnectionDetails(conexion),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          !conexion.activo
                              ? Icons.cancel
                              : isCompleted
                                  ? Icons.check_circle
                                  : Icons.pending,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          !conexion.activo
                              ? 'Inactiva'
                              : isCompleted
                                  ? 'Completada'
                                  : 'Pendiente',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showConnectionMenu(conexion),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Conexión visual
              Row(
                children: [
                  // Componente origen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conexion.componenteOrigen,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (conexion.rfidOrigen != null)
                          Text(
                            'RFID: ${conexion.rfidOrigen}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Flecha y cable
                  Column(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: statusColor,
                        size: 20,
                      ),
                      if (conexion.cableUsado != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            conexion.cableUsado!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Componente destino
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          conexion.componenteDestino,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.end,
                        ),
                        if (conexion.rfidDestino != null)
                          Text(
                            'RFID: ${conexion.rfidDestino}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              // Descripción si existe
              if (conexion.descripcion != null &&
                  conexion.descripcion!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    conexion.descripcion!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagramView(ConnectionsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Vista de Diagrama',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente: Visualización gráfica de conexiones',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Conexión'),
        content: const Text(
          'Funcionalidad en desarrollo.\n\n'
          'Próximamente podrás crear conexiones desde esta pantalla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showConnectionDetails(VistaConexionesConCables conexion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalles de Conexión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Origen', conexion.componenteOrigen),
            _buildDetailRow('Destino', conexion.componenteDestino),
            if (conexion.cableUsado != null)
              _buildDetailRow('Cable', conexion.cableUsado!),
            if (conexion.rfidOrigen != null)
              _buildDetailRow('RFID Origen', conexion.rfidOrigen!),
            if (conexion.rfidDestino != null)
              _buildDetailRow('RFID Destino', conexion.rfidDestino!),
            if (conexion.rfidCable != null)
              _buildDetailRow('RFID Cable', conexion.rfidCable!),
            if (conexion.descripcion != null)
              _buildDetailRow('Descripción', conexion.descripcion!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showConnectionMenu(VistaConexionesConCables conexion) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Ver detalles'),
              onTap: () {
                Navigator.pop(context);
                _showConnectionDetails(conexion);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar edición
              },
            ),
            if (conexion.activo)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Desactivar',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implementar desactivación
                },
              ),
          ],
        ),
      ),
    );
  }
}
