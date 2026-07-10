import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/features/todos/data/models/todos/todos.dart';

void main() {
  group('Todos', () {
    test('equality is based on isCompleted, date, todo', () {
      const a = Todos(isCompleted: false, date: 'd', todo: 'task');
      const b = Todos(isCompleted: false, date: 'd', todo: 'task');
      expect(a, b);
    });

    test('differs when isCompleted changes', () {
      const a = Todos(isCompleted: false, date: 'd', todo: 'task');
      const b = Todos(isCompleted: true, date: 'd', todo: 'task');
      expect(a, isNot(equals(b)));
    });

    group('copyWith', () {
      const base = Todos(isCompleted: false, date: 'd', todo: 'task');

      test('overrides only supplied fields', () {
        final updated = base.copyWith(isCompleted: true);
        expect(updated.isCompleted, isTrue);
        expect(updated.date, base.date);
        expect(updated.todo, base.todo);
      });

      test('with no arguments returns an equivalent copy', () {
        expect(base.copyWith(), base);
      });

      test('supports empty todo text', () {
        final updated = base.copyWith(todo: '');
        expect(updated.todo, '');
      });
    });
  });
}
