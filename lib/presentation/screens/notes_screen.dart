import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import '../../cubit/settings_cubit.dart';
import '../../models/notes/notes.dart';
import '../../models/settings/settings.dart';
import '../../bloc/notes_bloc/notes_bloc.dart';
import '../widgets/notes_card.dart';
import 'new_notes_screen.dart';
import 'update_note_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NewNotesScreen(
                isHomeScreen: true,
              ),
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
                  if (state.note.isNotEmpty) {
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
                                isHomeScreen: true,
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
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset('assets/lottie/empty_list.json'),
                          Text(
                            'Everything looks empty here !',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    );
                  }
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
