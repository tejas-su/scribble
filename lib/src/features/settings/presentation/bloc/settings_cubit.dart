import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/settings/settings.dart';
import '../../data/services/settings_database.dart';

class SettingsCubit extends Cubit<Settings> {
  final HiveSettingsDatabase settingsDatabase;

  SettingsCubit({required this.settingsDatabase})
    : super(settingsDatabase.getInitialSetting());

  void toggleTheme(bool isDarkMode) {
    //Retrive the grid state as we are updating only the theme and not the layout
    final Settings settings = settingsDatabase.getInitialSetting();
    //Update the values in the database
    settingsDatabase.putSettingsToBox(
      isGrid: settings.isGrid,
      isDarkMode: isDarkMode,
      sortByModifiedDate: settings.sortByModifiedDate,
    );
    emit(
      Settings(
        isGrid: settings.isGrid,
        isDarkMode: isDarkMode,
        sortByModifiedDate: settings.sortByModifiedDate,
      ),
    );
  }

  void toggleLayout(bool isGrid) {
    final Settings settings = settingsDatabase.getInitialSetting();
    settingsDatabase.putSettingsToBox(
      isGrid: isGrid,
      isDarkMode: settings.isDarkMode,
      sortByModifiedDate: settings.sortByModifiedDate,
    );
    emit(
      Settings(
        isGrid: isGrid,
        isDarkMode: settings.isDarkMode,
        sortByModifiedDate: settings.sortByModifiedDate,
      ),
    );
  }

  void toggleSortPreference(bool sortByModifiedDate) {
    final Settings settings = settingsDatabase.getInitialSetting();
    settingsDatabase.putSettingsToBox(
      isGrid: settings.isGrid,
      isDarkMode: settings.isDarkMode,
      sortByModifiedDate: sortByModifiedDate,
    );
    emit(
      Settings(
        isGrid: settings.isGrid,
        isDarkMode: settings.isDarkMode,
        sortByModifiedDate: sortByModifiedDate,
      ),
    );
  }
}
