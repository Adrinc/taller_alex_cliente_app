import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:nethive_neo/theme/theme.dart';
import 'package:nethive_neo/helpers/globals.dart';

class ScannerPage extends StatefulWidget {
  final String? negocioId;

  const ScannerPage({
    super.key,
    this.negocioId,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scannerAnimationController;

  String _scanResult = '';
  bool _isScanning = false;
  List<String> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scannerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animationController.forward();
    _scannerAnimationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerAnimationController.dispose();
    super.dispose();
  }

  Future<String> _simulateScanner() async {
    // Simulación de scanner para desarrollo
    // TODO: Reemplazar con mobile_scanner real
    await Future.delayed(const Duration(seconds: 2));
    
    // Retornar un RFID de prueba
    final List<String> testRfids = [
      'E2001122334455667788',
      'E2002233445566778899',
      'E2003344556677889900',
      'E2004455667788990011',
    ];
    
    // Retornar un RFID aleatorio
    return testRfids[(DateTime.now().millisecond % testRfids.length)];
  }

  Future<void> _startScanning() async {
    // Verificar permisos de cámara
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      _showErrorMessage('Permiso de cámara requerido para escanear');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      // TODO: Implementar mobile_scanner
      // Por ahora simulamos un resultado de prueba
      final barcodeScanRes = await _simulateScanner();

      if (barcodeScanRes != '-1' && barcodeScanRes.isNotEmpty) {
        await _processScanResult(barcodeScanRes);
      }
    } catch (e) {
      _showErrorMessage('Error al escanear: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _processScanResult(String scanResult) async {
    // Vibrar para confirmar escaneo exitoso
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }

    setState(() {
      _scanResult = scanResult;
      if (!_scanHistory.contains(scanResult)) {
        _scanHistory.insert(0, scanResult);
        // Mantener solo los últimos 10 escaneos
        if (_scanHistory.length > 10) {
          _scanHistory = _scanHistory.take(10).toList();
        }
      }
    });

    // Buscar información del componente en la base de datos
    await _searchComponent(scanResult);
  }

  Future<void> _searchComponent(String rfidCode) async {
    try {
      final response = await supabaseLU
          .from('componente')
          .select('*, ubicacion(*), categoria_componente(*)')
          .eq('codigo_rfid', rfidCode)
          .maybeSingle();

      if (response != null) {
        _showComponentInfo(response);
      } else {
        _showCreateComponentDialog(rfidCode);
      }
    } catch (e) {
      _showErrorMessage('Error al buscar componente: $e');
    }
  }

  void _showComponentInfo(Map<String, dynamic> component) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildComponentInfoSheet(component),
    );
  }

  void _showCreateComponentDialog(String rfidCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Componente No Encontrado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código RFID: $rfidCode'),
            const SizedBox(height: 16),
            const Text('Este código RFID no está registrado en el sistema.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/componente-form?rfidCode=$rfidCode');
            },
            child: const Text('Crear Componente'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
          child: Column(
            children: [
              // Header
              _buildHeader(theme),

              // Scanner Area
              Expanded(
                child: _buildScannerArea(theme),
              ),

              // History
              if (_scanHistory.isNotEmpty) _buildScanHistory(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Barra superior
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
              const Expanded(
                child: Text(
                  'Escáner RFID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 56),
            ],
          ),

          const SizedBox(height: 20),

          // Icono y descripción
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 40,
            ),
          )
              .animate()
              .scale(delay: 200.ms, duration: 800.ms)
              .fadeIn(duration: 800.ms),

          const SizedBox(height: 20),

          Text(
            'Escanear Etiqueta RFID',
            style: theme.title2.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 8),

          Text(
            'Presiona el botón para iniciar el escaneo',
            style: theme.bodyText2.copyWith(color: Colors.white60),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildScannerArea(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Área de escaneo visual
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isScanning
                    ? theme.primaryColor
                    : Colors.white.withOpacity(0.3),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animación de escaneo
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _scannerAnimationController,
                    builder: (context, child) {
                      return Positioned(
                        top: _scannerAnimationController.value * 220 + 20,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                theme.primaryColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Icono central
                Icon(
                  Icons.qr_code_2,
                  size: 120,
                  color: _isScanning
                      ? theme.primaryColor.withOpacity(0.8)
                      : Colors.white.withOpacity(0.3),
                ),

                // Esquinas del marco
                ...List.generate(4, (index) {
                  final positions = [
                    {'top': 0.0, 'left': 0.0}, // Top-left
                    {'top': 0.0, 'right': 0.0}, // Top-right
                    {'bottom': 0.0, 'left': 0.0}, // Bottom-left
                    {'bottom': 0.0, 'right': 0.0}, // Bottom-right
                  ];

                  return Positioned(
                    top: positions[index]['top'],
                    left: positions[index]['left'],
                    right: positions[index]['right'],
                    bottom: positions[index]['bottom'],
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: index < 2
                              ? BorderSide(color: theme.primaryColor, width: 4)
                              : BorderSide.none,
                          bottom: index >= 2
                              ? BorderSide(color: theme.primaryColor, width: 4)
                              : BorderSide.none,
                          left: index % 2 == 0
                              ? BorderSide(color: theme.primaryColor, width: 4)
                              : BorderSide.none,
                          right: index % 2 == 1
                              ? BorderSide(color: theme.primaryColor, width: 4)
                              : BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ).animate().scale(delay: 800.ms, duration: 600.ms),

          const SizedBox(height: 40),

          // Botón de escaneo
          Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isScanning
                    ? [Colors.grey, Colors.grey[600]!]
                    : [theme.primaryColor, theme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (_isScanning ? Colors.grey : theme.primaryColor)
                      .withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isScanning ? null : _startScanning,
                borderRadius: BorderRadius.circular(30),
                child: Center(
                  child: _isScanning
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: SpinKitRing(
                                color: Colors.white,
                                size: 20,
                                lineWidth: 3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Escaneando...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Iniciar Escaneo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 1000.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

          // Resultado del último escaneo
          if (_scanResult.isNotEmpty) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Último escaneo:',
                    style: theme.bodyText3.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _scanResult,
                          style: theme.subtitle2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _scanResult));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código copiado al portapapeles'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.white60,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildScanHistory(AppTheme theme) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Historial de escaneos',
                style: theme.subtitle2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _scanHistory.clear();
                    _scanResult = '';
                  });
                },
                child: Text(
                  'Limpiar',
                  style: theme.bodyText3.copyWith(
                    color: theme.tertiaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _scanHistory.take(3).length,
            (index) => Container(
              margin: EdgeInsets.only(bottom: index < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _scanHistory[index],
                      style: theme.bodyText3.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _searchComponent(_scanHistory[index]),
                    icon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.6),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentInfoSheet(Map<String, dynamic> component) {
    final theme = AppTheme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        component['nombre'] ?? 'Componente',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        component['categoria_componente']?['nombre'] ??
                            'Sin categoría',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Información del componente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildInfoRow('Código RFID', component['codigo_rfid'] ?? ''),
                _buildInfoRow('Modelo', component['modelo'] ?? ''),
                _buildInfoRow('Fabricante', component['fabricante'] ?? ''),
                _buildInfoRow('Estado', component['estado'] ?? ''),
                if (component['ubicacion'] != null)
                  _buildInfoRow(
                      'Ubicación', component['ubicacion']['nombre'] ?? ''),
                if (component['descripcion'] != null &&
                    component['descripcion'].isNotEmpty)
                  _buildInfoRow('Descripción', component['descripcion']),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(
                          '/componente-form?componentId=${component['id']}');
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context
                          .push('/inventario?componentId=${component['id']}');
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Ver en Inventario'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black87 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
