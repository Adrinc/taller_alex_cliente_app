import 'package:flutter/material.dart';

class BatchModePanel extends StatelessWidget {
  final List<String> scannedRfids;
  final Function(String) onRemoveRfid;
  final VoidCallback onClearBatch;

  const BatchModePanel({
    super.key,
    required this.scannedRfids,
    required this.onRemoveRfid,
    required this.onClearBatch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          top: BorderSide(color: Colors.orange.shade200, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Header del panel
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Modo Lote - ${scannedRfids.length} RFIDs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (scannedRfids.isNotEmpty)
                  TextButton.icon(
                    onPressed: onClearBatch,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Limpiar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                    ),
                  ),
              ],
            ),
          ),

          // Lista de RFIDs
          Expanded(
            child: scannedRfids.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: Colors.orange.shade300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Escanee RFIDs para agregarlos al lote',
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: scannedRfids.length,
                    itemBuilder: (context, index) {
                      final rfid = scannedRfids[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 4),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.qr_code,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                          title: Text(
                            rfid,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            'RFID ${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.red.shade400,
                              size: 20,
                            ),
                            onPressed: () => onRemoveRfid(rfid),
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
}
