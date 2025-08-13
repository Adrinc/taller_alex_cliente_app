import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/models/configuration.dart';
import 'package:nethive_neo/theme/theme.dart';

class ThemeConfigProvider extends ChangeNotifier {
  static const int organizationId = 10;

  // Estado del configurador
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Configuración actual
  Map<String, dynamic> _currentConfig = {};
  List<Map<String, dynamic>> _savedThemes = [];

  // Tracking del tema activo
  int? _currentThemeId; // ID del tema activo (null si es temporal)

  // Modo preview
  ThemeMode _previewMode = ThemeMode.light;
  bool _isPreviewActive = false;

  // Logos
  String? _lightLogoUrl;
  String? _darkLogoUrl;
  Uint8List? _lightLogoBytes;
  Uint8List? _darkLogoBytes;
  String? _lightLogoName;
  String? _darkLogoName;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  Map<String, dynamic> get currentConfig => _currentConfig;
  List<Map<String, dynamic>> get savedThemes => _savedThemes;
  ThemeMode get previewMode => _previewMode;
  bool get isPreviewActive => _isPreviewActive;
  String? get lightLogoUrl => _lightLogoUrl;
  String? get darkLogoUrl => _darkLogoUrl;
  Uint8List? get lightLogoBytes => _lightLogoBytes;
  Uint8List? get darkLogoBytes => _darkLogoBytes;
  int? get currentThemeId => _currentThemeId; // ID del tema activo

  // Configuración por defecto
  Map<String, dynamic> get defaultConfig => {
        'name': 'Tema Por Defecto',
        'light': {
          'colors': {
            'primary': '#10B981', // Verde esmeralda principal
            'secondary': '#059669', // Verde más oscuro
            'tertiary': '#0D9488', // Verde azulado
            'accent': '#3B82F6', // Azul de acento
            'primaryBackground': '#0F172A', // Fondo muy oscuro
            'secondaryBackground': '#1E293B', // Fondo secundario oscuro
            'primaryText': '#FFFFFF', // Texto blanco
            'secondaryText': '#94A3B8', // Texto gris claro
            'success': '#10B981', // Verde para éxito
            'warning': '#F59E0B', // Amarillo para advertencias
            'error': '#EF4444', // Rojo para errores
            'info': '#3B82F6', // Azul para información
          },
          'typography': {
            'fontFamily': 'Poppins',
            'fontSize': {
              'xs': 12,
              'sm': 14,
              'base': 16,
              'lg': 18,
              'xl': 20,
              '2xl': 24,
              '3xl': 30,
              '4xl': 36,
            }
          },
          'logo': null,
          'iconStyle': 'material',
        },
        'dark': {
          'colors': {
            'primary': '#10B981', // Verde esmeralda principal
            'secondary': '#059669', // Verde más oscuro
            'tertiary': '#0D9488', // Verde azulado
            'accent': '#3B82F6', // Azul de acento
            'primaryBackground': '#0F172A', // Fondo muy oscuro
            'secondaryBackground': '#1E293B', // Fondo secundario oscuro
            'primaryText': '#FFFFFF', // Texto blanco
            'secondaryText': '#94A3B8', // Texto gris claro
            'success': '#10B981', // Verde para éxito
            'warning': '#F59E0B', // Amarillo para advertencias
            'error': '#EF4444', // Rojo para errores
            'info': '#3B82F6', // Azul para información
          },
          'typography': {
            'fontFamily': 'Poppins',
            'fontSize': {
              'xs': 12,
              'sm': 14,
              'base': 16,
              'lg': 18,
              'xl': 20,
              '2xl': 24,
              '3xl': 30,
              '4xl': 36,
            }
          },
          'logo': null,
          'iconStyle': 'material',
        }
      };

  // Fuentes disponibles
  List<String> get availableFonts => [
        'Poppins',
        'Roboto',
        'Inter',
        'Montserrat',
        'Open Sans',
        'Lato',
        'Source Sans Pro',
        'Nunito',
        'Raleway',
        'Ubuntu',
      ];

  // Estilos de iconos disponibles
  List<Map<String, dynamic>> get iconStyles => [
        {'id': 'material', 'name': 'Material Design', 'icon': Icons.android},
        {'id': 'cupertino', 'name': 'Cupertino (iOS)', 'icon': Icons.apple},
        {'id': 'rounded', 'name': 'Redondeados', 'icon': Icons.circle_outlined},
        {'id': 'sharp', 'name': 'Afilados', 'icon': Icons.crop_square},
      ];

