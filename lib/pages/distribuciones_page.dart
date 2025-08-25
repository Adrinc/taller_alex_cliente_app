import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:nethive_neo/providers/nethive/distribuciones_provider.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/models/nethive/distribucion_model.dart';
import 'package:nethive_neo/theme/theme.dart';

class DistribucionesPage extends StatefulWidget {
  final String? negocioId;

  const DistribucionesPage({
    super.key,
    this.negocioId,
  });

  @override
  State<DistribucionesPage> createState() => _DistribucionesPageState();
}

class _DistribucionesPageState extends State<DistribucionesPage> {
  String? _negocioId;
  String? _negocioNombre;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      // Obtener negocio ID
      if (widget.negocioId != null) {
        _negocioId = widget.negocioId;
      } else {
        // Intentar obtenerlo del URI o del storage local
        final uri = Uri.base;
        String? negocioIdFromUrl = uri.queryParameters['negocioId'];

        if (negocioIdFromUrl != null) {
          _negocioId = negocioIdFromUrl;
        } else {
          final empresasProvider = context.read<EmpresasNegociosProvider>();
          if (empresasProvider.negocios.isEmpty) {
            await empresasProvider.getNegocios();
          }
          if (empresasProvider.negocios.isNotEmpty) {
            _negocioId = empresasProvider.negocios.first.id;
            _negocioNombre = empresasProvider.negocios.first.nombre;
          }
        }
      }

