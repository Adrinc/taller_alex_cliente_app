import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/main.dart';
import 'package:nethive_neo/models/configuration.dart';

const kThemeModeKey = '__theme_mode__';

void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    MyApp.of(context).setThemeMode(themeMode);

abstract class AppTheme {
  static ThemeMode get themeMode {
    final darkMode = prefs.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.light
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static LightModeTheme lightTheme = LightModeTheme();
  static DarkModeTheme darkTheme = DarkModeTheme();

  static void initConfiguration(Configuration? conf) {
    print('🎨 [AppTheme] Inicializando configuración...');
    print('🎨 [AppTheme] Configuration recibida: ${conf?.toJson()}');

    if (conf?.config != null) {
      print('🎨 [AppTheme] Config no es null, procesando...');
      print('🎨 [AppTheme] Light mode: ${conf!.config!.light?.toJson()}');
      print('🎨 [AppTheme] Dark mode: ${conf.config!.dark?.toJson()}');

      lightTheme = LightModeTheme(mode: conf.config!.light);
      darkTheme = DarkModeTheme(mode: conf.config!.dark);

      print('🎨 [AppTheme] Temas actualizados exitosamente');
      print('🎨 [AppTheme] Light primaryColor: ${lightTheme.primaryColor}');
      print('🎨 [AppTheme] Dark primaryColor: ${darkTheme.primaryColor}');
    } else {
      print(
          '⚠️ [AppTheme] Configuration o config es null, usando temas por defecto');
      lightTheme = LightModeTheme();
      darkTheme = DarkModeTheme();
    }
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? prefs.remove(kThemeModeKey)
      : prefs.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static AppTheme of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTheme : lightTheme;
  Color hexToColor(String hexString) {
    // Quita el signo de almohadilla si está presente
    hexString = hexString.toUpperCase().replaceAll("#",
        ""); // Si la cadena tiene 6 caracteres, añade el valor de opacidad completa "FF"
    if (hexString.length == 6) {
      hexString = "FF$hexString";
    } // Si la cadena tiene 8 caracteres, ya incluye la transparencia, así que se deja como está
    else if (hexString.length == 8) {
      hexString = hexString.substring(6, 8) + hexString.substring(0, 6);
    } // Añade el prefijo 0x y convierte la cadena hexadecimal a un entero
    return Color(int.parse("0x$hexString"));
  }

  abstract Color primaryColor;
  abstract Color secondaryColor;
  abstract Color tertiaryColor;
  abstract Color alternate;
  abstract Color primaryBackground;
  abstract Color secondaryBackground;
  abstract Color tertiaryBackground;
  abstract Color transparentBackground;
  abstract Color primaryText;
  abstract Color secondaryText;
  abstract Color tertiaryText;
  abstract Color hintText;
  abstract Color error;
  abstract Color warning;
  abstract Color success;
  abstract Color formBackground;

  Gradient blueGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1E40AF), // Azul profundo
      Color(0xFF3B82F6), // Azul brillante
      Color(0xFF0369A1), // Azul medio
      Color(0xFF0F172A), // Azul muy oscuro
    ],
  );

  Gradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF10B981), // Verde esmeralda
      Color(0xFF059669), // Verde intenso
      Color(0xFF0D9488), // Verde-azulado
      Color(0xFF0F172A), // Azul muy oscuro
    ],
  );

  // Nuevo gradiente para elementos modernos
  Gradient modernGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF1E40AF), // Azul profundo
      Color(0xFF3B82F6), // Azul brillante
      Color(0xFF10B981), // Verde esmeralda
      Color(0xFF7C3AED), // Púrpura
    ],
  );

  // Gradiente para backgrounds oscuros
  Gradient darkBackgroundGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF0F172A), // Azul muy oscuro
      Color(0xFF1E293B), // Azul oscuro
      Color(0xFF334155), // Azul gris
    ],
  );

  String get title1Family => typography.title1Family;
  TextStyle get title1 => typography.title1;
  String get title2Family => typography.title2Family;
  TextStyle get title2 => typography.title2;
  String get title3Family => typography.title3Family;
  TextStyle get title3 => typography.title3;
  String get subtitle1Family => typography.subtitle1Family;
  TextStyle get subtitle1 => typography.subtitle1;
  String get subtitle2Family => typography.subtitle2Family;
  TextStyle get subtitle2 => typography.subtitle2;
  String get bodyText1Family => typography.bodyText1Family;
  TextStyle get bodyText1 => typography.bodyText1;
  String get bodyText2Family => typography.bodyText2Family;
  TextStyle get bodyText2 => typography.bodyText2;
  String get bodyText3Family => typography.bodyText3Family;
  TextStyle get bodyText3 => typography.bodyText3;
  String get plutoDataTextFamily => typography.plutoDataTextFamily;
  TextStyle get plutoDataText => typography.plutoDataText;
  String get copyRightTextFamily => typography.copyRightTextFamily;
  TextStyle get copyRightText => typography.copyRightText;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  @override
  Color primaryColor = const Color(0xFF10B981); // Verde esmeralda principal
  @override
  Color secondaryColor = const Color(0xFF059669); // Verde más oscuro
  @override
  Color tertiaryColor = const Color(0xFF0D9488); // Verde azulado
  @override
  Color alternate = const Color(0xFF3B82F6); // Azul de acento
  @override
  Color primaryBackground = const Color(0xFF0F172A); // Fondo muy oscuro
  @override
  Color secondaryBackground =
      const Color(0xFF1E293B); // Fondo secundario oscuro
  @override
  Color tertiaryBackground = const Color(0xFF334155); // Fondo terciario
  @override
  Color transparentBackground =
      const Color(0xFF1E293B).withOpacity(.1); // Fondo transparente
  @override
  Color primaryText = const Color(0xFFFFFFFF); // Texto blanco
  @override
  Color secondaryText = const Color(0xFF94A3B8); // Texto gris claro
  @override
  Color tertiaryText = const Color(0xFF64748B); // Texto gris medio
  @override
  Color hintText = const Color(0xFF475569); // Texto de sugerencia
  @override
  Color error = const Color(0xFFEF4444); // Rojo para errores
  @override
  Color warning = const Color(0xFFF59E0B); // Amarillo para advertencias
  @override
  Color success = const Color(0xFF10B981); // Verde para éxito
  @override
  Color formBackground =
      const Color(0xFF10B981).withOpacity(.05); // Fondo de formularios

  LightModeTheme({Mode? mode}) {
    print(
        '🎨 [LightModeTheme] Constructor llamado con mode: ${mode?.toJson()}');

    if (mode != null) {
      print('🎨 [LightModeTheme] Aplicando colores personalizados...');
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);

      print('🎨 [LightModeTheme] Colores aplicados:');
      print('  - primaryColor: ${mode.primaryColor} -> $primaryColor');
      print('  - secondaryColor: ${mode.secondaryColor} -> $secondaryColor');
      print('  - tertiaryColor: ${mode.tertiaryColor} -> $tertiaryColor');
      print('  - primaryText: ${mode.primaryText} -> $primaryText');
      print(
          '  - primaryBackground: ${mode.primaryBackground} -> $primaryBackground');
    } else {
      print('🎨 [LightModeTheme] Mode es null, usando colores por defecto');
    }
  }
}

