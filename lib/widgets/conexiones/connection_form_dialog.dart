import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/nethive/componente_model.dart';
import '../../models/nethive/vista_conexiones_con_cables_model.dart';
import '../../providers/nethive/connections_provider.dart';
import '../../providers/nethive/componentes_provider.dart';
import '../../theme/theme.dart';

class ConnectionFormDialog extends StatefulWidget {
  final String negocioId;
  final VistaConexionesConCables? conexionExistente;
  final bool isEdit;

  const ConnectionFormDialog({
    Key? key,
    required this.negocioId,
    this.conexionExistente,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<ConnectionFormDialog> createState() => _ConnectionFormDialogState();
}

class _ConnectionFormDialogState extends State<ConnectionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  Componente? _componenteOrigen;
  Componente? _componenteDestino;
  Componente? _cable;
  TipoConexion _tipoConexion = TipoConexion.componente;

  bool _isLoading = false;
  String? _error;

  List<Componente> _componentes = [];
  List<Componente> _cables = [];

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.isEdit && widget.conexionExistente != null) {
      _descripcionController.text = widget.conexionExistente!.descripcion ?? '';
    }
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final componentesProvider = context.read<ComponentesProvider>();

      // Cargar componentes del negocio
      await componentesProvider.getComponentes(negocioId: widget.negocioId);

      _componentes =
          componentesProvider.componentes.where((c) => c.activo).toList();

      // Cargar cables disponibles (componentes de categoría cable)
      _cables = componentesProvider.componentes
          .where((c) => c.activo && _esCable(c))
          .toList();
    } catch (e) {
      setState(() => _error = 'Error cargando datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _esCable(Componente componente) {
    // Aquí deberías usar la lógica real para identificar cables
    // Por ejemplo, si tienes categorías específicas para cables
    final nombreLower = componente.nombre.toLowerCase();
    return nombreLower.contains('cable') ||
        nombreLower.contains('patch') ||
        componente.categoriaId == 6; // Ajusta según tu esquema
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  widget.isEdit ? Icons.edit : Icons.add_link,
                  color: theme.primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isEdit ? 'Editar Conexión' : 'Nueva Conexión',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildForm(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppTheme theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de conexión
          Text(
            'Tipo de Conexión',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<TipoConexion>(
                  title: const Text('Datos/Red'),
                  value: TipoConexion.componente,
                  groupValue: _tipoConexion,
                  onChanged: (value) {
                    setState(() => _tipoConexion = value!);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<TipoConexion>(
                  title: const Text('Energía'),
                  value: TipoConexion.alimentacion,
                  groupValue: _tipoConexion,
                  onChanged: (value) {
                    setState(() => _tipoConexion = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Componente origen
          _buildComponenteSelector(
            label: 'Componente Origen',
            componente: _componenteOrigen,
            onChanged: (value) => setState(() => _componenteOrigen = value),
            excludeComponent: _componenteDestino,
          ),
          const SizedBox(height: 16),

          // Componente destino
          _buildComponenteSelector(
            label: 'Componente Destino',
            componente: _componenteDestino,
            onChanged: (value) => setState(() => _componenteDestino = value),
            excludeComponent: _componenteOrigen,
          ),
          const SizedBox(height: 16),

          // Cable (opcional)
          _buildCableSelector(),
          const SizedBox(height: 16),

          // Descripción
          TextFormField(
            controller: _descripcionController,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // Botones
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _canSubmit() ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(widget.isEdit ? 'Actualizar' : 'Crear Conexión'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponenteSelector({
    required String label,
    required Componente? componente,
    required ValueChanged<Componente?> onChanged,
    Componente? excludeComponent,
  }) {
    final availableComponents =
        _componentes.where((c) => c.id != excludeComponent?.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Componente>(
          value: componente,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.device_hub),
          ),
          hint: Text('Seleccionar $label'),
          validator: (value) => value == null ? 'Campo requerido' : null,
          items: availableComponents.map((c) {
            return DropdownMenuItem<Componente>(
              value: c,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (c.ubicacion != null)
                    Text(
                      c.ubicacion!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCableSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cable (opcional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Componente>(
          value: _cable,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.cable),
          ),
          hint: const Text('Seleccionar cable'),
          items: _cables.map((c) {
            return DropdownMenuItem<Componente>(
              value: c,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (c.rfid != null)
                    Text(
                      'RFID: ${c.rfid}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _cable = value),
        ),
      ],
    );
  }

  bool _canSubmit() {
    return _componenteOrigen != null &&
        _componenteDestino != null &&
        _componenteOrigen!.id != _componenteDestino!.id;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_canSubmit()) return;

    setState(() => _isLoading = true);

    try {
      final connectionsProvider = context.read<ConnectionsProvider>();
      bool success = false;

      if (_tipoConexion == TipoConexion.componente) {
        success = await connectionsProvider.crearConexionComponente(
          origenId: _componenteOrigen!.id,
          destinoId: _componenteDestino!.id,
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
        );
      } else {
        success = await connectionsProvider.crearConexionAlimentacion(
          origenId: _componenteOrigen!.id,
          destinoId: _componenteDestino!.id,
          cableId: _cable?.id,
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          tecnicoId: null, // Se puede obtener del usuario actual
        );
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.isEdit
                  ? 'Conexión actualizada exitosamente'
                  : 'Conexión creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(
            () => _error = connectionsProvider.error ?? 'Error desconocido');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
