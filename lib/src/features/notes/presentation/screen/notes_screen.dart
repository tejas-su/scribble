import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scribble/src/core/utils/menu_overlay.dart';
import 'package:scribble/src/core/utils/sort_modal_bottom_sheet.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/presentation/screen/notes_loading_screen.dart';
import 'package:scribble/src/features/notes/presentation/widgets/empty_placeholder.dart';
import '../../../../core/utils/share_plus_util.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../bloc/notes_bloc/notes_bloc.dart';
import '../widgets/notes_card.dart';
import 'new_notes_screen.dart';
import 'update_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late FocusNode _focusNode;
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.80) {
      // User has scrolled to 80% of the list, load more
      final query = _searchController.text;
      context.read<NotesBloc>().add(
        LoadMoreNotesEvent(query: query.isEmpty ? null : query),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Offset? tapPosition;

    void storePosition(TapDownDetails tapDownDetails) {
      tapPosition = tapDownDetails.globalPosition;
    }

    return Scaffold(
      floatingActionButton: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          // Only show FAB on the main notes screen (not deleted, archived, or bookmarked)
          if (state is NotesLoadedState &&
              !state.isDeleted &&
              !state.isArchived &&
              !state.isBookmarked) {
            return FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              elevation: 2,
              onPressed: () {
                //Clear the search results and set it to initial results
                _searchController.clear();
                _focusNode.unfocus();
                context.read<NotesBloc>().add(
                  const SearchNotesEvent(query: ''),
                );
                //Navigate to new notes screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NewNotesScreen(),
                  ),
                );
              },
              child: Icon(
                Icons.edit_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: Column(
        mainAxisSize: .min,
        children: [
          //Search bar
          Builder(
            builder: (context) {
              final NotesState state = context.watch<NotesBloc>().state;

              // Hide search bar during loading, when deleted/archived/bookmarked,
              // or when empty (but keep visible during active search)
              final bool isSearching = _searchController.text.isNotEmpty;

              if (state is NotesLoadingState ||
                  (state is NotesLoadedState &&
                      (state.isDeleted ||
                          state.isArchived ||
                          state.isBookmarked ||
                          (state.notes.isEmpty && !isSearching)))) {
                return SizedBox.shrink();
              } else {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    spacing: 4,
                    mainAxisSize: .min,
                    children: [
                      Expanded(
                        child: SearchBar(
                          controller: _searchController,
                          onChanged: (value) => context.read<NotesBloc>().add(
                            SearchNotesEvent(query: value),
                          ),
                          onSubmitted: (value) => _focusNode.unfocus(),
                          onTapOutside: (_) => _focusNode.unfocus(),
                          focusNode: _focusNode,
                          trailing: [
                            //Cancel button to clear search
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: const Icon(Icons.clear),
                              ),
                              onTap: () {
                                _searchController.clear();
                                _focusNode.unfocus();
                                context.read<NotesBloc>().add(
                                  const SearchNotesEvent(query: ''),
                                );
                              },
                            ),
                          ],
                          backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).colorScheme.surfaceContainer,
                          ),
                          elevation: WidgetStatePropertyAll(0),
                          keyboardType: TextInputType.text,

                          textStyle: WidgetStatePropertyAll(
                            TextStyle(height: 1),
                          ),

                          leading: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.search_rounded,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          hintText: 'Search...',
                          hintStyle: WidgetStatePropertyAll(
                            TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      //Filter
                      GestureDetector(
                        onTap: () {
                          final bool sortByModifiedDate = context
                              .read<SettingsCubit>()
                              .state
                              .sortByModifiedDate;
                          final int selectedIndex = sortByModifiedDate ? 0 : 1;
                          sortModalBottomSheet(context, selectedIndex, (
                            newSelectedIndex,
                          ) {
                            final bool newSortByModifiedDate =
                                newSelectedIndex == 0;
                            context.read<SettingsCubit>().toggleSortPreference(
                              newSortByModifiedDate,
                            );
                            context.read<NotesBloc>().add(
                              LoadNotesEvent(
                                sortByModifiedDate: newSortByModifiedDate,
                              ),
                            );
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.filter_alt,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 8),
          //Notes grid/list view
          Expanded(
            child: BlocBuilder<NotesBloc, NotesState>(
              builder: (context, state) {
                return switch (state) {
                  //Loading state
                  NotesLoadingState() => const NotesLoadingScreen(),
                  //Loaded state
                  NotesLoadedState() => Column(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      state.notes.isNotEmpty
                          ? Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Theme(
                                      data: ThemeData(
                                        colorScheme: Theme.of(
                                          context,
                                        ).colorScheme,
                                        scrollbarTheme: ScrollbarThemeData(
                                          thumbColor: WidgetStatePropertyAll(
                                            Theme.of(
                                              context,
                                            ).colorScheme.surfaceContainerLow,
                                          ),
                                        ),
                                      ),
                                      child: Scrollbar(
                                        interactive: true,
                                        thickness: 8,
                                        radius: Radius.circular(12),
                                        controller: _scrollController,
                                        child: MasonryGridView.builder(
                                          controller: _scrollController,
                                          gridDelegate:
                                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    context
                                                        .watch<SettingsCubit>()
                                                        .state
                                                        .isGrid
                                                    ? 2
                                                    : 1,
                                              ),
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          padding: const EdgeInsets.all(18),
                                          itemCount: state.notes.length,
                                          itemBuilder: (context, index) {
                                            final Note note = state
                                                .notes[index]; //Instance of Note
                                            return NotesCard(
                                              onTapDown: storePosition,
                                              onLongPress: () {
                                                if (tapPosition == null) {
                                                  return;
                                                }
                                                // Show menu overlay
                                                showMenuOverlay(
                                                  restoreNote:
                                                      state.isArchived ||
                                                      state.isDeleted,
                                                  isDeletedNote:
                                                      state.isDeleted,
                                                  context: context,
                                                  rect: RelativeRect.fromLTRB(
                                                    tapPosition!.dx,
                                                    tapPosition!.dy,
                                                    MediaQuery.sizeOf(
                                                          context,
                                                        ).width -
                                                        tapPosition!.dx,
                                                    MediaQuery.sizeOf(
                                                          context,
                                                        ).width -
                                                        tapPosition!.dy,
                                                  ),
                                                  onRestore: () => context
                                                      .read<NotesBloc>()
                                                      .add(
                                                        RestoreNotesEvent(
                                                          isDeletedNote:
                                                              state.isDeleted,
                                                          id: note.id!,
                                                        ),
                                                      ),
                                                  onArchive: () => context
                                                      .read<NotesBloc>()
                                                      .add(
                                                        ArchiveNotesEvent(
                                                          id: note.id!,
                                                        ),
                                                      ),
                                                  deletePermanently: () =>
                                                      context
                                                          .read<NotesBloc>()
                                                          .add(
                                                            DeleteNotesEvent(
                                                              id: note.id!,
                                                              softDelete: false,
                                                            ),
                                                          ),
                                                  onDelete: () => context
                                                      .read<NotesBloc>()
                                                      .add(
                                                        DeleteNotesEvent(
                                                          id: note.id!,
                                                          softDelete: true,
                                                        ),
                                                      ),
                                                  onBookmark: () {
                                                    context
                                                        .read<NotesBloc>()
                                                        .add(
                                                          BookmarkNotesEvent(
                                                            id: note.id!,
                                                            bookMark: !note
                                                                .isBookMarked,
                                                          ),
                                                        );
                                                  },
                                                  onShare: () async {
                                                    await shareNote(
                                                      title: note.title,
                                                      content: note.content,
                                                    );
                                                  },
                                                );
                                              },
                                              onTap: note.isDeleted
                                                  ? null
                                                  : () {
                                                      Navigator.of(
                                                        context,
                                                      ).push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UpdateNotesScreen(
                                                                note: note,
                                                                id: note.id!,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                              icon: note.isBookMarked
                                                  ? Icons.bookmark_rounded
                                                  : null,
                                              date: note.modifiedAt,
                                              title: note.title,
                                              content: note.content,
                                              searchQuery:
                                                  _searchController.text.isEmpty
                                                  ? null
                                                  : _searchController.text,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (state.isLoadingMore) SizedBox.shrink(),
                                ],
                              ),
                            )
                          : Expanded(child: EmptyPlaceholder()),
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
                      ),
                    ),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
