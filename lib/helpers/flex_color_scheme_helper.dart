import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Helper class para integrar FlexColorScheme con nuestro sistema de temas
class FlexColorSchemeHelper {
  static final Random _random = Random();

  /// Lista de todos los esquemas predefinidos disponibles
  static final List<FlexScheme> availableSchemes = [
    FlexScheme.material,
    FlexScheme.materialHc,
    FlexScheme.blue,
    FlexScheme.indigo,
    FlexScheme.hippieBlue,
    FlexScheme.aquaBlue,
    FlexScheme.brandBlue,
    FlexScheme.deepBlue,
    FlexScheme.sakura,
    FlexScheme.mandyRed,
    FlexScheme.red,
    FlexScheme.redWine,
    FlexScheme.purpleBrown,
    FlexScheme.green,
    FlexScheme.money,
    FlexScheme.jungle,
    FlexScheme.greyLaw,
    FlexScheme.wasabi,
    FlexScheme.gold,
    FlexScheme.mango,
    FlexScheme.amber,
    FlexScheme.vesuviusBurn,
    FlexScheme.deepPurple,
    FlexScheme.ebonyClay,
    FlexScheme.barossa,
    FlexScheme.shark,
    FlexScheme.bigStone,
    FlexScheme.damask,
    FlexScheme.bahamaBlue,
    FlexScheme.mallardGreen,
    FlexScheme.espresso,
    FlexScheme.outerSpace,
    FlexScheme.blueWhale,
    FlexScheme.sanJuanBlue,
    FlexScheme.rosewood,
    FlexScheme.blumineBlue,
    FlexScheme.flutterDash,
    FlexScheme.materialBaseline,
    FlexScheme.verdunHemlock,
    FlexScheme.dellGenoa,
  ];

  /// Genera un tema aleatorio usando FlexColorScheme
  static ThemeData generateRandomTheme({
    required bool isDark,
    FlexSurfaceMode? surfaceMode,
    FlexAppBarStyle? appBarStyle,
  }) {
    // Seleccionar un esquema aleatorio
    final randomScheme =
        availableSchemes[_random.nextInt(availableSchemes.length)];

    // Configuración base
    final flexScheme = isDark
        ? FlexThemeData.dark(
            scheme: randomScheme,
            surfaceMode:
                surfaceMode ?? FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: _random.nextInt(20) + 5, // 5-24
            appBarStyle: appBarStyle ?? FlexAppBarStyle.background,
            appBarOpacity: 0.95,
            transparentStatusBar: true,
            tabBarStyle: FlexTabBarStyle.forAppBar,
            tooltipsMatchBackground: true,
            swapLegacyOnMaterial3: true,
            useMaterial3: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          )
        : FlexThemeData.light(
            scheme: randomScheme,
            surfaceMode:
                surfaceMode ?? FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: _random.nextInt(15) + 3, // 3-17
            appBarStyle: appBarStyle ?? FlexAppBarStyle.primary,
            appBarOpacity: 0.95,
            transparentStatusBar: true,
            tabBarStyle: FlexTabBarStyle.forAppBar,
            tooltipsMatchBackground: true,
            swapLegacyOnMaterial3: true,
            useMaterial3: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          );

    return flexScheme;
  }

  /// Crea un tema desde un esquema específico
  static ThemeData createThemeFromScheme({
    required FlexScheme scheme,
    required bool isDark,
    FlexSurfaceMode? surfaceMode,
    FlexAppBarStyle? appBarStyle,
    int? blendLevel,
  }) {
    return isDark
        ? FlexThemeData.dark(
            scheme: scheme,
            surfaceMode:
                surfaceMode ?? FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: blendLevel ?? 12,
            appBarStyle: appBarStyle ?? FlexAppBarStyle.background,
            appBarOpacity: 0.95,
            transparentStatusBar: true,
            tabBarStyle: FlexTabBarStyle.forAppBar,
            tooltipsMatchBackground: true,
            swapLegacyOnMaterial3: true,
            useMaterial3: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          )
        : FlexThemeData.light(
            scheme: scheme,
            surfaceMode:
                surfaceMode ?? FlexSurfaceMode.levelSurfacesLowScaffold,
            blendLevel: blendLevel ?? 8,
            appBarStyle: appBarStyle ?? FlexAppBarStyle.primary,
            appBarOpacity: 0.95,
            transparentStatusBar: true,
            tabBarStyle: FlexTabBarStyle.forAppBar,
            tooltipsMatchBackground: true,
            swapLegacyOnMaterial3: true,
            useMaterial3: true,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
          );
  }

