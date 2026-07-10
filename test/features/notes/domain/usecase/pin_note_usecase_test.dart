import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/pin_note_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late PinNoteUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = PinNoteUseCase(repository);
  });

  test('calls pinNote when pin is true', () async {
    when(() => repository.pinNote(any())).thenAnswer((_) async {});

    await useCase(id: 1, pin: true);

    verify(() => repository.pinNote(1)).called(1);
    verifyNever(() => repository.unpinNote(any()));
  });

  test('calls unpinNote when pin is false', () async {
    when(() => repository.unpinNote(any())).thenAnswer((_) async {});

    await useCase(id: 1, pin: false);

    verify(() => repository.unpinNote(1)).called(1);
    verifyNever(() => repository.pinNote(any()));
  });

  test('propagates errors from the repository', () async {
    when(() => repository.pinNote(any())).thenThrow(Exception('fail'));

    expect(() => useCase(id: 1, pin: true), throwsException);
  });
}
