import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/notes_bloc/notes_bloc.dart';

import '../../cubit/settings_cubit.dart';
import '../../models/settings/settings.dart';

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
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'General',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text('Theme'),
                      onTap: () {
                        context
                            .read<SettingsCubit>()
                            .toggleTheme(!state.isDarkMode);
                      },
                      subtitle: state.isDarkMode
                          ? Text('Light theme')
                          : Text('Dark theme'),
                      trailing: state.isDarkMode
                          ? Icon(Icons.light_mode_rounded)
                          : Icon(Icons.dark_mode_rounded),
                      tileColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      onTap: () {
                        context
                            .read<SettingsCubit>()
                            .toggleLayout(!state.isGrid);
                      },
                      title: Text('Toggle Layout'),
                      subtitle:
                          state.isGrid ? Text('List view') : Text('Grid view'),
                      trailing: state.isGrid
                          ? Icon(Icons.table_rows_rounded)
                          : Icon(Icons.grid_view_rounded),
                      tileColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secrets',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text('Passwords'),
                      subtitle: Text('Reset or create a password'),
                      trailing: Icon(Icons.lock_rounded),
                      tileColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Danger zone',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.redAccent),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Delete all notes!',
                              ),
                              content: Text(
                                  'Are you sure you want to delete all the notes, this action cannot be undone'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .color))),
                                TextButton(
                                    onPressed: () {
                                      context
                                          .read<NotesBloc>()
                                          .add(DeleteAllNotesevent());
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 18,
                                      ),
                                    )),
                              ],
                            );
                          },
                        );
                      },
                      title: Text('Delete'),
                      subtitle: Text('Delete all notes'),
                      trailing: Icon(Icons.delete_rounded),
                      tileColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    Text(
                      'About',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text('About'),
                      trailing: Icon(Icons.info_rounded),
                      tileColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 8),
                  ]),
            );
          },
        ));
  }
}
