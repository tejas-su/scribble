import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings/settings.dart';

class HiveSettingsDatabase {
  final Box<Settings> box;
  HiveSettingsDatabase({required this.box});

  static Future<Box<Settings>> openBox(String boxName) async {
    final Box<Settings> box = await Hive.openBox<Settings>(boxName);
    return box;
  }

  void initializeSettings() {
    if (box.isEmpty) {
      box.put(
        0,
        const Settings(
          isGrid: false,
          isDarkMode: true,
          sortByModifiedDate: true,
        ),
      );
    }
  }

  Settings getInitialSetting() {
    final List<Settings> settings = box.values.toList().cast<Settings>();
    return settings[0];
  }

  void putSettingsToBox({
    required bool isGrid,
    required bool isDarkMode,
    required bool sortByModifiedDate,
  }) {
    box.putAt(
      0,
      Settings(
        isGrid: isGrid,
        isDarkMode: isDarkMode,
        sortByModifiedDate: sortByModifiedDate,
      ),
    );
  }
}
