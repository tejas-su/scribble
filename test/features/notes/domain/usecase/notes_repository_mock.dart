import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

class FakeNote extends Fake implements Note {}

const testNote = Note(
  title: 'title',
  content: 'content',
  modifiedAt: '2026-01-01',
  createdAt: '2026-01-01',
  isBookMarked: false,
  isPinned: false,
  isArchived: false,
  isDeleted: false,
  isReadOnly: false,
);
