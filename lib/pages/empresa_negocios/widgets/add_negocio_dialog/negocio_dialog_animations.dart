import 'package:flutter/material.dart';

class NegocioDialogAnimations {
  final TickerProvider vsync;

  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Listenable _combinedAnimation;
  bool _isInitialized = false;

  NegocioDialogAnimations({required this.vsync});

  // Getters para acceder a las animaciones
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<Offset> get slideAnimation => _slideAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;
  Listenable get combinedAnimation => _combinedAnimation;
  bool get isInitialized => _isInitialized;

  void initialize() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _combinedAnimation =
        Listenable.merge([_scaleAnimation, _slideAnimation, _fadeAnimation]);

    // Pequeño delay para asegurar que el widget esté completamente montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitialized = true;
      _startAnimations();
    });
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
  }
}