  ThemeConfigProvider() {
    _initializeConfig();
  }

  void _initializeConfig() {
    _currentConfig = Map<String, dynamic>.from(defaultConfig);
    notifyListeners(); // Notificar que la configuración por defecto está lista
    loadSavedThemes();
    // No cargar tema del usuario automáticamente en la inicialización
    // Se cargará cuando el usuario inicie sesión
  }

  // Método público para recargar el tema después del login
  Future<void> reloadUserTheme() async {
    await loadCurrentTheme();
  }

  // Cargar configuración actual desde Supabase
  Future<void> loadCurrentTheme() async {
    _setLoading(true);
    try {
      // Obtener el tema del usuario usando el nuevo flujo
      final userTheme = await SupabaseQueries.getUserTheme();

      if (userTheme?.config != null) {
        // Convertir Configuration a Map<String, dynamic> para el provider
        final config = userTheme!.config!;

        _currentConfig = {
          'name': 'Tema del Usuario',
          'light': {
            'colors': _extractColors(config.light),
            'typography': _extractTypography(config.light),
            'logo': config.logos?.logoColor,
            'iconStyle': 'material',
          },
          'dark': {
            'colors': _extractColors(config.dark),
            'typography': _extractTypography(config.dark),
            'logo': config.logos?.logoBlanco,
            'iconStyle': 'material',
          },
        };

        await _loadLogos();
        log('Tema del usuario cargado exitosamente en ThemeConfigProvider');

        // ¡IMPORTANTE! Aplicar la configuración al AppTheme
        AppTheme.initConfiguration(userTheme);
      } else {
        log('No se pudo cargar el tema del usuario, usando configuración por defecto');
        _currentConfig = Map<String, dynamic>.from(defaultConfig);
      }
    } catch (e) {
      log('Error loading current theme: $e');
      // Si no existe configuración, mantener la por defecto
      _currentConfig = Map<String, dynamic>.from(defaultConfig);
    } finally {
      _setLoading(false);
    }
  } // Cargar logos desde storage

  Future<void> _loadLogos() async {
    try {
      final lightLogo = _currentConfig['light']?['logo'];
      final darkLogo = _currentConfig['dark']?['logo'];

      if (lightLogo != null) {
        _lightLogoUrl = supabase.storage
            .from('nethive')
            .getPublicUrl('configurador/logos/$lightLogo');
      }

      if (darkLogo != null) {
        _darkLogoUrl = supabase.storage
            .from('nethive')
            .getPublicUrl('configurador/logos/$darkLogo');
      }
    } catch (e) {
      log('Error loading logos: $e');
    }
  }

  // Cargar temas guardados
  Future<void> loadSavedThemes() async {
    try {
      final response = await supabase
          .from('theme')
          .select('id, name, config, created_at')
          .eq('organization_fk', organizationId)
          .order('created_at', ascending: false);

      _savedThemes = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error loading saved themes: $e');
      _setError('Error al cargar temas guardados');
    }
    notifyListeners();
  }

  // Actualizar color
  void updateColor(String mode, String colorKey, Color color) {
    if (_currentConfig[mode] == null) _currentConfig[mode] = {};
    if (_currentConfig[mode]['colors'] == null)
      _currentConfig[mode]['colors'] = {};

    _currentConfig[mode]['colors'][colorKey] =
        '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

    // Al modificar, se convierte en tema temporal
    _currentThemeId = null;

    notifyListeners();
  } // Actualizar fuente

  void updateFont(String mode, String fontFamily) {
    if (_currentConfig[mode] == null) _currentConfig[mode] = {};
    if (_currentConfig[mode]['typography'] == null)
      _currentConfig[mode]['typography'] = {};

    _currentConfig[mode]['typography']['fontFamily'] = fontFamily;

    // Al modificar, se convierte en tema temporal
    _currentThemeId = null;

    notifyListeners();
  }

  // Actualizar estilo de iconos
  void updateIconStyle(String mode, String iconStyle) {
    if (_currentConfig[mode] == null) _currentConfig[mode] = {};
    _currentConfig[mode]['iconStyle'] = iconStyle;

    // Al modificar, se convierte en tema temporal
    _currentThemeId = null;

    notifyListeners();
  }

  // Seleccionar logo
  Future<void> selectLogo(String mode) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final fileName =
              'logo_${mode}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';

          if (mode == 'light') {
            _lightLogoBytes = file.bytes;
            _lightLogoName = fileName;
          } else {
            _darkLogoBytes = file.bytes;
            _darkLogoName = fileName;
          }

