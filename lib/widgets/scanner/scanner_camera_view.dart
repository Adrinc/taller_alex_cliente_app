import 'package:flutter/material.dart';

class ScannerCameraView extends StatelessWidget {
  const ScannerCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a1a),
            Color(0xFF2d2d2d),
            Color(0xFF1a1a1a),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Simulación de vista de cámara
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.center_focus_strong,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enfoque el RFID en esta área',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mantenga el dispositivo estable',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Efectos de luz ambiente
          Positioned.fill(
            child: CustomPaint(
              painter: CameraEffectsPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraEffectsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Crear efecto de luz sutil
    final gradient = RadialGradient(
      center: const Alignment(0.3, -0.3),
      radius: 0.8,
      colors: [
        Colors.blue.withOpacity(0.1),
        Colors.transparent,
      ],
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
