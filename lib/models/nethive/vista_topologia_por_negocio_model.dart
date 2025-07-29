import 'dart:convert';

class VistaTopologiaPorNegocio {
  final String negocioId;
  final String nombreNegocio;
  final String? distribucionId;
  final String? tipoDistribucion;
  final String? distribucionNombre;
  final String componenteId;
  final String componenteNombre;
  final String? descripcion;
  final String categoriaComponente;
  final bool enUso;
  final bool activo;
  final String? ubicacion;
  final String? imagenUrl;
  final DateTime fechaRegistro;

  VistaTopologiaPorNegocio({
    required this.negocioId,
    required this.nombreNegocio,
    this.distribucionId,
    this.tipoDistribucion,
    this.distribucionNombre,
    required this.componenteId,
    required this.componenteNombre,
    this.descripcion,
    required this.categoriaComponente,
    required this.enUso,
    required this.activo,
    this.ubicacion,
    this.imagenUrl,
    required this.fechaRegistro,
  });

  factory VistaTopologiaPorNegocio.fromMap(Map<String, dynamic> map) {
    return VistaTopologiaPorNegocio(
      negocioId: map['negocio_id']?.toString() ?? '',
      nombreNegocio: map['nombre_negocio']?.toString() ?? '',
      distribucionId: map['distribucion_id']?.toString(),
      tipoDistribucion: map['tipo_distribucion']?.toString(),
      distribucionNombre: map['distribucion_nombre']?.toString(),
      componenteId: map['componente_id']?.toString() ?? '',
      componenteNombre: map['componente_nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString(),
      categoriaComponente: map['categoria_componente']?.toString() ?? '',
      enUso: map['en_uso'] == true,
      activo: map['activo'] == true,
      ubicacion: map['ubicacion']?.toString(),
      imagenUrl: map['imagen_url']?.toString(),
      fechaRegistro:
          DateTime.tryParse(map['fecha_registro']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'negocio_id': negocioId,
      'nombre_negocio': nombreNegocio,
      'distribucion_id': distribucionId,
      'tipo_distribucion': tipoDistribucion,
      'distribucion_nombre': distribucionNombre,
      'componente_id': componenteId,
      'componente_nombre': componenteNombre,
      'descripcion': descripcion,
      'categoria_componente': categoriaComponente,
      'en_uso': enUso,
      'activo': activo,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  factory VistaTopologiaPorNegocio.fromJson(String source) =>
      VistaTopologiaPorNegocio.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  // Método para obtener el tipo de componente principal basado en IDs
  String get tipoComponentePrincipal {
    final categoria = categoriaComponente.toLowerCase();

    // Clasificación basada en los nombres de categorías exactos
    if (categoria == 'cable') return 'cable';
    if (categoria == 'switch') return 'switch';
    if (categoria == 'patch panel') return 'patch_panel';
    if (categoria == 'rack') return 'rack';
    if (categoria == 'ups') return 'ups';
    if (categoria == 'mdf') return 'mdf';
    if (categoria == 'idf') return 'idf';

    // Clasificación por contenido para compatibilidad
    if (categoria.contains('switch')) return 'switch';
    if (categoria.contains('router') || categoria.contains('firewall'))
      return 'router';
    if (categoria.contains('servidor') || categoria.contains('server'))
      return 'servidor';
    if (categoria.contains('cable')) return 'cable';
    if (categoria.contains('patch') || categoria.contains('panel'))
      return 'patch_panel';
    if (categoria.contains('rack')) return 'rack';
    if (categoria.contains('ups')) return 'ups';
    if (categoria.contains('organizador')) return 'organizador';

    return 'otro';
  }

  // Método mejorado para determinar si es MDF
  bool get esMDF {
    final categoria = categoriaComponente.toLowerCase();
    return categoria == 'mdf' ||
        tipoDistribucion?.toUpperCase() == 'MDF' ||
        ubicacion?.toLowerCase().contains('mdf') == true;
  }

  // Método mejorado para determinar si es IDF
  bool get esIDF {
    final categoria = categoriaComponente.toLowerCase();
    return categoria == 'idf' ||
        tipoDistribucion?.toUpperCase() == 'IDF' ||
        ubicacion?.toLowerCase().contains('idf') == true;
  }

  // Método para obtener el nivel de prioridad del componente (para ordenamiento en topología)
  int get prioridadTopologia {
    if (esMDF) return 1; // Máxima prioridad para MDF
    if (esIDF) return 2; // Segunda prioridad para IDF

    switch (tipoComponentePrincipal) {
      case 'router':
        return 3;
      case 'switch':
        return 4;
      case 'servidor':
        return 5;
      case 'patch_panel':
        return 6;
      case 'rack':
        return 7;
      case 'ups':
        return 8;
      case 'cable':
        return 9;
      case 'organizador':
        return 10;
      default:
        return 11;
    }
  }

  // Método para determinar el color del componente en el diagrama
  String getColorForDiagram() {
    if (esMDF) return '#2196F3'; // Azul para MDF
    if (esIDF) {
      return enUso
          ? '#4CAF50'
          : '#FF9800'; // Verde si está en uso, naranja si no
    }

    switch (tipoComponentePrincipal) {
      case 'router':
        return '#FF5722'; // Naranja rojizo
      case 'switch':
        return '#9C27B0'; // Morado
      case 'servidor':
        return '#E91E63'; // Rosa
      case 'patch_panel':
        return '#607D8B'; // Azul gris
      case 'rack':
        return '#795548'; // Marrón
      case 'ups':
        return '#FFC107'; // Ámbar
      case 'cable':
        return '#4CAF50'; // Verde
      case 'organizador':
        return '#9E9E9E'; // Gris
      default:
        return activo ? '#2196F3' : '#757575';
    }
  }
}
