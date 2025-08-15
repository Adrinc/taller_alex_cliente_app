import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/widgets/common/custom_app_bar.dart';

class ComponenteSelectorPage extends StatefulWidget {
  final String? rfidCode;

  const ComponenteSelectorPage({
    super.key,
    this.rfidCode,
  });

  @override
  State<ComponenteSelectorPage> createState() => _ComponenteSelectorPageState();
}

class _ComponenteSelectorPageState extends State<ComponenteSelectorPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Seleccionar Componente',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del RFID
            if (widget.rfidCode != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Colors.blue.shade700,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asignar RFID a Componente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'RFID: ${widget.rfidCode!}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Buscador
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar componente...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: Icon(Icons.filter_list),
              ),
              onChanged: (value) {
                // Implementar búsqueda
              },
            ),
            const SizedBox(height: 20),

            // Lista de componentes
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selector de Componentes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esta funcionalidad está en desarrollo.\nPermitirá buscar y seleccionar componentes existentes\npara asignarles el RFID escaneado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
