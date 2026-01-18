import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int? id;

  final String title;

  final String content;

  final String modifiedAt;

  final String createdAt;

  final bool isBookMarked;

  final bool isArchived;

  final bool isDeleted;

  final bool isReadOnly;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.modifiedAt,
    required this.createdAt,
    required this.isBookMarked,
    required this.isArchived,
    required this.isDeleted,
    required this.isReadOnly,
  });
  @override
  List<Object?> get props => [
    title,
    content,
    modifiedAt,
    createdAt,
    isArchived,
    isBookMarked,
    isReadOnly,
  ];
}
