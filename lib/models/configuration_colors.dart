import 'dart:convert';

class ConfigurationColors {
  final String name;
  final int id;
  Config? config;

  ConfigurationColors({
    required this.id,
    required this.name,
    this.config,
  });

  factory ConfigurationColors.fromJson(String str) =>
      ConfigurationColors.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ConfigurationColors.fromMap(Map<String, dynamic> json) =>
      ConfigurationColors(
        id: json['id'],
        name: json['name'],
        config: json["config"] == null ? null : Config.fromMap(json["config"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "config": config?.toMap(),
      };
}

class Config {
  Mode? dark;
  Mode? light;
  Logos? logos;

  Config({
    this.dark,
    this.light,
    this.logos,
  });

  factory Config.fromJson(String str) => Config.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Config.fromMap(Map<String, dynamic> json) => Config(
        dark: json["dark"] == null ? null : Mode.fromMap(json["dark"]),
        light: json["light"] == null ? null : Mode.fromMap(json["light"]),
        logos: json["logos"] == null ? null : Logos.fromMap(json["logos"]),
      );

  Map<String, dynamic> toMap() => {
        "dark": dark?.toMap(),
        "light": light?.toMap(),
        "logos": logos?.toMap(),
      };
}

class Mode {
  // FlexSchemeColor properties
  String? primary;
  String? primaryContainer;
  String? secondary;
  String? secondaryContainer;
  String? tertiary;
  String? tertiaryContainer;
  String? appBarColor;
  String? error;
  String? errorContainer;

  // ColorScheme properties
  String? brightness;
  String? primaryFixed;
  String? primaryFixedDim;
  String? onPrimary;
  String? onPrimaryContainer;
  String? onPrimaryFixed;
  String? onPrimaryFixedVariant;
  String? secondaryFixed;
  String? secondaryFixedDim;
  String? onSecondary;
  String? onSecondaryContainer;
  String? onSecondaryFixed;
  String? onSecondaryFixedVariant;
  String? tertiaryFixed;
  String? tertiaryFixedDim;
  String? onTertiary;
  String? onTertiaryContainer;
  String? onTertiaryFixed;
  String? onTertiaryFixedVariant;
  String? surface;
  String? surfaceDim;
  String? onError;
  String? onErrorContainer;
  String? onSurface;
  String? surfaceBright;
  String? surfaceContainerLowest;
  String? surfaceContainer;
  String? surfaceContainerHigh;
  String? inverseSurface;
  String? surfaceContainerLow;
  String? onSurfaceVariant;
  String? surfaceContainerHighest;
  String? onInverseSurface;
  String? outline;
  String? shadow;
  String? inversePrimary;
  String? outlineVariant;
  String? scrim;
  String? surfaceTint;

  Mode({
    // FlexSchemeColor
    this.primary,
    this.primaryContainer,
    this.secondary,
    this.secondaryContainer,
    this.tertiary,
    this.tertiaryContainer,
    this.appBarColor,
    this.error,
    this.errorContainer,

    // ColorScheme
    this.brightness,
    this.primaryFixed,
    this.primaryFixedDim,
    this.onPrimary,
    this.onPrimaryContainer,
    this.onPrimaryFixed,
    this.onPrimaryFixedVariant,
    this.secondaryFixed,
    this.secondaryFixedDim,
    this.onSecondary,
    this.onSecondaryContainer,
    this.onSecondaryFixed,
    this.onSecondaryFixedVariant,
    this.tertiaryFixed,
    this.tertiaryFixedDim,
    this.onTertiary,
    this.onTertiaryContainer,
    this.onTertiaryFixed,
    this.onTertiaryFixedVariant,
    this.surface,
    this.surfaceDim,
    this.onError,
    this.onErrorContainer,
    this.onSurface,
    this.surfaceBright,
    this.surfaceContainerLowest,
    this.surfaceContainer,
    this.surfaceContainerHigh,
    this.inverseSurface,
    this.surfaceContainerLow,
    this.onSurfaceVariant,
    this.surfaceContainerHighest,
    this.onInverseSurface,
    this.outline,
    this.shadow,
    this.inversePrimary,
    this.outlineVariant,
    this.scrim,
    this.surfaceTint,
  });

  factory Mode.fromJson(String str) => Mode.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Mode.fromMap(Map<String, dynamic> json) => Mode(
        // FlexSchemeColor
        primary: json["primary"],
        primaryContainer: json["primaryContainer"],
        secondary: json["secondary"],
        secondaryContainer: json["secondaryContainer"],
        tertiary: json["tertiary"],
        tertiaryContainer: json["tertiaryContainer"],
        appBarColor: json["appBarColor"],
        error: json["error"],
        errorContainer: json["errorContainer"],

        // ColorScheme
        brightness: json["brightness"],
        primaryFixed: json["primaryFixed"],
        primaryFixedDim: json["primaryFixedDim"],
        onPrimary: json["onPrimary"],
        onPrimaryContainer: json["onPrimaryContainer"],
        onPrimaryFixed: json["onPrimaryFixed"],
        onPrimaryFixedVariant: json["onPrimaryFixedVariant"],
        secondaryFixed: json["secondaryFixed"],
        secondaryFixedDim: json["secondaryFixedDim"],
        onSecondary: json["onSecondary"],
        onSecondaryContainer: json["onSecondaryContainer"],
        onSecondaryFixed: json["onSecondaryFixed"],
        onSecondaryFixedVariant: json["onSecondaryFixedVariant"],
        tertiaryFixed: json["tertiaryFixed"],
        tertiaryFixedDim: json["tertiaryFixedDim"],
        onTertiary: json["onTertiary"],
        onTertiaryContainer: json["onTertiaryContainer"],
        onTertiaryFixed: json["onTertiaryFixed"],
        onTertiaryFixedVariant: json["onTertiaryFixedVariant"],
        surface: json["surface"],
        surfaceDim: json["surfaceDim"],
        onError: json["onError"],
        onErrorContainer: json["onErrorContainer"],
        onSurface: json["onSurface"],
        surfaceBright: json["surfaceBright"],
        surfaceContainerLowest: json["surfaceContainerLowest"],
        surfaceContainer: json["surfaceContainer"],
        surfaceContainerHigh: json["surfaceContainerHigh"],
        inverseSurface: json["inverseSurface"],
        surfaceContainerLow: json["surfaceContainerLow"],
        onSurfaceVariant: json["onSurfaceVariant"],
        surfaceContainerHighest: json["surfaceContainerHighest"],
        onInverseSurface: json["onInverseSurface"],
        outline: json["outline"],
        shadow: json["shadow"],
        inversePrimary: json["inversePrimary"],
        outlineVariant: json["outlineVariant"],
        scrim: json["scrim"],
        surfaceTint: json["surfaceTint"],
      );

  Map<String, dynamic> toMap() => {
        // FlexSchemeColor
        "primary": primary,
        "primaryContainer": primaryContainer,
        "secondary": secondary,
        "secondaryContainer": secondaryContainer,
        "tertiary": tertiary,
        "tertiaryContainer": tertiaryContainer,
        "appBarColor": appBarColor,
        "error": error,
        "errorContainer": errorContainer,

        // ColorScheme
        "brightness": brightness,
        "primaryFixed": primaryFixed,
        "primaryFixedDim": primaryFixedDim,
        "onPrimary": onPrimary,
        "onPrimaryContainer": onPrimaryContainer,
        "onPrimaryFixed": onPrimaryFixed,
        "onPrimaryFixedVariant": onPrimaryFixedVariant,
        "secondaryFixed": secondaryFixed,
        "secondaryFixedDim": secondaryFixedDim,
        "onSecondary": onSecondary,
        "onSecondaryContainer": onSecondaryContainer,
        "onSecondaryFixed": onSecondaryFixed,
        "onSecondaryFixedVariant": onSecondaryFixedVariant,
        "tertiaryFixed": tertiaryFixed,
        "tertiaryFixedDim": tertiaryFixedDim,
        "onTertiary": onTertiary,
        "onTertiaryContainer": onTertiaryContainer,
        "onTertiaryFixed": onTertiaryFixed,
        "onTertiaryFixedVariant": onTertiaryFixedVariant,
        "surface": surface,
        "surfaceDim": surfaceDim,
        "onError": onError,
        "onErrorContainer": onErrorContainer,
        "onSurface": onSurface,
        "surfaceBright": surfaceBright,
        "surfaceContainerLowest": surfaceContainerLowest,
        "surfaceContainer": surfaceContainer,
        "surfaceContainerHigh": surfaceContainerHigh,
        "inverseSurface": inverseSurface,
        "surfaceContainerLow": surfaceContainerLow,
        "onSurfaceVariant": onSurfaceVariant,
        "surfaceContainerHighest": surfaceContainerHighest,
        "onInverseSurface": onInverseSurface,
        "outline": outline,
        "shadow": shadow,
        "inversePrimary": inversePrimary,
        "outlineVariant": outlineVariant,
        "scrim": scrim,
        "surfaceTint": surfaceTint,
      };
}

class Logos {
  String? logoColor;
  String? logoBlanco;
  List<String>? logos;
  List<String>? login;

  Logos({
    this.logoColor,
    this.logoBlanco,
    this.logos,
    this.login,
  });

  factory Logos.fromJson(String str) => Logos.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Logos.fromMap(Map<String, dynamic> json) => Logos(
        logoColor: json["logoColor"],
        logoBlanco: json["logoBlanco"],
        logos: json["logos"] == null
            ? []
            : List<String>.from(json["logos"]!.map((x) => x)),
        login: json["login"] == null
            ? []
            : List<String>.from(json["login"]!.map((x) => x)),
      );

  Map<String, dynamic> toMap() => {
        "logoColor": logoColor,
        "logoBlanco": logoBlanco,
        "logos": logos == null ? [] : List<dynamic>.from(logos!.map((x) => x)),
        "login": login == null ? [] : List<dynamic>.from(login!.map((x) => x)),
      };
}
