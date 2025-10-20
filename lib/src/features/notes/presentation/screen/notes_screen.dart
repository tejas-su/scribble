import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/utils/share_plus_util.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../data/models/notes/notes.dart';
import '../bloc/notes_bloc/notes_bloc.dart';
import '../widgets/notes_card.dart';
import 'new_notes_screen.dart';
import 'update_note_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Offset? tapPosition;

    void storePosition(TapDownDetails tapDownDetails) {
      tapPosition = tapDownDetails.globalPosition;
    }

    return Scaffold(
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
            NotesLoadedState() => Column(
                children: [
                  state.note.isNotEmpty
                      ? Expanded(
                          child: MasonryGridView.builder(
                            gridDelegate:
                                SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: context
                                            .watch<SettingsCubit>()
                                            .state
                                            .isGrid
                                        ? 2
                                        : 1),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            padding: const EdgeInsets.all(18),
                            itemCount: state.note.length,
                            itemBuilder: (context, index) {
                              Notes note = state.note[index]; //index position
                              return NotesCard(
                                onTapDown: storePosition,
                                onLongPress: () {
                                  if (tapPosition == null) {
                                    return;
                                  }
                                  showMenu(
                                      positionBuilder: (context, constraints) {
                                        return RelativeRect.fromLTRB(
                                            tapPosition!.dx,
                                            tapPosition!.dy,
                                            MediaQuery.sizeOf(context).width -
                                                tapPosition!.dx,
                                            MediaQuery.sizeOf(context).width -
                                                tapPosition!.dy);
                                      },
                                      popUpAnimationStyle: AnimationStyle(
                                          curve: Curves.bounceIn),
                                      menuPadding: EdgeInsets.all(8),
                                      elevation: 1,
                                      context: context,
                                      items: [
                                        PopupMenuItem(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          enabled: true,
                                          onTap: () => context
                                              .read<NotesBloc>()
                                              .add(DeleteNotesEvent(
                                                  index: index)),
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                        PopupMenuItem(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          enabled: true,
                                          onTap: () {
                                            context.read<NotesBloc>().add(
                                                UpdateNotesEvent(
                                                    notes: note.copyWith(
                                                        isBookmarked:
                                                            !note.isBookmarked),
                                                    index: index));
                                          },
                                          value: 'bookmark',
                                          child: Text('Bookmark'),
                                        ),
                                        PopupMenuItem(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          enabled: true,
                                          value: 'share',
                                          onTap: () async {
                                            await shareNote(
                                              title: note.title,
                                              content: note.content,
                                            );
                                          },
                                          child: Text('Share'),
                                        ),
                                      ]);
                                },
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => UpdateNotesScreen(
                                      note: note,
                                      index: index,
                                    ),
                                  ));
                                },
                                icon: note.isBookmarked
                                    ? Icons.bookmark_rounded
                                    : null,
                                date: note.date,
                                title: note.title,
                                content: note.content,
                              );
                            },
                          ),
                        )
                      : Expanded(
                          child: Padding(
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
                          ),
                        ),
                ],
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
