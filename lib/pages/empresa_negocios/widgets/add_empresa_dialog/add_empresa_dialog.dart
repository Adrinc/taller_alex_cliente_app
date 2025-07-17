import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'empresa_dialog_animations.dart';
import 'empresa_dialog_header.dart';
import 'empresa_dialog_form.dart';

class AddEmpresaDialog extends StatefulWidget {
  final EmpresasNegociosProvider provider;

  const AddEmpresaDialog({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<AddEmpresaDialog> createState() => _AddEmpresaDialogState();
}

class _AddEmpresaDialogState extends State<AddEmpresaDialog>
    with TickerProviderStateMixin {
  late EmpresaDialogAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = EmpresaDialogAnimations(vsync: this);
    _animations.initialize();

    // Escuchar cambios del provider
    widget.provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    if (mounted) {
      setState(() {
        // Forzar rebuild cuando cambie el provider
      });
    }
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChanged);
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_animations.isInitialized) {
      return const SizedBox.shrink();
    }

    // Detectar el tamaño de pantalla
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    final isTablet = screenSize.width > 768 && screenSize.width <= 1024;

    // Ajustar dimensiones según el tipo de pantalla
    final maxWidth = isDesktop ? 900.0 : (isTablet ? 750.0 : 650.0);
    final maxHeight = isDesktop ? 700.0 : 750.0;

    return AnimatedBuilder(
      animation: _animations.combinedAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animations.fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(isDesktop ? 40 : 20),
            child: Transform.scale(
              scale: _animations.scaleAnimation.value,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                  minHeight: isDesktop ? 600 : 400,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: AppTheme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 60,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.of(context).primaryBackground,
                          AppTheme.of(context).secondaryBackground,
                          AppTheme.of(context).tertiaryBackground,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    child: isDesktop
                        ? _buildDesktopLayout()
                        : _buildMobileLayout(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Header lateral compacto para desktop
        EmpresaDialogHeader(
          isDesktop: true,
          slideAnimation: _animations.slideAnimation,
        ),

        // Contenido principal del formulario
        Expanded(
          child: EmpresaDialogForm(
            provider: widget.provider,
            isDesktop: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header para móvil
        EmpresaDialogHeader(
          isDesktop: false,
          slideAnimation: _animations.slideAnimation,
        ),

        // Contenido del formulario para móvil
        Flexible(
          child: EmpresaDialogForm(
            provider: widget.provider,
            isDesktop: false,
          ),
        ),
      ],
    );
  }
}
