import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primaryColor: const Color(0xFFA5D6A7),
  primaryColorDark: const Color(0xFF75A478),
  primaryColorLight: const Color(0xFFD7FFD9),
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    background: Color(0xFFA5D6A7),
    brightness: Brightness.light,
    error: Colors.red,
    onBackground: Colors.black,
    onError: Colors.white,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    primary: Color(0xFFA5D6A7),
    primaryVariant: Color(0xFF75A478),
    secondary: Color(0xFFCE93D8),
    secondaryVariant: Color(0xFF9C64A6),
    surface: Color(0xFFA5D6A7),
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
  scaffoldBackgroundColor: Colors.grey.shade100,
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    unselectedItemColor: Color(0xFFA5D6A7),
    selectedItemColor: Color(0xFF9C64A6),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.grey.shade100,
  ),
  iconTheme: const IconThemeData(
    color: Colors.black,
  ),
);

final darkTheme = lightTheme.copyWith(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    background: Color(0xFF75A478),
    brightness: Brightness.dark,
    error: Colors.red,
    onBackground: Colors.white,
    onError: Colors.white,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    primary: Color(0xFFA5D6A7),
    primaryVariant: Color(0xFF75A478),
    secondary: Color(0xFFCE93D8),
    secondaryVariant: Color(0xFF9C64A6),
    surface: Color(0xFF75A478),
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      fontSize: 20.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    bodyText2: TextStyle(
      fontSize: 16.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    headline1: TextStyle(
      fontSize: 64.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    headline2: TextStyle(
      fontSize: 56.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    headline3: TextStyle(
      fontSize: 48.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    headline4: TextStyle(
      fontSize: 40.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    headline5: TextStyle(
      fontSize: 32.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    headline6: TextStyle(
      fontSize: 24.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontSize: 16.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    subtitle2: TextStyle(
      fontSize: 12.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
    ),
    button: TextStyle(
      fontSize: 20.0,
      fontFamily: "Source Sans Pro",
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    caption: TextStyle(fontSize: 16.0, fontFamily: "Source Sans Pro"),
    overline: TextStyle(fontSize: 10.0, fontFamily: "Source Sans Pro"),
  ),
  scaffoldBackgroundColor: Colors.grey.shade800,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade800,
    unselectedItemColor: const Color(0xFFA5D6A7),
    selectedItemColor: const Color(0xFF9C64A6),
  ),
  drawerTheme: DrawerThemeData(
    backgroundColor: Colors.grey.shade800,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  dialogBackgroundColor: Colors.grey.shade800,
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.white,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.all(Colors.white),
    checkColor: MaterialStateProperty.all(Colors.grey.shade800),
  ),
);
