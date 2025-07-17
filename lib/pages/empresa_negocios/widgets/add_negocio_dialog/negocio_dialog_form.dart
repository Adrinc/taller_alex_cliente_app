import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'negocio_form_fields.dart';
import 'negocio_empresa_selector.dart';
import 'negocio_action_buttons.dart';

class NegocioDialogForm extends StatefulWidget {
  final EmpresasNegociosProvider provider;
  final bool isDesktop;
  final String empresaId;

  const NegocioDialogForm({
    Key? key,
    required this.provider,
    required this.isDesktop,
    required this.empresaId,
  }) : super(key: key);

  @override
  State<NegocioDialogForm> createState() => _NegocioDialogFormState();
}

class _NegocioDialogFormState extends State<NegocioDialogForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _tipoLocalController = TextEditingController();
  bool _isLoading = false;

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
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Form(
        key: _formKey,
        child: widget.isDesktop ? _buildDesktopForm() : _buildMobileForm(),
      ),
    );
  }

  Widget _buildDesktopForm() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Selector de empresa
                NegocioEmpresaSelector(
                  provider: widget.provider,
                  isDesktop: true,
                ),

                const SizedBox(height: 20),

                // Campos del formulario en filas para desktop
                NegocioFormFields(
                  isDesktop: true,
                  nombreController: _nombreController,
                  direccionController: _direccionController,
                  latitudController: _latitudController,
                  longitudController: _longitudController,
                  tipoLocalController: _tipoLocalController,
                ),

                const SizedBox(height: 25),

                // Botones de acción
                NegocioActionButtons(
                  isLoading: _isLoading,
                  isDesktop: true,
                  onCancel: () => _handleCancel(),
                  onSubmit: () => _crearNegocio(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Selector de empresa
          NegocioEmpresaSelector(
            provider: widget.provider,
            isDesktop: false,
          ),

          const SizedBox(height: 20),

          // Campos del formulario en columnas para móvil
          NegocioFormFields(
            isDesktop: false,
            nombreController: _nombreController,
            direccionController: _direccionController,
            latitudController: _latitudController,
            longitudController: _longitudController,
            tipoLocalController: _tipoLocalController,
          ),

          const SizedBox(height: 25),

          // Botones de acción
          NegocioActionButtons(
            isLoading: _isLoading,
            isDesktop: false,
            onCancel: () => _handleCancel(),
            onSubmit: () => _crearNegocio(),
          ),
        ],
      ),
    );
  }

  void _handleCancel() {
    widget.provider.resetFormData();
    Navigator.of(context).pop();
  }

  Future<void> _crearNegocio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final latitud = double.parse(_latitudController.text.trim());
      final longitud = double.parse(_longitudController.text.trim());

      final success = await widget.provider.crearNegocio(
        empresaId: widget.empresaId, // Usar el empresaId pasado como parámetro
        nombre: _nombreController.text.trim(),
        direccion: _direccionController.text.trim(),
        latitud: latitud,
        longitud: longitud,
        tipoLocal: _tipoLocalController.text.trim(),
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Negocio creado exitosamente',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Error al crear el negocio',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
}
