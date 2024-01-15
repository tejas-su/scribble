import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/notes.dart';
import 'package:scribble/notes_bloc/hive_database.dart';
import 'notes_bloc/notes_bloc.dart';
import 'presentation/themes/themes.dart';
import 'presentation/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);
  Hive.registerAdapter(NotesAdapter());
  final hiveDatabase = HiveDatabase();
  await hiveDatabase.openBox();

  runApp(
    MyApp(
      hiveDatabase: hiveDatabase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final HiveDatabase _hiveDatabase;
  MyApp({super.key, required HiveDatabase hiveDatabase})
      : _hiveDatabase = HiveDatabase();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _hiveDatabase,
      child: BlocProvider(
        create: (context) =>
            NotesBloc(hiveDatabase: _hiveDatabase)..add(LoadNotes()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: darkTheme,
          home: const HomeScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
          },
        ),
      ),
    );
  }
}
