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
    lightTheme = LightModeTheme(mode: conf?.config!.light);
    darkTheme = DarkModeTheme(mode: conf?.config!.dark);
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
    begin: Alignment.topCenter,
    end: Alignment(4, 0.8),
    colors: <Color>[
      Color(0xFF0090FF),
      Color(0xFF0363C8),
      Color(0xFF063E9B),
      Color(0xFF0A0859),
    ],
  );

  Gradient primaryGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment(4, 0.8),
    colors: <Color>[
      Color(0xFF6C5DD3),
      Color(0xFF090046),
      Color(0xFF05002A),
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
  Color primaryColor = const Color(0xFF663DD9);
  @override
  Color secondaryColor = const Color(0xFF12142D);
  @override
  Color tertiaryColor = const Color(0xFF14B095);
  @override
  Color alternate = const Color(0xFFFECE05);
  @override
  Color primaryBackground = const Color(0xFFFFFFFF);
  @override
  Color secondaryBackground = const Color(0xFFF9F9F9);
  @override
  Color tertiaryBackground = const Color(0XFFF1F0F0);
  @override
  Color transparentBackground = const Color(0XFF4D4D4D).withOpacity(.2);
  @override
  Color primaryText = const Color(0xFF12142D);
  @override
  Color secondaryText = const Color(0XFF000000);
  @override
  Color tertiaryText = const Color(0XFF747474);
  @override
  Color hintText = const Color(0XFF8A88A0);
  @override
  Color error = const Color(0XFFF44A49);
  @override
  Color warning = const Color(0XFFF5AB1A);
  @override
  Color success = const Color(0XFF3AC170);
  @override
  Color formBackground = const Color(0xFF663DD9).withOpacity(.2);

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
  Color primaryColor = const Color(0xFF6C5DD3);
  @override
  Color secondaryColor = const Color(0xFF098BF7);
  @override
  Color tertiaryColor = const Color(0xFF14B095);
  @override
  Color alternate = const Color(0xFFFECE05);
  @override
  Color primaryBackground = Color(0xFF292929);
  @override
  Color secondaryBackground = Color(0xFF414141);
  @override
  Color tertiaryBackground = Color(0xFF343434);
  @override
  Color transparentBackground = const Color(0XFF4D4D4D).withOpacity(.2);
  @override
  Color primaryText = Color(0xFFD7D7D7);
  @override
  Color secondaryText = Color(0xFF5C63C8);
  @override
  Color tertiaryText = const Color(0XFF747474);
  @override
  Color hintText = const Color(0XFF8A88A0);
  @override
  Color error = const Color(0XFFF44A49);
  @override
  Color warning = const Color(0XFFF5AB1A);
  @override
  Color success = const Color(0XFF3AC170);
  @override
  Color formBackground = const Color(0xFF663DD9).withOpacity(.2);

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