      if (_negocioId != null) {
        // Obtener nombre del negocio si no lo tenemos
        if (_negocioNombre == null) {
          final empresasProvider = context.read<EmpresasNegociosProvider>();
          final negocio = empresasProvider.negocios.firstWhere(
            (n) => n.id == _negocioId,
            orElse: () => throw Exception('Negocio no encontrado'),
          );
          _negocioNombre = negocio.nombre;
        }

        // Cargar datos del provider
        final distribucionesProvider = context.read<DistribucionesProvider>();
        await Future.wait([
          distribucionesProvider.loadTiposDistribucion(),
          distribucionesProvider.loadDistribucionesByNegocio(_negocioId!),
        ]);
      }
    } catch (e) {
      print('Error inicializando distribuciones: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryBackground,
                theme.secondaryBackground,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_negocioId == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryBackground,
                theme.secondaryBackground,
              ],
            ),
          ),
          child: const Center(
            child: Text('Error: No se pudo identificar el negocio'),
          ),
        ),
      );
    }

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
          child: Consumer<DistribucionesProvider>(
            builder: (context, distribucionesProvider, child) {
              return Column(
                children: [
                  _buildHeader(theme),
                  _buildStatsPanel(distribucionesProvider, theme),
                  Expanded(
                    child:
                        _buildDistribucionesList(distribucionesProvider, theme),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDistribucionDialog(),
        backgroundColor: Colors.deepPurple,
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
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.primaryText,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distribuciones',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryText,
                      ),
                    ),
                    if (_negocioNombre != null)
                      Text(
                        _negocioNombre!,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.secondaryText,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.deepPurple),
                  onPressed: () => _initializeData(),
                  tooltip: 'Actualizar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(DistribucionesProvider provider, AppTheme theme) {
    final totalDistribuciones = provider.distribuciones.length;

    // Contar por tipo dinámicamente
    int tiposMDF = 0;
    int tiposIDF = 0;

    for (final distribucion in provider.distribuciones) {
      final tipoNombre = provider.getTipoNombre(distribucion.tipoId);
      if (tipoNombre == 'MDF') {
        tiposMDF++;
      } else if (tipoNombre == 'IDF') {
        tiposIDF++;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.indigo],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
                'Total', totalDistribuciones.toString(), Icons.account_tree),
          ),
          Container(height: 32, width: 1, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem('MDF', tiposMDF.toString(), Icons.home_work),
          ),
          Container(height: 32, width: 1, color: Colors.white.withOpacity(0.3)),
          Expanded(
            child: _buildStatItem('IDF', tiposIDF.toString(), Icons.business),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
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

  Widget _buildDistribucionesList(
      DistribucionesProvider provider, AppTheme theme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.distribuciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay distribuciones registradas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu primera distribución (MDF/IDF)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateDistribucionDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Crear Distribución'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.distribuciones.length,
      itemBuilder: (context, index) {
        final distribucion = provider.distribuciones[index];
        return _buildDistribucionCard(distribucion, provider, theme)
            .animate(delay: (index * 100).ms)
            .slideX(begin: 0.3, end: 0)
            .fadeIn();
      },
    );
  }

  Widget _buildDistribucionCard(Distribucion distribucion,
      DistribucionesProvider provider, AppTheme theme) {
    final tipoNombre =
        provider.getTipoNombre(distribucion.tipoId) ?? 'Desconocido';
    final isMDF = tipoNombre == 'MDF';
    final cardColor = isMDF ? Colors.deepPurple : Colors.indigo;
    final iconData = isMDF ? Icons.home_work : Icons.business;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor.withOpacity(0.3)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: cardColor, size: 24),
          ),
          title: Text(
            distribucion.nombre,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.primaryText,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tipoNombre,
                  style: TextStyle(
                    color: cardColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (distribucion.descripcion?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  distribucion.descripcion!,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _showEditDistribucionDialog(distribucion),
                icon: Icon(Icons.edit, color: theme.secondaryText),
                tooltip: 'Editar',
              ),
              IconButton(
                onPressed: () =>
                    _showDeleteDistribucionDialog(distribucion, provider),
                icon: Icon(Icons.delete, color: Colors.red.shade400),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateDistribucionDialog() {
    final provider = context.read<DistribucionesProvider>();
    _showDistribucionDialog(
      title: 'Crear Distribución',
      onSave: (tipoId, nombre, descripcion) async {
        final success = await provider.createDistribucion(
          negocioId: _negocioId!,
          tipoId: tipoId,
          nombre: nombre,
          descripcion: descripcion,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Distribución creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.error ?? 'Error al crear distribución'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        return success;
      },
    );
  }

  void _showEditDistribucionDialog(Distribucion distribucion) {
    final provider = context.read<DistribucionesProvider>();
    _showDistribucionDialog(
      title: 'Editar Distribución',
      initialTipoId: distribucion.tipoId,
      initialNombre: distribucion.nombre,
      initialDescripcion: distribucion.descripcion,
      onSave: (tipoId, nombre, descripcion) async {
        final success = await provider.updateDistribucion(
          id: distribucion.id,
          tipoId: tipoId,
          nombre: nombre,
          descripcion: descripcion,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Distribución actualizada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(provider.error ?? 'Error al actualizar distribución'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        return success;
      },
    );
  }

  void _showDeleteDistribucionDialog(
      Distribucion distribucion, DistribucionesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la distribución "${distribucion.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success =
                  await provider.deleteDistribucion(distribucion.id);

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Distribución eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          provider.error ?? 'Error al eliminar distribución'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDistribucionDialog({
    required String title,
    int? initialTipoId,
    String? initialNombre,
    String? initialDescripcion,
    required Future<bool> Function(
            int tipoId, String nombre, String? descripcion)
        onSave,
  }) {
    final provider = context.read<DistribucionesProvider>();
    final tiposDisponibles = provider.tiposDistribucion;

    // Si no hay tipos disponibles, crear fallback
    if (tiposDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No hay tipos de distribución disponibles'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int selectedTipoId = initialTipoId ?? tiposDisponibles.first.id;
    final nombreController = TextEditingController(text: initialNombre ?? '');
    final descripcionController =
        TextEditingController(text: initialDescripcion ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedTipoId,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Distribución',
                  border: OutlineInputBorder(),
                ),
                items: tiposDisponibles
                    .map((tipo) => DropdownMenuItem(
                          value: tipo.id,
                          child: Text(tipo.nombre),
                        ))
                    .toList(),
                onChanged: (value) => selectedTipoId = value!,
                validator: (value) =>
                    value == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'El nombre es obligatorio';
                  }

                  // Verificar si el nombre ya existe (solo para crear o si cambió el nombre)
                  if (provider.nombreExists(value!.trim(), _negocioId!,
                      excludeId: initialNombre != value.trim() ? null : null)) {
                    return 'Ya existe una distribución con este nombre';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await onSave(
                  selectedTipoId,
                  nombreController.text.trim(),
                  descripcionController.text.trim().isEmpty
                      ? null
                      : descripcionController.text.trim(),
                );
                if (success && mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
