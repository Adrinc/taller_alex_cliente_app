import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class EmpresaActionButtons extends StatelessWidget {
  final bool isLoading;
  final bool isDesktop;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const EmpresaActionButtons({
    Key? key,
    required this.isLoading,
    required this.isDesktop,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botón Cancelar
        Expanded(
          child: Container(
            height: isDesktop ? 45 : 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppTheme.of(context).secondaryText.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: TextButton(
              onPressed: isLoading ? null : onCancel,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close_rounded,
                    color: AppTheme.of(context).secondaryText,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppTheme.of(context).secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Botón Crear Empresa
        Expanded(
          flex: 2,
          child: Container(
            height: isDesktop ? 45 : 50,
            decoration: BoxDecoration(
              gradient: AppTheme.of(context).primaryGradient,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.business_center_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Crear Empresa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
