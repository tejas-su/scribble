import 'package:flutter/material.dart';

final darkTheme = ThemeData(
    listTileTheme: ListTileThemeData(selectedTileColor: Color(0xFF27272a)),
    drawerTheme:
        DrawerThemeData(backgroundColor: const Color(0xFF1c1c1c), elevation: 0),
    cardColor: const Color(0xFF1c1c1c),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: Color(0xFF395886)),
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurpleAccent, brightness: Brightness.dark),
    useMaterial3: true,
    brightness: Brightness.dark);

final lightTheme = ThemeData(
  listTileTheme: ListTileThemeData(selectedTileColor: Color(0xFFf4f4f5)),
  drawerTheme:
      DrawerThemeData(backgroundColor: const Color(0xFFF7F0F0), elevation: 0),
  scaffoldBackgroundColor: Color(0xFFFAFAFA),
  cardColor: const Color(0xFFF7F0F0),
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurpleAccent, brightness: Brightness.light),
  useMaterial3: true,
  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(backgroundColor: Color(0xFFD5DEEF)),
  brightness: Brightness.light,
);