class DarkModeTheme extends AppTheme {
  @override
  Color primaryColor = const Color(0xFF10B981); // Verde esmeralda principal
  @override
  Color secondaryColor = const Color(0xFF059669); // Verde más oscuro
  @override
  Color tertiaryColor = const Color(0xFF0D9488); // Verde azulado
  @override
  Color alternate = const Color(0xFF3B82F6); // Azul de acento
  @override
  Color primaryBackground = const Color(0xFF0F172A); // Fondo muy oscuro
  @override
  Color secondaryBackground =
      const Color(0xFF1E293B); // Fondo secundario oscuro
  @override
  Color tertiaryBackground = const Color(0xFF334155); // Fondo terciario
  @override
  Color transparentBackground =
      const Color(0xFF1E293B).withOpacity(.3); // Fondo transparente
  @override
  Color primaryText = const Color(0xFFFFFFFF); // Texto blanco
  @override
  Color secondaryText = const Color(0xFF94A3B8); // Texto gris claro
  @override
  Color tertiaryText = const Color(0xFF64748B); // Texto gris medio
  @override
  Color hintText = const Color(0xFF475569); // Texto de sugerencia
  @override
  Color error = const Color(0xFFEF4444); // Rojo para errores
  @override
  Color warning = const Color(0xFFF59E0B); // Amarillo para advertencias
  @override
  Color success = const Color(0xFF10B981); // Verde para éxito
  @override
  Color formBackground =
      const Color(0xFF10B981).withOpacity(.1); // Fondo de formularios

