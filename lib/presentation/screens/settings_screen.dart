// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/bloc/notes_bloc/notes_bloc.dart';
import '../../bloc/todos_bloc/todos_bloc.dart';
import '../../cubit/secrets_cubit.dart';
import '../../cubit/settings_cubit.dart';
import '../../models/settings/settings.dart';
import '../utils/helper_functions.dart';
import '../widgets/message_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordController = TextEditingController();
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
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
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      onTap: () async {
                        Box box = await Hive.openBox('password');
                        //  box.deleteAt(0);
                        var password = box.getAt(0);
                        debugPrint('Passwords in the database: $password');

                        //if password is empty then ask the user to create one
                        if (password == null) {
                          showAlertDialog(
                              context: context,
                              title: 'Create a password',
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Enter a strong password to secure your notes.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  BlocBuilder<SecretsCubit, SecretsCubitState>(
                                    builder: (context, state) {
                                      return MessageField(
                                        obscureText: state.obscureText,
                                        padding: 0,
                                        maxLines: 1,
                                        minLines: 1,
                                        onComplete: (p0) {
                                          context
                                              .read<SecretsCubit>()
                                              .onValidate(
                                                  passwordController.text,
                                                  context);
                                        },
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        controller: passwordController,
                                        icon: state.obscureText
                                            ? Icons.lock_rounded
                                            : Icons.lock_open_rounded,
                                        prompt: 'Create a password',
                                        onSubmitted: () {
                                          context
                                              .read<SecretsCubit>()
                                              .onToggle(state.obscureText);
                                        },
                                        errorText: state.showErrorText
                                            ? state.errortext
                                            : null,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              overrideActions: true,
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Discard',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .color),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      if (passwordController.text.isNotEmpty) {
                                        box.putAt(0, passwordController.text);
                                        debugPrint(
                                            'Saved password from field: ${box.getAt(0)}');
                                        Navigator.of(context).pop();
                                        passwordController.clear();
                                      }
                                    },
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .color),
                                    ))
                              ]);
                        } else if (password.isNotEmpty) {
                          showAlertDialog(
                              context: context,
                              title: 'Change password',
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Enter a strong password to secure your notes.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  BlocBuilder<SecretsCubit, SecretsCubitState>(
                                    builder: (context, state) {
                                      return MessageField(
                                        obscureText: state.obscureText,
                                        padding: 0,
                                        maxLines: 1,
                                        minLines: 1,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        controller: passwordController,
                                        icon: state.obscureText
                                            ? Icons.lock_rounded
                                            : Icons.lock_open_rounded,
                                        prompt: 'Enter old password',
                                        onSubmitted: () {
                                          context
                                              .read<SecretsCubit>()
                                              .onToggle(state.obscureText);
                                        },
                                        errorText: state.showErrorText
                                            ? state.errortext
                                            : null,
                                      );
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  BlocBuilder<SecretsCubit, SecretsCubitState>(
                                    builder: (context, state) {
                                      return MessageField(
                                        obscureText: state.obscureText,
                                        padding: 0,
                                        maxLines: 1,
                                        minLines: 1,
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        controller: passwordController,
                                        icon: state.obscureText
                                            ? Icons.lock_rounded
                                            : Icons.lock_open_rounded,
                                        prompt: 'Enter new password',
                                        onSubmitted: () {
                                          context
                                              .read<SecretsCubit>()
                                              .onToggle(state.obscureText);
                                        },
                                        errorText: state.showErrorText
                                            ? state.errortext
                                            : null,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              overrideActions: true,
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Discard',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .color),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      if (passwordController.text.isNotEmpty) {
                                        //TODO: HANDLE reset part
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .color),
                                    ))
                              ]);
                        }
                      },
                      title: Text('Password'),
                      subtitle: Text('Reset or create a password'),
                      trailing: Icon(Icons.lock_rounded),
                      tileColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Danger zone',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.redAccent),
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
                            context
                                .read<NotesBloc>()
                                .add(DeleteAllNotesevent());
                            Navigator.of(context).pop();
                          },
                        );
                      },
                      title: Text('Delete'),
                      subtitle: Text('Delete all notes'),
                      trailing: Icon(Icons.delete_rounded),
                      tileColor: Theme.of(context).cardColor,
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
                      tileColor: Theme.of(context).cardColor,
                    ),
                  ]),
            ),
          );
        },
      ),
    );
  }
}
