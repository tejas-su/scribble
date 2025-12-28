// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart';
import '../../../todos/presentation/bloc/todos_bloc/todos_bloc.dart';
import '../bloc/settings_cubit.dart';
import '../../data/models/settings/settings.dart';
import '../../../../core/utils/alert_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleSpacing: 20,
        title: Text(
          'settings',
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
      body: BlocBuilder<SettingsCubit, Settings>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                    title: Text('Theme'),
                    onTap: () {
                      context.read<SettingsCubit>().toggleTheme(
                        !state.isDarkMode,
                      );
                    },
                    subtitle: state.isDarkMode
                        ? Text('Light theme')
                        : Text('Dark theme'),
                    trailing: state.isDarkMode
                        ? Icon(Icons.light_mode_rounded)
                        : Icon(Icons.dark_mode_rounded),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    onTap: () {
                      context.read<SettingsCubit>().toggleLayout(!state.isGrid);
                    },
                    title: Text('Toggle Layout'),
                    subtitle: state.isGrid
                        ? Text('List view')
                        : Text('Grid view'),
                    trailing: state.isGrid
                        ? Icon(Icons.table_rows_rounded)
                        : Icon(Icons.grid_view_rounded),
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Danger zone',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    onTap: () {
                      showAlertDialog(
                        context: context,
                        title: 'Delete all notes!',
                        content: Text(
                          'Are you sure you want to delete all the notes, this action cannot be undone',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          context.read<NotesBloc>().add(DeleteAllNotesevent());
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    title: Text('Delete'),
                    subtitle: Text('Delete all notes'),
                    trailing: Icon(Icons.delete_rounded),
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    onTap: () {
                      showAlertDialog(
                        context: context,
                        title: 'Delete all tdos!',
                        content: Text(
                          'Are you sure you want to delete all the todos, this action cannot be undone',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          context.read<TodosBloc>().add(DeleteAllTodoEvent());
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    title: Text('Delete'),
                    subtitle: Text('Delete all todos'),
                    trailing: Icon(Icons.delete_rounded),
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    tileColor: Theme.of(context).colorScheme.surfaceContainer,
                    title: Text('Version'),
                    subtitle: Text('v4.0.0'),
                    trailing: Icon(Icons.info_rounded),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
