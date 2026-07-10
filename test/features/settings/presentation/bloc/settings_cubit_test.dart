import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/settings/data/models/settings/settings.dart';
import 'package:scribble/src/features/settings/data/services/settings_database.dart';
import 'package:scribble/src/features/settings/presentation/bloc/settings_cubit.dart';

class MockHiveSettingsDatabase extends Mock implements HiveSettingsDatabase {}

void main() {
  late MockHiveSettingsDatabase database;

  const initial = Settings(isGrid: false, isDarkMode: true, sortByModifiedDate: true);

  setUp(() {
    database = MockHiveSettingsDatabase();
    when(() => database.getInitialSetting()).thenReturn(initial);
    when(
      () => database.putSettingsToBox(
        isGrid: any(named: 'isGrid'),
        isDarkMode: any(named: 'isDarkMode'),
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
      ),
    ).thenReturn(null);
  });

  SettingsCubit buildCubit() => SettingsCubit(settingsDatabase: database);

  test('initial state comes from settingsDatabase.getInitialSetting', () {
    final cubit = buildCubit();
    addTearDown(cubit.close);

    expect(cubit.state, initial);
  });

  group('toggleTheme', () {
    test('emits isDarkMode toggled and preserves other fields', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.toggleTheme(false);

      expect(cubit.state.isDarkMode, isFalse);
      expect(cubit.state.isGrid, initial.isGrid);
      expect(cubit.state.sortByModifiedDate, initial.sortByModifiedDate);
    });

    test('persists the new value to the database', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.toggleTheme(false);

      verify(
        () => database.putSettingsToBox(
          isGrid: initial.isGrid,
          isDarkMode: false,
          sortByModifiedDate: initial.sortByModifiedDate,
        ),
      ).called(1);
    });
  });

  group('toggleLayout', () {
    test('emits isGrid toggled and preserves other fields', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.toggleLayout(true);

      expect(cubit.state.isGrid, isTrue);
      expect(cubit.state.isDarkMode, initial.isDarkMode);
    });
  });

  group('toggleSortPreference', () {
    test('emits sortByModifiedDate toggled and preserves other fields', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.toggleSortPreference(false);

      expect(cubit.state.sortByModifiedDate, isFalse);
      expect(cubit.state.isGrid, initial.isGrid);
      expect(cubit.state.isDarkMode, initial.isDarkMode);
    });
  });

  test('reads latest persisted settings on every toggle (not cached state)', () {
    // toggleTheme re-reads getInitialSetting() rather than using cubit.state,
    // so if the database's underlying values changed externally, that
    // externally-changed value (not the cubit's in-memory state) wins.
    final cubit = buildCubit();
    addTearDown(cubit.close);

    when(() => database.getInitialSetting()).thenReturn(
      const Settings(isGrid: true, isDarkMode: true, sortByModifiedDate: true),
    );

    cubit.toggleTheme(false);

    expect(cubit.state.isGrid, isTrue);
  });
}
