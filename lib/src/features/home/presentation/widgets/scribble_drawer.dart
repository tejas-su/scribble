import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/src/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:scribble/src/features/settings/presentation/screen/settings_screen.dart';

import '../../../notes/presentation/bloc/notes_bloc/notes_bloc.dart';

class ScribbleDrawer extends StatelessWidget {
  final ValueNotifier<int> pageNotifier;
  final PageController pageController;
  const ScribbleDrawer({super.key, required this.pageNotifier, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 8,
            crossAxisAlignment: .start,
            children: [
              SafeArea(
                child: Text(
                  'scribble',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
              Divider(),
              // pages
              ValueListenableBuilder(
                valueListenable: pageNotifier,
                builder: (context, value, child) => Column(
                  spacing: 8,
                  children: [
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      selected: pageNotifier.value == 0,
                      leading: const Icon(Icons.edit_rounded),
                      title: const Text('Notes'),
                      onTap: () {
                        pageNotifier.value = 0;
                        Navigator.of(context).pop();
                        final sortByModifiedDate = context
                            .read<SettingsCubit>()
                            .state
                            .sortByModifiedDate;
                        context.read<NotesBloc>().add(
                          LoadNotesEvent(
                            sortByModifiedDate: sortByModifiedDate,
                          ),
                        );
                        pageController.animateToPage(
                          0,
                          duration: Durations.medium1,
                          curve: Easing.linear,
                        );
                      },
                    ),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      selected: pageNotifier.value == 1,
                      leading: const Icon(Icons.today_rounded),
                      title: const Text('Todos'),
                      onTap: () {
                        pageNotifier.value = 1;
                        Navigator.of(context).pop();
                        pageController.animateToPage(
                          1,
                          duration: Durations.medium1,
                          curve: Easing.linear,
                        );
                      },
                    ),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      selected: pageNotifier.value == 2,
                      leading: const Icon(Icons.delete_rounded),
                      title: const Text('Deleted'),
                      onTap: () {
                        pageNotifier.value = 2;
                        Navigator.of(context).pop();
                        context.read<NotesBloc>().add(LoadDeletedNotesEvent());
                        pageController.animateToPage(
                          0,
                          duration: Durations.medium1,
                          curve: Easing.linear,
                        );
                      },
                    ),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      selected: pageNotifier.value == 3,
                      leading: const Icon(Icons.archive_rounded),
                      title: const Text('Archived'),
                      onTap: () {
                        pageNotifier.value = 3;
                        Navigator.of(context).pop();
                        context.read<NotesBloc>().add(LoadArchivedNotesEvent());
                        pageController.animateToPage(
                          0,
                          duration: Durations.medium1,
                          curve: Easing.linear,
                        );
                      },
                    ),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      selected: pageNotifier.value == 4,
                      leading: const Icon(Icons.bookmark_rounded),
                      title: const Text('Bookmarks'),
                      onTap: () {
                        pageNotifier.value = 4;
                        Navigator.of(context).pop();
                        context.read<NotesBloc>().add(LoadBookmarkedNotesEvent());
                        pageController.animateToPage(
                          0,
                          duration: Durations.medium1,
                          curve: Easing.linear,
                        );
                      },
                    ),
                    ListTile(
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.onSecondaryContainer,
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                      ),
                      selected: false,
                      leading: const Icon(Icons.settings_rounded),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}