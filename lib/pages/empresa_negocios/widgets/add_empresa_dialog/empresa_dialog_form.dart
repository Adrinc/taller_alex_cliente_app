import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'empresa_form_fields.dart';
import 'empresa_file_section.dart';
import 'empresa_action_buttons.dart';

class EmpresaDialogForm extends StatefulWidget {
  final EmpresasNegociosProvider provider;
  final bool isDesktop;

  const EmpresaDialogForm({
    Key? key,
    required this.provider,
    required this.isDesktop,
  }) : super(key: key);

  @override
  State<EmpresaDialogForm> createState() => _EmpresaDialogFormState();
}

class _EmpresaDialogFormState extends State<EmpresaDialogForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _rfcController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _rfcController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
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
                // Campos del formulario en filas para desktop
                EmpresaFormFields(
                  isDesktop: true,
                  nombreController: _nombreController,
                  rfcController: _rfcController,
                  direccionController: _direccionController,
                  telefonoController: _telefonoController,
                  emailController: _emailController,
                ),

                const SizedBox(height: 20),

                // Sección de archivos
                EmpresaFileSection(
                  provider: widget.provider,
                  isDesktop: true,
                ),

                const SizedBox(height: 25),

                // Botones de acción
                EmpresaActionButtons(
                  isLoading: _isLoading,
                  isDesktop: true,
                  onCancel: () => _handleCancel(),
                  onSubmit: () => _crearEmpresa(),
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
          // Campos del formulario en columnas para móvil
          EmpresaFormFields(
            isDesktop: false,
            nombreController: _nombreController,
            rfcController: _rfcController,
            direccionController: _direccionController,
            telefonoController: _telefonoController,
            emailController: _emailController,
          ),

          const SizedBox(height: 20),

          // Sección de archivos
          EmpresaFileSection(
            provider: widget.provider,
            isDesktop: false,
          ),

          const SizedBox(height: 25),

          // Botones de acción
          EmpresaActionButtons(
            isLoading: _isLoading,
            isDesktop: false,
            onCancel: () => _handleCancel(),
            onSubmit: () => _crearEmpresa(),
          ),
        ],
      ),
    );
  }

  void _handleCancel() {
    widget.provider.resetFormData();
    Navigator.of(context).pop();
  }

  Future<void> _crearEmpresa() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.provider.crearEmpresa(
        nombre: _nombreController.text.trim(),
        rfc: _rfcController.text.trim(),
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim(),
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
                    'Empresa creada exitosamente',
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
                    'Error al crear la empresa',
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
