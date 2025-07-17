import 'package:flutter/material.dart';
import 'package:nethive_neo/theme/theme.dart';

class NegocioDialogHeader extends StatelessWidget {
  final bool isDesktop;
  final Animation<Offset> slideAnimation;

  const NegocioDialogHeader({
    Key? key,
    required this.isDesktop,
    required this.slideAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopHeader(context);
    } else {
      return _buildMobileHeader(context);
    }
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.of(context).tertiaryColor,
            AppTheme.of(context).primaryColor,
            AppTheme.of(context).secondaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.of(context).primaryColor.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(context),
              const SizedBox(height: 20),
              _buildTitle(context, fontSize: 24),
              const SizedBox(height: 8),
              _buildSubtitle(context, fontSize: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.of(context).tertiaryColor,
              AppTheme.of(context).primaryColor,
              AppTheme.of(context).secondaryColor,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.of(context).primaryColor.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 15),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildIcon(context),
            const SizedBox(height: 16),
            _buildTitle(context, fontSize: 26),
            const SizedBox(height: 8),
            _buildSubtitle(context, fontSize: 14, isMobile: true),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 18),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.store_rounded,
        color: Colors.white,
        size: isDesktop ? 35 : 35,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, {required double fontSize}) {
    return Text(
      'Nuevo Negocio',
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context,
      {required double fontSize, bool isMobile = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        isMobile
            ? '🏪 Registra un nuevo negocio o sucursal'
            : '🏪 Registra un nuevo negocio',
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
