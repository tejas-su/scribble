import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/src/features/notes/data/repository/notes_repository_impl.dart';
import 'package:scribble/src/features/notes/data/services/sqflite_notes_database_service.dart';
import 'package:scribble/src/features/notes/domain/usecase/add_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/archive_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/bookmark_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/read_write_access_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/soft_delete_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_note_permanently_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_all_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/restore_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/update_note_usecase.dart';
import 'src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart';
import 'src/features/home/presentation/bloc/page_view_cubit.dart';
import 'src/features/settings/presentation/bloc/settings_cubit.dart';
import 'src/features/notes/data/models/notes/notes.dart';
import 'src/features/settings/data/models/settings/settings.dart';
import 'src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart';
import 'src/features/todos/data/models/todos/todos.dart';
import 'src/core/themes/themes.dart';
import 'src/features/home/presentation/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'src/features/notes/data/services/hive_notes_database.dart';
import 'src/features/settings/data/services/settings_database.dart';
import 'src/features/todos/data/services/hive_todos_database.dart';

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
  //Initialization of boxes (open the box)
  Box<Notes> notesBox = await HiveNotesDatabase.openBox('notes');
  Box<Todos> todosBox = await HiveTodosDatabase.openBox('todos');
  Box<Settings> settingsBox = await HiveSettingsDatabase.openBox('settings');
  HiveSettingsDatabase(box: settingsBox).initializeSettings();
  runApp(
    MyApp(notesBox: notesBox, todosBox: todosBox, settingsbox: settingsBox),
  );
}

class MyApp extends StatelessWidget {
  final Box<Notes> notesBox;
  final Box<Todos> todosBox;
  final Box<Settings> settingsbox;
  const MyApp({
    super.key,
    required this.notesBox,
    required this.todosBox,
    required this.settingsbox,
  });

  @override
  Widget build(BuildContext context) {
    final repo = NotesRepositoryImpl(SqfliteNotesDatabaseService.instance);
    return MultiBlocProvider(
      providers: [
        // Settings Bloc - must be first so other blocs can access it
        BlocProvider(
          create: (context) => SettingsCubit(
            settingsDatabase: HiveSettingsDatabase(box: settingsbox),
          ),
        ),

        // Notes Bloc
        BlocProvider(
          create: (context) {
            final settingsCubit = context.read<SettingsCubit>();
            final sortByModifiedDate = settingsCubit.state.sortByModifiedDate;
            return NotesBloc(
              archiveNotesUseCase: ArchiveNotesUseCase(repo),
              restoreNotesUseCase: RestoreNotesUseCase(repo),
              getNotesUseCase: GetNotesUseCase(repo),
              addNoteUseCase: AddNoteUseCase(repo),
              updateNoteUseCase: UpdateNoteUseCase(repo),
              softDeleteNoteUseCase: SoftDeleteNoteUseCase(repo),
              deleteNotePermanentlyUseCase: DeleteNotePermanentlyUseCase(repo),
              deleteAllNotesUseCase: DeleteAllNotesUseCase(repo),
              bookmarkNoteUseCase: BookmarkNoteUseCase(repo),
              readWriteAccessUsecase: ReadWriteAccessUsecase(repo),
              hiveDatabase: HiveNotesDatabase(box: notesBox),
              settingsCubit: settingsCubit,
            )..add(LoadNotesEvent(sortByModifiedDate: sortByModifiedDate));
          },
        ),

        // Todos Bloc
        BlocProvider(
          create: (context) =>
              TodosBloc(hiveDatabase: HiveTodosDatabase(box: todosBox))
                ..add(LoadTodoEvent()),
        ),

        // Page View Bloc
        BlocProvider(create: (context) => PageViewCubit()),
      ],
      child: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
