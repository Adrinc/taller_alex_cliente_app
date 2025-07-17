import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nethive_neo/theme/theme.dart';

class NegocioFormFields extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController nombreController;
  final TextEditingController direccionController;
  final TextEditingController latitudController;
  final TextEditingController longitudController;
  final TextEditingController tipoLocalController;

  const NegocioFormFields({
    Key? key,
    required this.isDesktop,
    required this.nombreController,
    required this.direccionController,
    required this.latitudController,
    required this.longitudController,
    required this.tipoLocalController,
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
        // Primera fila - Nombre del negocio
        _buildFormField(
          context: context,
          controller: nombreController,
          label: 'Nombre del negocio',
          hint: 'Ej: Sucursal Centro, Tienda Principal',
          icon: Icons.store_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Segunda fila - Dirección
        _buildFormField(
          context: context,
          controller: direccionController,
          label: 'Dirección',
          hint: 'Dirección completa del negocio',
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

        // Tercera fila - Coordenadas
        Row(
          children: [
            Expanded(
              child: _buildFormField(
                context: context,
                controller: latitudController,
                label: 'Latitud',
                hint: 'Ej: 19.4326',
                icon: Icons.location_searching,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La latitud es requerida';
                  }
                  final lat = double.tryParse(value);
                  if (lat == null) {
                    return 'Número inválido';
                  }
                  if (lat < -90 || lat > 90) {
                    return 'Debe estar entre -90 y 90';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFormField(
                context: context,
                controller: longitudController,
                label: 'Longitud',
                hint: 'Ej: -99.1332',
                icon: Icons.location_searching,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La longitud es requerida';
                  }
                  final lng = double.tryParse(value);
                  if (lng == null) {
                    return 'Número inválido';
                  }
                  if (lng < -180 || lng > 180) {
                    return 'Debe estar entre -180 y 180';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Cuarta fila - Tipo de local
        _buildFormField(
          context: context,
          controller: tipoLocalController,
          label: 'Tipo de local',
          hint: 'Ej: Sucursal, Matriz, Almacén',
          icon: Icons.business,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El tipo de local es requerido';
            }
            return null;
          },
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
          label: 'Nombre del negocio',
          hint: 'Ej: Sucursal Centro, Tienda Principal',
          icon: Icons.store_rounded,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es requerido';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: direccionController,
          label: 'Dirección',
          hint: 'Dirección completa del negocio',
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
          controller: latitudController,
          label: 'Latitud',
          hint: 'Ej: 19.4326',
          icon: Icons.location_searching,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La latitud es requerida';
            }
            final lat = double.tryParse(value);
            if (lat == null) {
              return 'Número inválido';
            }
            if (lat < -90 || lat > 90) {
              return 'Debe estar entre -90 y 90';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: longitudController,
          label: 'Longitud',
          hint: 'Ej: -99.1332',
          icon: Icons.location_searching,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La longitud es requerida';
            }
            final lng = double.tryParse(value);
            if (lng == null) {
              return 'Número inválido';
            }
            if (lng < -180 || lng > 180) {
              return 'Debe estar entre -180 y 180';
            }
            return null;
          },
        ),
        _buildFormField(
          context: context,
          controller: tipoLocalController,
          label: 'Tipo de local',
          hint: 'Ej: Sucursal, Matriz, Almacén',
          icon: Icons.business,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El tipo de local es requerido';
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
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
              gradient: LinearGradient(
                colors: [
                  AppTheme.of(context).tertiaryColor,
                  AppTheme.of(context).primaryColor,
                ],
              ),
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
