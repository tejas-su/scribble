import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc/todos_bloc/todos_bloc.dart';
import 'cubit/page_view_cubit.dart';
import 'cubit/secrets_cubit.dart';
import 'cubit/settings_cubit.dart';
import 'models/notes/notes.dart';
import 'models/settings/settings.dart';
import 'bloc/notes_bloc/notes_bloc.dart';
import 'models/todos/todos.dart';
import 'presentation/themes/themes.dart';
import 'presentation/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'services/hive_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Optimal directory path to store the notes
  final directory = await getApplicationDocumentsDirectory();
  //Initialize the hive database
  await Hive.initFlutter(directory.path);
  //Custom object for hive
  Hive.registerAdapter(NotesAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(TodosAdapter());
  Box notesBox = await Hive.openBox<Notes>('notes');
  Box todosBox = await Hive.openBox<Todos>('todos');
  Box secretNotes = await Hive.openBox<Notes>('secretnotes');
  Box settingsBox = await Hive.openBox<Settings>('settings');

  //For handling the initial error showing the the theme value is empty
  if (settingsBox.isEmpty) {
    settingsBox.put(0, Settings(isGrid: false, isDarkMode: true));
  }
  //Retrieve the value of theme and layout
  Settings settings = settingsBox.getAt(0);
  bool initialTheme = settings.isDarkMode;
  bool initialLayout = settings.isGrid;
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
          create: (context) =>
              NotesBloc(hiveDatabase: HiveNotesDatabase(notesBox: notesBox))
                ..add(LoadNotesEvent())),
      BlocProvider(
          create: (context) => SecretNotesBloc(
              hiveDatabase: HiveNotesDatabase(notesBox: secretNotes))
            ..add(LoadNotesEvent())),
      BlocProvider(
        create: (context) => SettingsCubit(
            initialLayout: initialLayout,
            settingsBox: settingsBox,
            initialTheme: initialTheme),
      ),
      BlocProvider(
          create: (context) =>
              TodosBloc(hiveDatabase: HiveTodosDatabase(todosBox: todosBox))
                ..add(LoadTodoEvent())),
      BlocProvider(
        create: (context) => SecretsCubit(),
      ),
      BlocProvider(create: (context) => PageViewCubit()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Settings>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
