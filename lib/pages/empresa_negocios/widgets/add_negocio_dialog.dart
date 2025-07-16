import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class AddNegocioDialog extends StatefulWidget {
  final EmpresasNegociosProvider provider;
  final String empresaId;

  const AddNegocioDialog({
    Key? key,
    required this.provider,
    required this.empresaId,
  }) : super(key: key);

  @override
  State<AddNegocioDialog> createState() => _AddNegocioDialogState();
}

class _AddNegocioDialogState extends State<AddNegocioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _tipoLocalController = TextEditingController(text: 'Sucursal');

  bool _isLoading = false;

  final List<String> _tiposLocal = [
    'Sucursal',
    'Oficina Central',
    'Bodega',
    'Centro de Distribución',
    'Punto de Venta',
    'Otro'
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _tipoLocalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.of(context).primaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.store,
            color: AppTheme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Añadir Nueva Sucursal',
            style: TextStyle(
              color: AppTheme.of(context).primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Información de la empresa
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        color: AppTheme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Empresa: ${widget.provider.empresaSeleccionada?.nombre ?? ""}',
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Nombre
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la sucursal *',
                    hintText: 'Ej: Sucursal Centro, Sede Norte',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dirección
                TextFormField(
                  controller: _direccionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Dirección *',
                    hintText: 'Dirección completa de la sucursal',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La dirección es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de local
                DropdownButtonFormField<String>(
                  value: _tipoLocalController.text,
                  decoration: InputDecoration(
                    labelText: 'Tipo de local *',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _tiposLocal.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _tipoLocalController.text = newValue;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona un tipo de local';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Coordenadas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.map,
                            color: AppTheme.of(context).primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Coordenadas Geográficas *',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.of(context).primaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Latitud
                          Expanded(
                            child: TextFormField(
                              controller: _latitudController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*\.?\d*'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Latitud',
                                hintText: 'Ej: 19.4326',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final lat = double.tryParse(value);
                                if (lat == null) {
                                  return 'Número inválido';
                                }
                                if (lat < -90 || lat > 90) {
                                  return 'Rango: -90 a 90';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Longitud
                          Expanded(
                            child: TextFormField(
                              controller: _longitudController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*\.?\d*'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Longitud',
                                hintText: 'Ej: -99.1332',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final lng = double.tryParse(value);
                                if (lng == null) {
                                  return 'Número inválido';
                                }
                                if (lng < -180 || lng > 180) {
                                  return 'Rango: -180 a 180';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tip: Puedes obtener las coordenadas desde Google Maps',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.of(context).secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de archivos
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Archivos (Opcional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.of(context).primaryText,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logo
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.provider.selectLogo,
                              icon: Icon(Icons.image),
                              label: Text(
                                widget.provider.logoFileName ??
                                    'Seleccionar Logo',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (widget.provider.logoToUpload != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: widget.provider.getImageWidget(
                                widget.provider.logoToUpload,
                                height: 40,
                                width: 40,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Imagen
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.provider.selectImagen,
                              icon: Icon(Icons.photo),
                              label: Text(
                                widget.provider.imagenFileName ??
                                    'Seleccionar Imagen',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (widget.provider.imagenToUpload != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: widget.provider.getImageWidget(
                                widget.provider.imagenToUpload,
                                height: 40,
                                width: 40,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  widget.provider.resetFormData();
                  Navigator.of(context).pop();
                },
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: AppTheme.of(context).secondaryText,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _crearNegocio,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Crear Sucursal'),
        ),
      ],
    );
  }

  Future<void> _crearNegocio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.provider.crearNegocio(
        empresaId: widget.empresaId,
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        latitud: double.parse(_latitudController.text.trim()),
        longitud: double.parse(_longitudController.text.trim()),
        tipoLocal: _tipoLocalController.text.trim(),
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sucursal creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al crear la sucursal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
}
