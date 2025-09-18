import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nethive_neo/theme/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // Navegación automática después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // TODO: Navegar a la siguiente pantalla
        // Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TallerAlexColors.neumorphicBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TallerAlexColors.neumorphicBackground,
              TallerAlexColors.paleRose.withOpacity(0.3),
              TallerAlexColors.neumorphicBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo animado con efecto neumórfico
              FadeInDown(
                duration: const Duration(milliseconds: 1000),
                child: ScaleTransition(
                  scale: _animation,
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(40),
                    borderRadius: 30,
                    depth: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono del taller con gradiente
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            gradient: TallerAlexColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.car_repair,
                            size: 45,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nombre de la app
                        ShaderMask(
                          shaderCallback: (bounds) => TallerAlexColors
                              .primaryGradient
                              .createShader(bounds),
                          child: Text(
                            'Taller Alex',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Cliente',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: TallerAlexColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Indicador de carga con animación personalizada
              FadeInUp(
                duration: const Duration(milliseconds: 1200),
                delay: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    Text(
                      'Cargando...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: TallerAlexColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Barra de progreso neumórfica personalizada
                    const LoadingAnimation(),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Mensaje de bienvenida
              FadeIn(
                duration: const Duration(milliseconds: 1500),
                delay: const Duration(milliseconds: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Transparencia y control total\nde tu vehículo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TallerAlexColors.textSecondary,
                          height: 1.5,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget personalizado para mostrar diferentes efectos de loading
class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({Key? key}) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotController,
          builder: (context, child) {
            final value =
                (_dotController.value - (index * 0.2)).clamp(0.0, 1.0);
            return Transform.scale(
              scale: 1.0 + (0.3 * value),
              child: Opacity(
                opacity: 0.3 + (0.7 * value),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: TallerAlexColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
