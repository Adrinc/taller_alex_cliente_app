import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class EmpresaFormFields extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController nombreController;
  final TextEditingController rfcController;
  final TextEditingController direccionController;
  final TextEditingController telefonoController;
  final TextEditingController emailController;

  const EmpresaFormFields({
    Key? key,
    required this.isDesktop,
    required this.nombreController,
    required this.rfcController,
    required this.direccionController,
    required this.telefonoController,
    required this.emailController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopFields(context);
    } else {
      return _buildMobileFields(context);
    }
  }

  Widget _buildDesktopFields(BuildContext context) {
    return Column(
      children: [
        // Primera fila - Nombre y RFC
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildFormField(
                context: context,
                controller: nombreController,
                label: 'Nombre de la empresa',
                hint: 'Ej: TechCorp Solutions S.A.',
                icon: Icons.business_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                context: context,
                controller: rfcController,
                label: 'RFC',
                hint: 'Ej: ABC123456789',
                icon: Icons.assignment_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El RFC es requerido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Segunda fila - Dirección
        _buildFormField(
          context: context,
          controller: direccionController,
          label: 'Dirección',
          hint: 'Dirección completa de la empresa',
          icon: Icons.location_on_rounded,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección es requerida';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Tercera fila - Teléfono y Email
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                context: context,
                controller: telefonoController,
                label: 'Teléfono',
                hint: 'Ej: +52 555 123 4567',
                icon: Icons.phone_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                context: context,
                controller: emailController,
                label: 'Email',
                hint: 'contacto@empresa.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFields(BuildContext context) {
    return Column(
      children: [
        _buildFormField(
          context: context,
          controller: nombreController,
          label: 'Nombre de la empresa',
          hint: 'Ej: TechCorp Solutions S.A. de C.V.',
          icon: Icons.business_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: rfcController,
          label: 'RFC',
          hint: 'Ej: ABC123456789',
          icon: Icons.assignment_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El RFC es requerido';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: direccionController,
          label: 'Dirección',
          hint: 'Dirección completa de la empresa',
          icon: Icons.location_on_rounded,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección es requerida';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: telefonoController,
          label: 'Teléfono',
          hint: 'Ej: +52 555 123 4567',
          icon: Icons.phone_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El teléfono es requerido';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: emailController,
          label: 'Email',
          hint: 'contacto@empresa.com',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El email es requerido';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFormField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          labelStyle: TextStyle(
            color: AppTheme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: 12,
          ),
          filled: true,
          fillColor: AppTheme.of(context).secondaryBackground.withOpacity(0.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: AppTheme.of(context).primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
