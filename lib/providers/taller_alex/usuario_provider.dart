import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class UsuarioProvider extends ChangeNotifier {
  // Datos del usuario
  Map<String, dynamic> _usuario = {
    'nombre': 'Carlos Rodríguez',
    'email': 'carlos.rodriguez@email.com',
    'telefono': '55 1234 5678',
    'direccion': 'Av. Revolución 123, Col. Roma Norte',
    'rfc': 'RORC850215ABC',
    'fechaNacimiento': DateTime(1985, 2, 15),
    'genero': 'Masculino',
    'ocupacion': 'Ingeniero',
    'imagen': null, // Aquí se almacenará la ruta de imagen temporal
  };

  // Bytes de la imagen de perfil (para demo temporal)
  Uint8List? _imagenBytes;

  // Preferencias de notificaciones
  Map<String, bool> _notificationPreferences = {
    'citasRecordatorios': true,
    'estadoOrden': true,
    'promociones': false,
    'newsletter': false,
    'push': true,
    'email': true,
    'sms': false,
  };

  // Configuración de la app
  Map<String, dynamic> _appSettings = {
    'tema': 'claro', // claro, oscuro
    'idioma': 'es',
    'mostrarTutoriales': true,
    'autoSync': true,
  };

  // Getters
  Map<String, dynamic> get usuario => Map.unmodifiable(_usuario);
  Map<String, bool> get notificationPreferences =>
      Map.unmodifiable(_notificationPreferences);
  Map<String, dynamic> get appSettings => Map.unmodifiable(_appSettings);

  String get nombreCompleto => _usuario['nombre'] ?? '';
  String get email => _usuario['email'] ?? '';
  String get telefono => _usuario['telefono'] ?? '';
  String get direccion => _usuario['direccion'] ?? '';
  String get rfc => _usuario['rfc'] ?? '';
  DateTime? get fechaNacimiento => _usuario['fechaNacimiento'];
  String get genero => _usuario['genero'] ?? '';
  String get ocupacion => _usuario['ocupacion'] ?? '';
  String? get imagenPerfil => _usuario['imagen'];
  Uint8List? get imagenBytes => _imagenBytes;

  // Métodos para actualizar datos del usuario
  void actualizarNombre(String nombre) {
    _usuario['nombre'] = nombre;
    notifyListeners();
  }

  void actualizarEmail(String email) {
    _usuario['email'] = email;
    notifyListeners();
  }

  void actualizarTelefono(String telefono) {
    _usuario['telefono'] = telefono;
    notifyListeners();
  }

  void actualizarDireccion(String direccion) {
    _usuario['direccion'] = direccion;
    notifyListeners();
  }

  void actualizarRFC(String rfc) {
    _usuario['rfc'] = rfc;
    notifyListeners();
  }

  void actualizarFechaNacimiento(DateTime fecha) {
    _usuario['fechaNacimiento'] = fecha;
    notifyListeners();
  }

  void actualizarGenero(String genero) {
    _usuario['genero'] = genero;
    notifyListeners();
  }

  void actualizarOcupacion(String ocupacion) {
    _usuario['ocupacion'] = ocupacion;
    notifyListeners();
  }

  void actualizarImagenPerfil(String? imagePath) {
    _usuario['imagen'] = imagePath;
    _imagenBytes = null; // Limpiar bytes si se usa ruta
    notifyListeners();
  }

  void actualizarImagenBytes(Uint8List bytes) {
    _imagenBytes = bytes;
    _usuario['imagen'] = null; // Limpiar ruta si se usan bytes
    notifyListeners();
  }

  void actualizarDatosCompletos({
    String? nombre,
    String? email,
    String? telefono,
    String? direccion,
    String? rfc,
    DateTime? fechaNacimiento,
    String? genero,
    String? ocupacion,
  }) {
    if (nombre != null) _usuario['nombre'] = nombre;
    if (email != null) _usuario['email'] = email;
    if (telefono != null) _usuario['telefono'] = telefono;
    if (direccion != null) _usuario['direccion'] = direccion;
    if (rfc != null) _usuario['rfc'] = rfc;
    if (fechaNacimiento != null) _usuario['fechaNacimiento'] = fechaNacimiento;
    if (genero != null) _usuario['genero'] = genero;
    if (ocupacion != null) _usuario['ocupacion'] = ocupacion;
    notifyListeners();
  }

  // Métodos para configuración de notificaciones
  void actualizarPreferenciaNotificacion(String tipo, bool valor) {
    _notificationPreferences[tipo] = valor;
    notifyListeners();
  }

  void actualizarTodasLasNotificaciones(Map<String, bool> preferencias) {
    _notificationPreferences.addAll(preferencias);
    notifyListeners();
  }

  // Métodos para configuración de la app
  void cambiarTema(String tema) {
    _appSettings['tema'] = tema;
    notifyListeners();
  }

  void cambiarIdioma(String idioma) {
    _appSettings['idioma'] = idioma;
    notifyListeners();
  }

  void actualizarConfiguracion(String key, dynamic value) {
    _appSettings[key] = value;
    notifyListeners();
  }

  // Método para obtener iniciales del nombre
  String getIniciales() {
    final nombre = nombreCompleto.trim();
    if (nombre.isEmpty) return 'U';

    final palabras = nombre.split(' ');
    if (palabras.length == 1) {
      return palabras[0].substring(0, 1).toUpperCase();
    } else {
      return '${palabras[0].substring(0, 1)}${palabras[1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  // Método para resetear datos (útil para logout)
  void resetearDatos() {
    _usuario = {
      'nombre': '',
      'email': '',
      'telefono': '',
      'direccion': '',
      'rfc': '',
      'fechaNacimiento': null,
      'genero': '',
      'ocupacion': '',
      'imagen': null,
    };
    _imagenBytes = null;
    notifyListeners();
  }
}
