import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'negocio_dialog_animations.dart';
import 'negocio_dialog_header.dart';
import 'negocio_dialog_form.dart';

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

class _AddNegocioDialogState extends State<AddNegocioDialog>
    with TickerProviderStateMixin {
  late NegocioDialogAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = NegocioDialogAnimations(vsync: this);
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
    final maxWidth = isDesktop ? 950.0 : (isTablet ? 800.0 : 700.0);
    final maxHeight = isDesktop ? 750.0 : 800.0;

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
                  minHeight: isDesktop ? 650 : 450,
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
        NegocioDialogHeader(
          isDesktop: true,
          slideAnimation: _animations.slideAnimation,
        ),

        // Contenido principal del formulario
        Expanded(
          child: NegocioDialogForm(
            provider: widget.provider,
            isDesktop: true,
            empresaId: widget.empresaId, // Pasar empresaId al formulario
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
        NegocioDialogHeader(
          isDesktop: false,
          slideAnimation: _animations.slideAnimation,
        ),

        // Contenido del formulario para móvil
        Flexible(
          child: NegocioDialogForm(
            provider: widget.provider,
            isDesktop: false,
            empresaId: widget.empresaId, // Pasar empresaId al formulario
          ),
        ),
      ],
    );
  }
}