  /// Obtiene el nombre legible de un esquema
  static String getSchemeDisplayName(FlexScheme scheme) {
    switch (scheme) {
      case FlexScheme.material:
        return 'Material Design';
      case FlexScheme.materialHc:
        return 'Material High Contrast';
      case FlexScheme.blue:
        return 'Blue Delight';
      case FlexScheme.indigo:
        return 'Indigo Nights';
      case FlexScheme.hippieBlue:
        return 'Hippie Blue';
      case FlexScheme.aquaBlue:
        return 'Aqua Blue';
      case FlexScheme.brandBlue:
        return 'Brand Blue';
      case FlexScheme.deepBlue:
        return 'Deep Blue Sea';
      case FlexScheme.sakura:
        return 'Pink Sakura';
      case FlexScheme.mandyRed:
        return 'Oh Mandy Red';
      case FlexScheme.red:
        return 'Red Tornado';
      case FlexScheme.redWine:
        return 'Red Wine';
      case FlexScheme.purpleBrown:
        return 'Purple Brown';
      case FlexScheme.green:
        return 'Green Forest';
      case FlexScheme.money:
        return 'Green Money';
      case FlexScheme.jungle:
        return 'Green Jungle';
      case FlexScheme.greyLaw:
        return 'Grey Law';
      case FlexScheme.wasabi:
        return 'Wasabi Green';
      case FlexScheme.gold:
        return 'Gold Sunset';
      case FlexScheme.mango:
        return 'Mango Mojito';
      case FlexScheme.amber:
        return 'Amber Blue';
      case FlexScheme.vesuviusBurn:
        return 'Vesuvius Burned';
      case FlexScheme.deepPurple:
        return 'Deep Purple';
      case FlexScheme.ebonyClay:
        return 'Ebony Clay';
      case FlexScheme.barossa:
        return 'Barossa';
      case FlexScheme.shark:
        return 'Shark Grey';
      case FlexScheme.bigStone:
        return 'Big Stone';
      case FlexScheme.damask:
        return 'Damask';
      case FlexScheme.bahamaBlue:
        return 'Bahama Blue';
      case FlexScheme.mallardGreen:
        return 'Mallard Green';
      case FlexScheme.espresso:
        return 'Espresso';
      case FlexScheme.outerSpace:
        return 'Outer Space';
      case FlexScheme.blueWhale:
        return 'Blue Whale';
      case FlexScheme.sanJuanBlue:
        return 'San Juan Blue';
      case FlexScheme.rosewood:
        return 'Rosewood';
      case FlexScheme.blumineBlue:
        return 'Blumine Blue';
      case FlexScheme.flutterDash:
        return 'Flutter Dash';
      case FlexScheme.materialBaseline:
        return 'Material Baseline';
      case FlexScheme.verdunHemlock:
        return 'Verdun Hemlock';
      case FlexScheme.dellGenoa:
        return 'Dell Genoa Green';
      default:
        return 'Unknown Scheme';
    }
  }

  /// Convierte FlexScheme a Map para serialización
  static Map<String, dynamic> schemeToMap(FlexScheme scheme) {
    return {
      'flexScheme': scheme.index,
      'schemeName': getSchemeDisplayName(scheme),
    };
  }

  /// Convierte Map a FlexScheme para deserialización
  static FlexScheme? schemeFromMap(Map<String, dynamic> map) {
    final index = map['flexScheme'] as int?;
    if (index != null && index >= 0 && index < availableSchemes.length) {
      return availableSchemes[index];
    }
    return null;
  }

  /// Obtiene colores principales de un esquema para preview
  static Map<String, Color> getSchemeColors(FlexScheme scheme, bool isDark) {
    final themeData = isDark
        ? FlexThemeData.dark(scheme: scheme, useMaterial3: true)
        : FlexThemeData.light(scheme: scheme, useMaterial3: true);

    final colorScheme = themeData.colorScheme;

    return {
      'primary': colorScheme.primary,
      'secondary': colorScheme.secondary,
      'surface': colorScheme.surface,
      'background': colorScheme.surface,
      'tertiary': colorScheme.tertiary,
    };
  }
}
