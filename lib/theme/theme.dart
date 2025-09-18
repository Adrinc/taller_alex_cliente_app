import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/configuration.dart';

// Colores Taller Alex - Paleta Fucsia/Rosa Neumórfica
class TallerAlexColors {
  // Colores principales
  static const Color primaryFuchsia = Color(0xFFE91E63); // Fucsia vibrante
  static const Color primaryRose = Color(0xFFF06292); // Rosa medio
  static const Color lightRose = Color(0xFFF8BBD9); // Rosa claro
  static const Color paleRose = Color(0xFFFCE4EC); // Rosa muy claro

  // Backgrounds neumórficos
  static const Color neumorphicBase = Color(0xFFF5F5F5); // Gris muy claro
  static const Color neumorphicSurface = Color(0xFFFFFFFF); // Blanco puro
  static const Color neumorphicBackground =
      Color(0xFFF8F9FA); // Casi blanco con tinte

  // Sombras neumórficas
  static const Color shadowDark = Color(0xFFD1D9E6); // Sombra oscura suave
  static const Color shadowLight =
      Color(0xFFFFFFFF); // Sombra clara (highlight)

  // Gradientes fucsia
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryFuchsia, primaryRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [lightRose, paleRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Colores de texto
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7B8794);
  static const Color textLight = Color(0xFFB0B7C3);
}

const kThemeModeKey = '__theme_mode__';

// TODO: Implement mobile theme switching
void setDarkModeSetting(BuildContext context, ThemeMode themeMode) {
  // Implementation for mobile theme switching
}

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
    if (conf?.config != null) {
      lightTheme = LightModeTheme(mode: conf!.config!.light);
      darkTheme = DarkModeTheme(mode: conf.config!.dark);
    } else {
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

  // Gradientes Taller Alex - Fucsia
  Gradient blueGradient =
      TallerAlexColors.primaryGradient; // Gradiente fucsia principal

  Gradient primaryGradient =
      TallerAlexColors.primaryGradient; // Gradiente fucsia principal

  // Gradiente suave para backgrounds
  Gradient modernGradient =
      TallerAlexColors.softGradient; // Gradiente fucsia suave

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
  Color primaryColor = TallerAlexColors.primaryFuchsia; // Fucsia principal
  @override
  Color secondaryColor = TallerAlexColors.primaryRose; // Rosa secundario
  @override
  Color tertiaryColor = TallerAlexColors.lightRose; // Rosa claro
  @override
  Color alternate = TallerAlexColors.paleRose; // Rosa muy claro
  @override
  Color primaryBackground =
      TallerAlexColors.neumorphicBackground; // Fondo neumórfico
  @override
  Color secondaryBackground =
      TallerAlexColors.neumorphicSurface; // Superficie blanca
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
    if (mode != null) {
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);
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
    if (mode != null) {
      primaryColor = hexToColor(mode.primaryColor!);
      secondaryColor = hexToColor(mode.secondaryColor!);
      tertiaryColor = hexToColor(mode.tertiaryColor!);
      primaryText = hexToColor(mode.primaryText!);
      primaryBackground = hexToColor(mode.primaryBackground!);
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

// Componentes Neumórficos de Taller Alex
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double depth;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.depth = 4,
    this.backgroundColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? TallerAlexColors.neumorphicSurface;

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Sombra oscura (abajo y derecha)
          BoxShadow(
            color: TallerAlexColors.shadowDark.withOpacity(0.3),
            offset: Offset(depth.abs(), depth.abs()),
            blurRadius: (depth * 2).abs(),
          ),
          // Sombra clara (arriba y izquierda)
          BoxShadow(
            color: TallerAlexColors.shadowLight,
            offset: Offset(-depth.abs() / 2, -depth.abs() / 2),
            blurRadius: depth.abs(),
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final double depth;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 16,
    this.depth = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        margin: margin,
        padding: padding,
        borderRadius: borderRadius,
        depth: depth,
        child: child,
      ),
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final bool isPressed;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = 12,
    this.backgroundColor,
    this.isPressed = false,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPressed = widget.isPressed || _isPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? TallerAlexColors.neumorphicSurface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isPressed
              ? [
                  // Sombras más suaves cuando está presionado
                  BoxShadow(
                    color: TallerAlexColors.shadowDark.withOpacity(0.1),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ]
              : [
                  // Sombras normales
                  BoxShadow(
                    color: TallerAlexColors.shadowDark.withOpacity(0.3),
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: TallerAlexColors.shadowLight,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
