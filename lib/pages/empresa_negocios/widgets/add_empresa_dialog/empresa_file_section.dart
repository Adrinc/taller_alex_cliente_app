import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';

class EmpresaFileSection extends StatelessWidget {
  final EmpresasNegociosProvider provider;
  final bool isDesktop;

  const EmpresaFileSection({
    Key? key,
    required this.provider,
    required this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primaryColor.withOpacity(0.1),
            AppTheme.of(context).tertiaryColor.withOpacity(0.1),
            AppTheme.of(context).secondaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          _buildSectionHeader(context),

          const SizedBox(height: 16),

          // Botones de archivos
          if (isDesktop)
            _buildDesktopFileButtons(context)
          else
            _buildMobileFileButtons(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.of(context).primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.of(context).primaryColor.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.cloud_upload_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Archivos Opcionales',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.of(context).primaryText,
              ),
            ),
            Text(
              'Logo e imagen de la empresa',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFileButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCompactFileButton(
            context: context,
            label: 'Logo de la empresa',
            subtitle: 'PNG, JPG (Max 2MB)',
            icon: Icons.image_rounded,
            fileName: provider.logoFileName,
            file: provider.logoToUpload,
            onPressed: provider.selectLogo,
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompactFileButton(
            context: context,
            label: 'Imagen principal',
            subtitle: 'Imagen representativa',
            icon: Icons.photo_library_rounded,
            fileName: provider.imagenFileName,
            file: provider.imagenToUpload,
            onPressed: provider.selectImagen,
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFileButtons(BuildContext context) {
    return Column(
      children: [
        _buildEnhancedFileButton(
          context: context,
          label: 'Logo de la empresa',
          subtitle: 'Formato PNG, JPG (Max 2MB)',
          icon: Icons.image_rounded,
          fileName: provider.logoFileName,
          file: provider.logoToUpload,
          onPressed: provider.selectLogo,
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
          ),
        ),
        const SizedBox(height: 12),
        _buildEnhancedFileButton(
          context: context,
          label: 'Imagen principal',
          subtitle: 'Imagen representativa de la empresa',
          icon: Icons.photo_library_rounded,
          fileName: provider.imagenFileName,
          file: provider.imagenToUpload,
          onPressed: provider.selectImagen,
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFileButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required String? fileName,
    required dynamic file,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Icono con gradiente
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(height: 8),

                // Información del archivo
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  fileName ?? subtitle,
                  style: TextStyle(
                    color: fileName != null
                        ? AppTheme.of(context).primaryColor
                        : AppTheme.of(context).secondaryText,
                    fontSize: 11,
                    fontWeight:
                        fileName != null ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),

                // Preview de imagen si existe
                if (file != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: provider.getImageWidget(
                        file,
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFileButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required String? fileName,
    required dynamic file,
    required VoidCallback onPressed,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono con gradiente
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del archivo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: AppTheme.of(context).primaryText,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileName ?? subtitle,
                        style: TextStyle(
                          color: fileName != null
                              ? AppTheme.of(context).primaryColor
                              : AppTheme.of(context).secondaryText,
                          fontSize: 13,
                          fontWeight: fileName != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Preview de imagen si existe
                if (file != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            AppTheme.of(context).primaryColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: provider.getImageWidget(
                        file,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.upload_file,
                      color: AppTheme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
