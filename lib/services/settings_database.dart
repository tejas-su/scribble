import 'package:hive_flutter/hive_flutter.dart';
import '../models/settings/settings.dart';

class HiveSettingsDatabase {
  final Box<Settings> box;
  HiveSettingsDatabase({required this.box});

  static openBox(String boxName) async {
    Box<Settings> box = await Hive.openBox<Settings>(boxName);
    return box;
  }

  initializeSettings() {
    if (box.isEmpty) {
      box.put(0, Settings(isGrid: false, isDarkMode: true));
    }
  }

  Settings getInitialSetting() {
    List<Settings> settings = box.values.toList().cast<Settings>();
    return settings[0];
  }

  void putSettingsToBox({required bool isGrid, required bool isDarkMode}) {
    box.putAt(0, Settings(isGrid: isGrid, isDarkMode: isDarkMode));
  }
}
