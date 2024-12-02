import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../cubit/settings_cubit.dart';
import '../../models/notes/notes.dart';
import '../../models/settings/settings.dart';
import '../../notes_bloc/notes_bloc.dart';
import '../widgets/notes_card.dart';
import 'new_notes_screen.dart';
import 'todo_screen.dart';
import 'update_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleSpacing: 20,
        title: Text(
          'scribble',
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        actions: [
          BlocBuilder<SettingsCubit, Settings>(
            builder: (context, theme) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          context
                              .read<SettingsCubit>()
                              .toggleTheme(!theme.isDarkMode);
                        },
                        icon: theme.isDarkMode
                            ? Icon(
                                Icons.light_mode_rounded,
                                color: Theme.of(context).iconTheme.color,
                              )
                            : Icon(
                                Icons.dark_mode_rounded,
                                color: Theme.of(context).iconTheme.color,
                              )),
                    //Buton to change the view to grid or list view accordingly
                    BlocBuilder<SettingsCubit, Settings>(
                      builder: (context, state) {
                        return IconButton(
                            onPressed: () {
                              context
                                  .read<SettingsCubit>()
                                  .toggleLayout(!state.isGrid);
                            },
                            icon: state.isGrid
                                ? const Icon(Icons.grid_view_rounded)
                                : const Icon(Icons.table_rows_rounded));
                      },
                    ),

                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const TodoScreen(),
                          ));
                        },
                        icon: const Icon(Icons.event_available))
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewNotesScreen(),
            ),
          );
        },
        backgroundColor:
            Theme.of(context).floatingActionButtonTheme.backgroundColor,
        child: Icon(
          Icons.edit_rounded,
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          return switch (state) {
            //Loading state
            NotesLoadingState() => Center(
                  child: CircularProgressIndicator(
                color: Theme.of(context).textTheme.titleLarge?.color,
              )),
            //Loaded state
            NotesLoadedState() => BlocBuilder<SettingsCubit, Settings>(
                builder: (context, layout) {
                  return MasonryGridView.builder(
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: layout.isGrid ? 2 : 1),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.all(18),
                    itemCount: state.note.length,
                    itemBuilder: (context, index) {
                      Notes notes = state.note[index]; //index position
                      return NotesCard(
                        onPressedSlidable: (context) {
                          context
                              .read<NotesBloc>()
                              .add(DeleteNotesEvent(index: index));
                        },
                        onDismissed: () {
                          context
                              .read<NotesBloc>()
                              .add(DeleteNotesEvent(index: index));
                        },
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UpdateNotesScreen(
                              note: state.note[index],
                              index: index,
                            ),
                          ));
                        },
                        icon: state.note[index].isBookmarked
                            ? Icons.bookmark_rounded
                            : null,
                        date: notes.date,
                        title: notes.title,
                        content: notes.content,
                      );
                    },
                  );
                },
              ),
            //Error state
            NotesErrorState() => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                    child: Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                )),
              )
          };
        },
      ),
    );
  }
}
