import 'package:flutter/material.dart';

final darkTheme = ThemeData(
    dividerColor: Color(0xff2c2c2c),
    scaffoldBackgroundColor: Color(0xFF121212),
    listTileTheme: ListTileThemeData(selectedTileColor: Color(0xFF27272a)),
    cardColor: const Color(0xFF1e1e1e),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: Color(0xFF395886)),
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurpleAccent, brightness: Brightness.dark),
    useMaterial3: true,
    brightness: Brightness.dark);

final lightTheme = ThemeData(
  dividerColor: Color(0xFFe4e4e7),
  listTileTheme: ListTileThemeData(
    selectedTileColor: Color(0xFFf4f4f5),
  ),
  scaffoldBackgroundColor: Color(0xFFffffff),
  cardColor: const Color(0xFFfafafa),
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurpleAccent, brightness: Brightness.light),
  useMaterial3: true,
  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(backgroundColor: Color(0xFFD5DEEF)),
  brightness: Brightness.light,
);
