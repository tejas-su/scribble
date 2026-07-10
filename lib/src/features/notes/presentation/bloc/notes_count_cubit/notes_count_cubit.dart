import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_count_usecase.dart';
import 'package:scribble/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart';

part 'notes_count_state.dart';

class NotesCountCubit extends Cubit<NotesCountState> {
  final GetNotesCountUseCase getNotesCountUseCase;
  late final StreamSubscription<NotesState> _notesBlocSubscription;

  NotesCountCubit({
    required this.getNotesCountUseCase,
    required NotesBloc notesBloc,
  }) : super(const NotesCountState()) {
    _notesBlocSubscription = notesBloc.stream.listen((_) => refreshCounts());
    refreshCounts();
  }

  Future<void> refreshCounts() async {
    try {
      final results = await Future.wait([
        getNotesCountUseCase(),
        getNotesCountUseCase(onlyArchived: true),
        getNotesCountUseCase(onlyBookmarked: true),
      ]);
      emit(
        NotesCountState(
          notesCount: results[0],
          archivedCount: results[1],
          bookmarkedCount: results[2],
        ),
      );
    } catch (_) {
      // Keep the previous counts if the refresh fails
    }
  }

  @override
  Future<void> close() {
    _notesBlocSubscription.cancel();
    return super.close();
  }
}
