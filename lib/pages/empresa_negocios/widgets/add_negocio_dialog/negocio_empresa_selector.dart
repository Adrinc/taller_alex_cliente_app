import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class NegocioEmpresaSelector extends StatelessWidget {
  final EmpresasNegociosProvider provider;
  final bool isDesktop;

  const NegocioEmpresaSelector({
    super.key,
    required this.provider,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).formBackground,
            AppTheme.of(context).secondaryBackground.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.of(context).tertiaryColor,
                      AppTheme.of(context).primaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Seleccionar Empresa',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildEmpresaDropdown(context),
        ],
      ),
    );
  }

  Widget _buildEmpresaDropdown(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: provider.empresaSeleccionadaId,
        decoration: InputDecoration(
          hintText: 'Selecciona una empresa',
          hintStyle: TextStyle(
            color: AppTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: 14,
          ),
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
            ),
            child: const Icon(
              Icons.business_center_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        dropdownColor: AppTheme.of(context).secondaryBackground,
        style: TextStyle(
          color: AppTheme.of(context).primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppTheme.of(context).primaryColor,
          size: 28,
        ),
        items: provider.empresas.map((empresa) {
          return DropdownMenuItem<String>(
            value: empresa.id,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.business_rounded,
                      color: AppTheme.of(context).primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          empresa.nombre,
                          style: TextStyle(
                            color: AppTheme.of(context).primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          empresa.rfc,
                          style: TextStyle(
                            color: AppTheme.of(context).secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          provider.setEmpresaSeleccionada(newValue!);
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecciona una empresa';
          }
          return null;
        },
      ),
    );
  }
}
