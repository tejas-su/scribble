import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings/settings.dart';

class SettingsCubit extends Cubit<Settings> {
  final bool initialTheme;
  final bool initialLayout;
  final Box settingsBox;

  SettingsCubit(
      {required this.initialLayout,
      required this.initialTheme,
      required this.settingsBox})
      : super(Settings(isGrid: initialLayout, isDarkMode: initialTheme));

  List<Settings> _getInitial() {
    List<Settings> settings = settingsBox.values.toList().cast<Settings>();
    return settings;
  }

  void toggleTheme(isDarkMode) {
    List<Settings> settings = _getInitial();
    settingsBox.put(
        0, Settings(isGrid: settings[0].isGrid, isDarkMode: isDarkMode));
    emit(isDarkMode
        ? Settings(isGrid: settings[0].isGrid, isDarkMode: true)
        : Settings(isGrid: settings[0].isGrid, isDarkMode: false));
  }

  void toggleLayout(isGrid) {
    List<Settings> settings = _getInitial();

    settingsBox.put(
        0, Settings(isGrid: isGrid, isDarkMode: settings[0].isDarkMode));
    emit(isGrid
        ? Settings(isGrid: true, isDarkMode: settings[0].isDarkMode)
        : Settings(isGrid: false, isDarkMode: settings[0].isDarkMode));
  }
}
