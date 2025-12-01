import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;

  final String title;

  final String content;

  final String date;

  final bool isBookMarked;

  final bool isArchived;

  final bool isDeleted;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.isBookMarked,
    required this.isArchived,
    required this.isDeleted,
  });
  @override
  List<Object?> get props => [title, content, date, isArchived, isBookMarked];
}
