import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/widgets/scanner/scanner_camera_view.dart';
import 'package:nethive_neo/widgets/scanner/rfid_result_bottom_sheet_new.dart';
import 'package:nethive_neo/widgets/scanner/manual_input_dialog.dart';
import 'package:nethive_neo/widgets/scanner/batch_mode_panel.dart';
import 'package:nethive_neo/theme/theme.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanLineController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryBackground,
              theme.secondaryBackground,
              theme.tertiaryBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<RfidScannerProvider>(
            builder: (context, scanner, child) {
              return Column(
                children: [
                  // Header personalizado
                  _buildHeader(theme, scanner),

                  // Área principal de escaneo
                  Expanded(
                    flex: 3,
                    child: _buildScanningArea(scanner),
                  ),

                  // Panel de modo lote (si está activo)
                  if (scanner.isBatchMode)
                    Expanded(
                      flex: 1,
                      child: BatchModePanel(
                        scannedRfids: scanner.batchScannedRfids,
                        onRemoveRfid: scanner.removeFromBatch,
                        onClearBatch: scanner.clearBatch,
                      ),
                    ),

                  // Panel de controles inferior
                  _buildControlsPanel(scanner),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme, RfidScannerProvider scanner) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barra superior con botón atrás
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Escáner RFID',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Botones de acción
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    scanner.isBatchMode
                        ? Icons.list_alt
                        : Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  scanner.toggleBatchMode();
                },
                tooltip: scanner.isBatchMode ? 'Modo individual' : 'Modo lote',
              ),
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.keyboard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () => _showManualInputDialog(),
                tooltip: 'Entrada manual',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Estado de conexión
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scanner.isConnected
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scanner.isConnected ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  scanner.isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  color: scanner.isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  scanner.isConnected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    color: scanner.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningArea(RfidScannerProvider scanner) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scanner.isScanning
              ? Colors.blue.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Vista de cámara simulada
          const ScannerCameraView(),

          // Overlay de escaneo
          if (scanner.isScanning) _buildScanningOverlay(),

          // Información del último escaneo
          if (scanner.lastScannedRfid != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildLastScanInfo(scanner),
            ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Línea de escaneo animada
          AnimatedBuilder(
            animation: _scanLineController,
            builder: (context, child) {
              return Positioned(
                left: 50,
                right: 50,
                top: 50 + (_scanLineController.value * 200),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue,
                        Colors.transparent
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),

          // Esquinas de enfoque
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerCornersPainter(),
            ),
          ),

          // Pulso central
          Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 80 + (_pulseController.value * 40),
                  height: 80 + (_pulseController.value * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          Colors.blue.withOpacity(1 - _pulseController.value),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastScanInfo(RfidScannerProvider scanner) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Último escaneo:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scanner.lastScannedRfid!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (scanner.lastScanTime != null)
            Text(
              _formatTime(scanner.lastScanTime!),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlsPanel(RfidScannerProvider scanner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón de escaneo principal
          ElevatedButton.icon(
            onPressed: scanner.isConnected
                ? () {
                    if (scanner.isScanning) {
                      scanner.stopScanning();
                    } else {
                      scanner.startScanning();
                      _simulateRfidScan(scanner); // Solo para demo
                    }
                  }
                : null,
            icon: Icon(
              scanner.isScanning ? Icons.stop : Icons.play_arrow,
            ),
            label: Text(
              scanner.isScanning ? 'Detener' : 'Escanear',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: scanner.isScanning ? Colors.red : Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12), // Reducido padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
              .animate(
                target: scanner.isScanning ? 1 : 0,
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05), // Reducido el scale
                duration: const Duration(milliseconds: 500),
              ),

          // Botón de configuración
          OutlinedButton.icon(
            onPressed: () => _showSettingsDialog(scanner),
            icon: const Icon(Icons.settings, color: Colors.white),
            label: const Text('Config', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Botón de inventario
          OutlinedButton.icon(
            onPressed: () => context.go('/inventario'),
            icon: const Icon(Icons.inventory, color: Colors.white),
            label:
                const Text('Inventario', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simulación de escaneo para demo
  void _simulateRfidScan(RfidScannerProvider scanner) {
    if (!scanner.isScanning) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (scanner.isScanning) {
        final rfidCode =
            'E200001${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        _handleRfidScanned(rfidCode);
      }
    });
  }

  void _handleRfidScanned(String rfidCode) async {
    final scanner = context.read<RfidScannerProvider>();
    final result = await scanner.processScannedRfid(rfidCode);

    // Mostrar resultado en bottom sheet
    if (mounted) {
      _showRfidResultBottomSheet(result);
    }
  }

  void _showRfidResultBottomSheet(RfidScanResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RfidResultBottomSheet(result: result),
    );
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualInputDialog(
        onRfidEntered: _handleRfidScanned,
      ),
    );
  }

  void _showSettingsDialog(RfidScannerProvider scanner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración del Escáner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Modo HID'),
              subtitle: Text(scanner.isHidMode
                  ? 'Entrada por teclado'
                  : 'Bluetooth Serial'),
              value: scanner.isHidMode,
              onChanged: scanner.setScannerMode,
            ),
            ListTile(
              title: const Text('Reconectar Escáner'),
              leading: const Icon(Icons.refresh),
              onTap: () {
                scanner.initializeScanner();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

class ScannerCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;
    const margin = 50.0;

    // Esquina superior izquierda
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin + cornerLength, margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, margin),
      Offset(margin, margin + cornerLength),
      paint,
    );

    // Esquina superior derecha
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin - cornerLength, margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, margin),
      Offset(size.width - margin, margin + cornerLength),
      paint,
    );

    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin + cornerLength, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(margin, size.height - margin),
      Offset(margin, size.height - margin - cornerLength),
      paint,
    );

    // Esquina inferior derecha
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin - cornerLength, size.height - margin),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin),
      Offset(size.width - margin, size.height - margin - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
