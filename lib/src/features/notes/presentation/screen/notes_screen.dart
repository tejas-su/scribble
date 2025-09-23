import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
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
                  state.isSelecting
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              IconButton(
                                  iconSize: 25,
                                  onPressed: () => context
                                      .read<NotesBloc>()
                                      .add(SelectAllNotesEvent()),
                                  icon: Icon(
                                    Icons.select_all_rounded,
                                  )),
                              Expanded(child: SizedBox()),
                              IconButton(
                                  iconSize: 22,
                                  onPressed: () => context
                                      .read<NotesBloc>()
                                      .add(DeleteSelectedNotes(
                                          notes: state.note)),
                                  icon: Icon(Icons.delete_rounded)),
                              IconButton(
                                  iconSize: 20,
                                  onPressed: null,
                                  icon: Icon(Icons.share_rounded)),
                              IconButton(
                                  iconSize: 25,
                                  onPressed: () => context
                                      .read<NotesBloc>()
                                      .add(DeSelectAllNotesEvent()),
                                  icon: Icon(
                                    Icons.close,
                                  )),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
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
                              Notes notes = state.note[index]; //index position
                              return NotesCard(
                                onTapDown: storePosition,
                                isSelected: notes.isSelected,
                                onLongPress: () {
                                  if (tapPosition == null) {
                                    return;
                                  }
                                  context.read<NotesBloc>().add(
                                      SelectNotesEvent(
                                          note: notes,
                                          index: index,
                                          isSelected: !notes.isSelected));
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
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                        PopupMenuItem(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          enabled: true,
                                          value: 'share',
                                          child: Text('Share'),
                                        ),
                                        PopupMenuItem(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          enabled: true,
                                          value: 'bookmark',
                                          child: Text('Bookmark'),
                                        )
                                      ]);
                                },
                                onPressedSlidable: (context) {
                                  // context
                                  //     .read<NotesBloc>()
                                  //     .add(DeleteNotesEvent(index: index));
                                },
                                onDismissed: () {
                                  // context
                                  //     .read<NotesBloc>()
                                  //     .add(DeleteNotesEvent(index: index));
                                },
                                onTap: () {
                                  state.isSelecting
                                      ? context.read<NotesBloc>().add(
                                          SelectNotesEvent(
                                              note: notes,
                                              index: index,
                                              isSelected: !notes.isSelected))
                                      : Navigator.of(context)
                                          .push(MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateNotesScreen(
                                            note: notes,
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
