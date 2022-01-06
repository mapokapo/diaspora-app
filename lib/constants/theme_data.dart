import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primaryColor: const Color(0xFFA5D6A7),
  primaryColorDark: const Color(0xFF75A478),
  primaryColorLight: const Color(0xFFD7FFD9),
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    background: Colors.grey.shade100,
    brightness: Brightness.light,
    error: Colors.red,
    onBackground: Colors.black,
    onError: Colors.white,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    primary: const Color(0xFFA5D6A7),
    primaryVariant: const Color(0xFF75A478),
    secondary: const Color(0xFFCE93D8),
    secondaryVariant: const Color(0xFF9C64A6),
    surface: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(fontSize: 20.0, fontFamily: "Source Sans Pro"),
    bodyText2: TextStyle(fontSize: 16.0, fontFamily: "Source Sans Pro"),
    headline1: TextStyle(fontSize: 64.0, fontFamily: "Source Sans Pro"),
    headline2: TextStyle(fontSize: 56.0, fontFamily: "Source Sans Pro"),
    headline3: TextStyle(fontSize: 48.0, fontFamily: "Source Sans Pro"),
    headline4: TextStyle(fontSize: 40.0, fontFamily: "Source Sans Pro"),
    headline5: TextStyle(fontSize: 32.0, fontFamily: "Source Sans Pro"),
    headline6: TextStyle(fontSize: 24.0, fontFamily: "Source Sans Pro"),
    subtitle1: TextStyle(fontSize: 16.0, fontFamily: "Source Sans Pro"),
    subtitle2: TextStyle(fontSize: 12.0, fontFamily: "Source Sans Pro"),
    button: TextStyle(
      fontSize: 20.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    caption: TextStyle(fontSize: 16.0, fontFamily: "Source Sans Pro"),
    overline: TextStyle(fontSize: 10.0, fontFamily: "Source Sans Pro"),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.grey.shade800,
    ),
  ),
);

final darkTheme = lightTheme.copyWith(
  brightness: Brightness.dark,
);
