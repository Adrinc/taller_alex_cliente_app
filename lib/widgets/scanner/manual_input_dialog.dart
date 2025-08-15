import 'package:flutter/material.dart';

class ManualInputDialog extends StatefulWidget {
  final Function(String) onRfidEntered;

  const ManualInputDialog({
    super.key,
    required this.onRfidEntered,
  });

  @override
  State<ManualInputDialog> createState() => _ManualInputDialogState();
}

class _ManualInputDialogState extends State<ManualInputDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entrada Manual de RFID'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingrese el código RFID manualmente como alternativa al escaneo:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Código RFID',
                hintText: 'Ej: E200001234567890',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese un código RFID';
                }
                if (value.length < 8) {
                  return 'El código debe tener al menos 8 caracteres';
                }
                return null;
              },
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              widget.onRfidEntered(_controller.text.trim().toUpperCase());
            }
          },
          child: const Text('Procesar'),
        ),
      ],
    );
  }
}