          notifyListeners();
        }
      }
    } catch (e) {
      log('Error selecting logo: $e');
      _setError('Error al seleccionar logo');
    }
  }

  // Subir logo a storage
  Future<String?> _uploadLogo(String mode) async {
    try {
      Uint8List? logoBytes;
      String? logoName;

      if (mode == 'light') {
        logoBytes = _lightLogoBytes;
        logoName = _lightLogoName;
      } else {
        logoBytes = _darkLogoBytes;
        logoName = _darkLogoName;
      }

      if (logoBytes != null && logoName != null) {
        await supabase.storage
            .from('nethive')
            .uploadBinary('configurador/logos/$logoName', logoBytes);

        return logoName;
      }
    } catch (e) {
      log('Error uploading logo: $e');
      _setError('Error al subir logo');
    }
    return null;
  }

  // Guardar tema
  Future<bool> saveTheme(String themeName) async {
    _setSaving(true);
    try {
      // Subir logos si hay nuevos
      if (_lightLogoBytes != null) {
        final lightLogoPath = await _uploadLogo('light');
        if (lightLogoPath != null) {
          _currentConfig['light']['logo'] = lightLogoPath;
        }
      }

      if (_darkLogoBytes != null) {
        final darkLogoPath = await _uploadLogo('dark');
        if (darkLogoPath != null) {
          _currentConfig['dark']['logo'] = darkLogoPath;
        }
      }

      // Actualizar nombre del tema
      _currentConfig['name'] = themeName;

      // Convertir al formato antiguo antes de guardar
      final configToSave = _convertToOldFormat(_currentConfig);
      print(
          '🎨 [saveTheme] Guardando configuración en formato antiguo: $configToSave');

      // Guardar en Supabase
      await supabase.from('theme').upsert({
        'organization_fk': organizationId,
        'name': themeName,
        'config': configToSave,
      });

      // Limpiar logos temporales
      _lightLogoBytes = null;
      _darkLogoBytes = null;
      _lightLogoName = null;
      _darkLogoName = null;

      await loadSavedThemes();
      await _loadLogos();

      return true;
    } catch (e) {
      log('Error saving theme: $e');
      _setError('Error al guardar tema');
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // Cargar tema guardado
  Future<void> loadTheme(int themeId) async {
    _setLoading(true);
    try {
      final theme = _savedThemes.firstWhere((theme) => theme['id'] == themeId);
      _currentConfig = Map<String, dynamic>.from(theme['config']);
      _currentThemeId = themeId; // Trackear el tema activo
      await _loadLogos();

      // Aplicar automáticamente el tema cargado
      await _updateGlobalTheme();
    } catch (e) {
      log('Error loading theme: $e');
      _setError('Error al cargar tema');
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar tema
  Future<bool> deleteTheme(int themeId) async {
    try {
      // Primero obtener la información del tema para extraer los logos
      final theme = _savedThemes.firstWhere((theme) => theme['id'] == themeId);
      final config = theme['config'] as Map<String, dynamic>;

      // Obtener nombres de archivos de logos
      final lightLogo = config['light']?['logo'];
      final darkLogo = config['dark']?['logo'];

      // Eliminar logos del storage si existen
      if (lightLogo != null) {
        try {
          await supabase.storage
              .from('nethive')
              .remove(['configurador/logos/$lightLogo']);
          log('Light logo deleted: $lightLogo');
        } catch (e) {
          log('Error deleting light logo: $e');
          // Continuar aunque falle la eliminación del logo
        }
      }

      if (darkLogo != null) {
        try {
          await supabase.storage
              .from('nethive')
              .remove(['configurador/logos/$darkLogo']);
          log('Dark logo deleted: $darkLogo');
        } catch (e) {
          log('Error deleting dark logo: $e');
          // Continuar aunque falle la eliminación del logo
        }
      }

      // Eliminar el registro del tema de la base de datos
      await supabase.from('theme').delete().eq('id', themeId);

      // Recargar la lista de temas
      await loadSavedThemes();

      return true;
    } catch (e) {
      log('Error deleting theme: $e');
      _setError('Error al eliminar tema');
      return false;
    }
  }

  // Aplicar tema al sistema
  Future<void> applyTheme() async {
    try {
      if (_currentThemeId != null) {
        // Es un tema guardado - actualizar user_profile.theme_fk
        await _updateUserTheme(_currentThemeId!);
      } else {
        // Es un tema temporal - solo aplicar visualmente
        await _updateGlobalTheme();
      }

      // Forzar notificación para asegurar que todos los widgets se actualicen
      notifyListeners();
    } catch (e) {
      log('Error applying theme: $e');
      _setError('Error al aplicar tema');
      notifyListeners(); // También notificar en caso de error
    }
  }

  // Actualizar el theme_fk del usuario en user_profile
  Future<void> _updateUserTheme(int themeId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      await supabase
          .from('user_profile')
          .update({'theme_fk': themeId})
          .eq('user_profile_id', user.id)
          .eq('organization_fk', organizationId);

      // También aplicar el tema visualmente
      await _updateGlobalTheme();

      log('Theme applied to user successfully - ID: $themeId');
    } catch (e) {
      log('Error updating user theme: $e');
      throw e;
    }
  }

  // Método para actualizar el tema global de la aplicación
  Future<void> _updateGlobalTheme() async {
    try {
      // Importar las clases necesarias
      final Configuration configuration = _convertToConfiguration();

      // Actualizar AppTheme
      AppTheme.initConfiguration(configuration);

      // Notificar a todos los widgets que el tema ha cambiado
      notifyListeners();

      log('Global theme updated successfully');
    } catch (e) {
      log('Error updating global theme: $e');
    }
  }

  // Convertir la configuración actual al formato Configuration
  Configuration _convertToConfiguration() {
    final lightColors = _currentConfig['light']?['colors'] ?? {};
    final darkColors = _currentConfig['dark']?['colors'] ?? {};

    return Configuration(
      config: Config(
        light: Mode(
          primaryColor: lightColors['primary'],
          secondaryColor: lightColors['secondary'],
          tertiaryColor: lightColors['tertiary'],
          alternate: lightColors['accent'],
          primaryBackground: lightColors['primaryBackground'],
          secondaryBackground: lightColors['secondaryBackground'],
          primaryText: lightColors['primaryText'],
          secondaryText: lightColors['secondaryText'],
          tertiaryText:
              lightColors['secondaryText'], // Usar secondaryText como fallback
          hintText:
              lightColors['secondaryText'], // Usar secondaryText como fallback
          tertiaryBackground: lightColors[
              'secondaryBackground'], // Usar secondaryBackground como fallback
        ),
        dark: Mode(
          primaryColor: darkColors['primary'],
          secondaryColor: darkColors['secondary'],
          tertiaryColor: darkColors['tertiary'],
          alternate: darkColors['accent'],
          primaryBackground: darkColors['primaryBackground'],
          secondaryBackground: darkColors['secondaryBackground'],
          primaryText: darkColors['primaryText'],
          secondaryText: darkColors['secondaryText'],
          tertiaryText:
              darkColors['secondaryText'], // Usar secondaryText como fallback
          hintText:
              darkColors['secondaryText'], // Usar secondaryText como fallback
          tertiaryBackground: darkColors[
              'secondaryBackground'], // Usar secondaryBackground como fallback
        ),
        logos: Logos(
          logoColor: _currentConfig['light']?['logo'],
          logoBlanco: _currentConfig['dark']?['logo'],
        ),
      ),
    );
  }

  // Preview
  void setPreviewMode(ThemeMode mode) {
    _previewMode = mode;
    notifyListeners();
  }

  void togglePreview() {
    _isPreviewActive = !_isPreviewActive;
    notifyListeners();
  }

  // Export/Import
  String exportTheme() {
    return jsonEncode(_currentConfig);
  }

  void importTheme(String jsonData) {
    try {
      final imported = jsonDecode(jsonData);
      _currentConfig = Map<String, dynamic>.from(imported);
      notifyListeners();
    } catch (e) {
      _setError('Error al importar tema: formato inválido');
    }
  }

  // Resetear a configuración por defecto
  void resetToDefault() {
    _currentConfig = Map<String, dynamic>.from(defaultConfig);
    _lightLogoBytes = null;
    _darkLogoBytes = null;
    _lightLogoName = null;
    _darkLogoName = null;
    _lightLogoUrl = null;
    _darkLogoUrl = null;
    notifyListeners();
  }

  // Obtener color como Color object
  Color getColor(String mode, String colorKey) {
    final colorHex = _currentConfig[mode]?['colors']?[colorKey];
    if (colorHex != null && colorHex is String) {
      log('getColor($mode, $colorKey): Found $colorHex');
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    }

    // Si no se encuentra el color, usar el color por defecto del defaultConfig
    final defaultColorHex = defaultConfig[mode]?['colors']?[colorKey];
    if (defaultColorHex != null && defaultColorHex is String) {
      log('getColor($mode, $colorKey): Using default $defaultColorHex');
      return Color(int.parse(defaultColorHex.replaceFirst('#', '0xFF')));
    }

    log('getColor($mode, $colorKey): Using fallback blue');
    return Colors.blue; // Último recurso
  }

  // Obtener fuente
  String getFont(String mode) {
    return _currentConfig[mode]?['typography']?['fontFamily'] ?? 'Poppins';
  }

  // Obtener estilo de iconos
  String getIconStyle(String mode) {
    return _currentConfig[mode]?['iconStyle'] ?? 'material';
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    if (saving) _error = null;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos auxiliares para convertir Configuration a Map
  Map<String, String?> _extractColors(Mode? mode) {
    if (mode == null) {
      return {};
    }

    final colors = {
      'primary': mode.primaryColor,
      'secondary': mode.secondaryColor,
      'tertiary': mode.tertiaryColor,
      'primaryBackground': mode.primaryBackground,
      'secondaryBackground': mode.secondaryBackground,
      'tertiaryBackground': mode.tertiaryBackground,
      'primaryText': mode.primaryText,
      'secondaryText': mode.secondaryText,
      'tertiaryText': mode.tertiaryText,
      'alternate': mode.alternate,
      'hintText': mode.hintText,
    };

    return colors;
  }

  Map<String, String?> _extractTypography(Mode? mode) {
    // Para tipografía, usando colores de texto como base
    if (mode == null) {
      return {};
    }

    final typography = {
      'headingFamily': 'Poppins',
      'bodyFamily': 'Poppins',
      'headingColor': mode.primaryText,
      'bodyColor': mode.secondaryText,
    };

    return typography;
  }

  /// Convierte del formato del provider (nuevo) al formato antiguo para guardar en BD
  Map<String, dynamic> _convertToOldFormat(Map<String, dynamic> currentConfig) {
    final converted = <String, dynamic>{};

    // Convertir light mode
    if (currentConfig['light'] != null) {
      final lightSection = currentConfig['light'] as Map<String, dynamic>;
      final lightColors = lightSection['colors'] as Map<String, dynamic>?;

      converted['light'] = <String, dynamic>{};

      if (lightColors != null) {
        converted['light']['primaryColor'] = lightColors['primary'];
        converted['light']['secondaryColor'] = lightColors['secondary'];
        converted['light']['tertiaryColor'] = lightColors['tertiary'];
        converted['light']['primaryText'] = lightColors['primaryText'];
        converted['light']['secondaryText'] = lightColors['secondaryText'];
        converted['light']['tertiaryText'] = lightColors['tertiaryText'];
        converted['light']['primaryBackground'] =
            lightColors['primaryBackground'];
        converted['light']['secondaryBackground'] =
            lightColors['secondaryBackground'];
        converted['light']['tertiaryBackground'] =
            lightColors['tertiaryBackground'];
        converted['light']['alternate'] = lightColors['alternate'];
        converted['light']['hintText'] = lightColors['hintText'];
      }
    }

    // Convertir dark mode
    if (currentConfig['dark'] != null) {
      final darkSection = currentConfig['dark'] as Map<String, dynamic>;
      final darkColors = darkSection['colors'] as Map<String, dynamic>?;

      converted['dark'] = <String, dynamic>{};

      if (darkColors != null) {
        converted['dark']['primaryColor'] = darkColors['primary'];
        converted['dark']['secondaryColor'] = darkColors['secondary'];
        converted['dark']['tertiaryColor'] = darkColors['tertiary'];
        converted['dark']['primaryText'] = darkColors['primaryText'];
        converted['dark']['secondaryText'] = darkColors['secondaryText'];
        converted['dark']['tertiaryText'] = darkColors['tertiaryText'];
        converted['dark']['primaryBackground'] =
            darkColors['primaryBackground'];
        converted['dark']['secondaryBackground'] =
            darkColors['secondaryBackground'];
        converted['dark']['tertiaryBackground'] =
            darkColors['tertiaryBackground'];
        converted['dark']['alternate'] = darkColors['alternate'];
        converted['dark']['hintText'] = darkColors['hintText'];
      }
    }

    // Agregar logos
    converted['logos'] = <String, dynamic>{};
    if (currentConfig['light'] != null &&
        currentConfig['light']['logo'] != null) {
      converted['logos']['logoColor'] = currentConfig['light']['logo'];
    }
    if (currentConfig['dark'] != null &&
        currentConfig['dark']['logo'] != null) {
      converted['logos']['logoBlanco'] = currentConfig['dark']['logo'];
    }

    return converted;
  }
}