  // Nuevos gradientes modernos
  @override
  LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          secondaryColor,
        ],
      );

  @override
  LinearGradient get modernGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tertiaryColor,
          primaryColor,
        ],
      );

  @override
  LinearGradient get darkBackgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryBackground,
          secondaryBackground,
        ],
      );

  DarkModeTheme({Mode? mode}) {
    print('🎨 [DarkModeTheme] Constructor llamado con mode: ${mode?.toJson()}');

    if (mode != null) {
      print('🎨 [DarkModeTheme] Aplicando colores personalizados...');
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);

      print('🎨 [DarkModeTheme] Colores aplicados:');
      print('  - primaryColor: ${mode.primaryColor} -> $primaryColor');
      print('  - secondaryColor: ${mode.secondaryColor} -> $secondaryColor');
      print('  - tertiaryColor: ${mode.tertiaryColor} -> $tertiaryColor');
      print('  - primaryText: ${mode.primaryText} -> $primaryText');
      print(
          '  - primaryBackground: ${mode.primaryBackground} -> $primaryBackground');
    } else {
      print('🎨 [DarkModeTheme] Mode es null, usando colores por defecto');
    }
  }
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    required String fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    bool useGoogleFonts = true,
    TextDecoration? decoration,
    TextDecorationStyle? decorationStyle,
    double? lineHeight,
  }) =>
      useGoogleFonts
          ? GoogleFonts.getFont(
              fontFamily,
              color: color ?? this.color,
              fontSize: fontSize ?? this.fontSize,
              fontWeight: fontWeight ?? this.fontWeight,
              fontStyle: fontStyle ?? this.fontStyle,
              letterSpacing: letterSpacing ?? this.letterSpacing,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            )
          : copyWith(
              fontFamily: fontFamily,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              fontStyle: fontStyle,
              decoration: decoration,
              decorationStyle: decorationStyle,
              height: lineHeight,
            );
}

abstract class Typography {
  String get title1Family;
  TextStyle get title1;
  String get title2Family;
  TextStyle get title2;
  String get title3Family;
  TextStyle get title3;
  String get subtitle1Family;
  TextStyle get subtitle1;
  String get subtitle2Family;
  TextStyle get subtitle2;
  String get bodyText1Family;
  TextStyle get bodyText1;
  String get bodyText2Family;
  TextStyle get bodyText2;
  String get bodyText3Family;
  TextStyle get bodyText3;
  String get plutoDataTextFamily;
  TextStyle get plutoDataText;
  String get copyRightTextFamily;
  TextStyle get copyRightText;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  @override
  String get title1Family => 'Poppins';
  @override
  TextStyle get title1 => GoogleFonts.poppins(
        fontSize: 70,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title2Family => 'Poppins';
  @override
  TextStyle get title2 => GoogleFonts.poppins(
        fontSize: 65,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get title3Family => 'Poppins';
  @override
  TextStyle get title3 => GoogleFonts.poppins(
        fontSize: 48,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );

  @override
  String get subtitle1Family => 'Poppins';
  @override
  TextStyle get subtitle1 => GoogleFonts.poppins(
        fontSize: 28,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );
  @override
  String get subtitle2Family => 'Poppins';
  @override
  TextStyle get subtitle2 => GoogleFonts.poppins(
        fontSize: 24,
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
      );

  @override
  String get bodyText1Family => 'Poppins';
  @override
  TextStyle get bodyText1 => GoogleFonts.poppins(
        fontSize: 20,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get bodyText2Family => 'Poppins';
  @override
  TextStyle get bodyText2 => GoogleFonts.poppins(
        fontSize: 18,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get bodyText3Family => 'Poppins';
  @override
  TextStyle get bodyText3 => GoogleFonts.poppins(
        fontSize: 14,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get plutoDataTextFamily => 'Poppins';
  @override
  TextStyle get plutoDataText => GoogleFonts.poppins(
        fontSize: 12,
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
      );
  @override
  String get copyRightTextFamily => 'Poppins';
  @override
  TextStyle get copyRightText => GoogleFonts.poppins(
        fontSize: 12,
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
      );
}
