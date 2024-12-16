import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/settings/settings.dart';
import '../services/settings_database.dart';

class SettingsCubit extends Cubit<Settings> {
  final HiveSettingsDatabase settingsDatabase;

  SettingsCubit({
    required this.settingsDatabase,
  }) : super(settingsDatabase.getInitialSetting());

  void toggleTheme(isDarkMode) {
    //Retrive the grid state as we are updating only the theme and not the layout
    Settings settings = settingsDatabase.getInitialSetting();
    //Update the values in the database
    settingsDatabase.putSettingsToBox(
        isGrid: settings.isGrid, isDarkMode: isDarkMode);
    emit(isDarkMode
        ? Settings(isGrid: settings.isGrid, isDarkMode: true)
        : Settings(isGrid: settings.isGrid, isDarkMode: false));
  }

  void toggleLayout(isGrid) {
    Settings settings = settingsDatabase.getInitialSetting();
    settingsDatabase.putSettingsToBox(
        isGrid: isGrid, isDarkMode: settings.isDarkMode);

    emit(isGrid
        ? Settings(isGrid: true, isDarkMode: settings.isDarkMode)
        : Settings(isGrid: false, isDarkMode: settings.isDarkMode));
  }
}
