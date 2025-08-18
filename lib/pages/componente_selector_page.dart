import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/providers/nethive/componentes_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/widgets/selector_page/componente_card.dart';
import 'package:nethive_neo/widgets/selector_page/empty_components_widget.dart';
import 'package:nethive_neo/widgets/selector_page/components_loading_widget.dart';
import 'package:nethive_neo/widgets/selector_page/components_error_widget.dart';

class ComponenteSelectorPage extends StatefulWidget {
  final String? rfidCode;
  final String? negocioId;

  const ComponenteSelectorPage({
    super.key,
    this.rfidCode,
    this.negocioId,
  });

  @override
  State<ComponenteSelectorPage> createState() => _ComponenteSelectorPageState();
}

class _ComponenteSelectorPageState extends State<ComponenteSelectorPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ComponentesProvider>(context, listen: false);

      // Si no hay negocio seleccionado en el provider, intentar usar el query parameter
      if (provider.negocioSeleccionadoId == null && widget.negocioId != null) {
        print(
            'ComponenteSelectorPage: Configurando negocio desde query parameter: ${widget.negocioId}');

        // Configurar el negocio en el provider usando el query parameter
        // Nota: Aquí configuramos solo el ID, el nombre se podría obtener después si es necesario
        provider.setNegocioSeleccionado(
            widget.negocioId, 'Negocio Seleccionado');
      }

      // Verificar que hay un negocio seleccionado
      if (provider.negocioSeleccionadoId == null) {
        _showErrorDialog(
            'No hay un negocio seleccionado. Por favor, regresa y selecciona un negocio primero.');
        return;
      }

      _loadComponentes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadComponentes() {
    final provider = Provider.of<ComponentesProvider>(context, listen: false);

    // Log para debugging
    print(
        'ComponenteSelectorPage: Cargando componentes para negocio: ${provider.negocioSeleccionadoId}');
    print(
        'ComponenteSelectorPage: Nombre del negocio: ${provider.negocioSeleccionadoNombre}');

    // Usar el negocioSeleccionadoId del provider para filtrar componentes
    provider.getComponentesSinRfid(negocioId: provider.negocioSeleccionadoId);
  }

  void _onSearchChanged(String query) {
    final provider = Provider.of<ComponentesProvider>(context, listen: false);
    if (query.trim().isEmpty) {
      provider.clearComponentesSinRfid();
      // Usar el negocioSeleccionadoId del provider para filtrar componentes
      provider.getComponentesSinRfid(negocioId: provider.negocioSeleccionadoId);
    } else {
      provider.buscarComponentesSinRfid(query);
    }
  }

  void _showAssignmentDialog(Componente componente) {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text(
          'Confirmar Asignación',
          style: TextStyle(color: theme.primaryText),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RFID: ${widget.rfidCode ?? 'Sin código'}',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Componente: ${componente.nombre}',
              style: TextStyle(color: theme.primaryText),
            ),
            Text(
              'Ubicación: ${componente.ubicacion ?? 'Sin ubicación'}',
              style: TextStyle(color: theme.secondaryText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: theme.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _asignarRfid(componente);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.primaryBackground,
            ),
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _asignarRfid(Componente componente) async {
    if (widget.rfidCode == null) {
      _showErrorDialog('No hay código RFID disponible');
      return;
    }

    final provider = Provider.of<ComponentesProvider>(context, listen: false);

    final success = await provider.asignarRfidAComponente(
      componente.id,
      widget.rfidCode!,
    );

    if (mounted) {
      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Error al asignar RFID al componente');
      }
    }
  }

  void _showSuccessDialog() {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: theme.success),
            const SizedBox(width: 8),
            Text(
              'Éxito',
              style: TextStyle(color: theme.primaryText),
            ),
          ],
        ),
        content: Text(
          'RFID asignado correctamente al componente',
          style: TextStyle(color: theme.primaryText),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop(); // Regresar a la página anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: theme.primaryBackground,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Row(
          children: [
            Icon(Icons.error, color: theme.error),
            const SizedBox(width: 8),
            Text(
              'Error',
              style: TextStyle(color: theme.primaryText),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: theme.primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.primaryText,
          ),
          onPressed: () => context.pop(),
        ),
        title: Consumer<ComponentesProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccionar Componente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.primaryText,
                      ),
                ),
                if (widget.rfidCode != null)
                  Text(
                    'RFID: ${widget.rfidCode}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
                        ),
                  ),
                if (provider.negocioSeleccionadoNombre != null)
                  Text(
                    'Negocio: ${provider.negocioSeleccionadoNombre}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: theme.secondaryText,
                        ),
                  ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.primaryText,
            ),
            onPressed: _loadComponentes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.secondaryText.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.primaryText),
              decoration: InputDecoration(
                hintText: 'Buscar componente...',
                hintStyle: TextStyle(color: theme.secondaryText),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.secondaryText,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.secondaryText,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Lista de componentes
          Expanded(
            child: Consumer<ComponentesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingComponentesSinRfid) {
                  return const ComponentsLoadingWidget();
                }

                if (provider.errorComponentesSinRfid != null) {
                  return ComponentsErrorWidget(
                    errorMessage: provider.errorComponentesSinRfid!,
                    onRetry: _loadComponentes,
                  );
                }

                if (provider.componentesSinRfid.isEmpty) {
                  return const EmptyComponentsWidget();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.componentesSinRfid.length,
                  itemBuilder: (context, index) {
                    final componente = provider.componentesSinRfid[index];
                    return ComponenteCard(
                      componente: componente,
                      onTap: () => _showAssignmentDialog(componente),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
