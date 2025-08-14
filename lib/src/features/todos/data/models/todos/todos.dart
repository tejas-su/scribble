import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'todos.g.dart';

@HiveType(typeId: 3)
class Todos extends Equatable {
  @HiveField(0)
  final bool isCompleted;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final String todo;
  @HiveField(3)
  const Todos(
      {required this.isCompleted, required this.date, required this.todo});

  @override
  List<Object?> get props => [isCompleted, date, todo];

  Todos copyWith({
    bool? isCompleted,
    String? date,
    String? todo,
  }) {
    return Todos(
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      todo: todo ?? this.todo,
    );
  }
}
