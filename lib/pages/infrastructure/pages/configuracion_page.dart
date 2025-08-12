import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/configuracion_widgets/color_config_tab.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/configuracion_widgets/typography_config_tab.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/configuracion_widgets/logo_config_tab.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/configuracion_widgets/saved_themes_tab.dart';
import 'package:nethive_neo/pages/infrastructure/pages/widgets/configuracion_widgets/theme_preview_panel.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeConfigProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.of(context).primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.palette,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configurador de Temas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Personaliza colores, tipografías, logos y más',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón para aplicar tema
                    ElevatedButton.icon(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              await provider.applyTheme();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tema aplicado exitosamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.of(context).primaryColor,
                      ),
                      icon: provider.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: Text(
                          provider.isSaving ? 'Aplicando...' : 'Aplicar Tema'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Error message
              if (provider.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: provider.clearError,
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                ),

              // Contenido principal
              Expanded(
                child: Row(
                  children: [
                    // Panel de configuración
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.of(context)
                                .primaryColor
                                .withOpacity(0.2),
                          ),
                        ),
                        child: DefaultTabController(
                          length: 4,
                          child: Column(
                            children: [
                              // Tab bar
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.of(context).primaryBackground,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                                child: TabBar(
                                  labelColor: AppTheme.of(context).primaryColor,
                                  unselectedLabelColor:
                                      AppTheme.of(context).secondaryText,
                                  indicatorColor:
                                      AppTheme.of(context).primaryColor,
                                  tabs: const [
                                    Tab(
                                      icon: Icon(Icons.palette),
                                      text: 'Colores',
                                    ),
                                    Tab(
                                      icon: Icon(Icons.text_fields),
                                      text: 'Tipografía',
                                    ),
                                    Tab(
                                      icon: Icon(Icons.image),
                                      text: 'Logos',
                                    ),
                                    Tab(
                                      icon: Icon(Icons.bookmark),
                                      text: 'Temas',
                                    ),
                                  ],
                                ),
                              ),

                              // Tab content
                              const Expanded(
                                child: TabBarView(
                                  children: [
                                    ColorConfigTab(),
                                    TypographyConfigTab(),
                                    LogoConfigTab(),
                                    SavedThemesTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Panel de preview (solo en pantallas grandes)
                    if (MediaQuery.of(context).size.width > 1200)
                      const ThemePreviewPanel(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
