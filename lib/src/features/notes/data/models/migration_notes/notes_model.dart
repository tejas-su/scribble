import 'package:scribble/src/features/notes/domain/enitities/note.dart';

class NotesModel extends Note {
  const NotesModel({
    super.id,
    required super.title,
    required super.content,
    required super.date,
    required super.isBookMarked,
    required super.isArchived,
    required super.isDeleted,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": super.id,
      "title": super.title,
      "date": super.date,
      "content": super.content,
      "isBookMarked": super.isBookMarked ? 1 : 0,
      "isArchived": super.isArchived ? 1 : 0,
      "isDeleted": super.isDeleted ? 1 : 0,
    };
  }

  NotesModel copyWith({
    String? title,
    String? date,
    String? content,
    bool? isBookMarked,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return NotesModel(
      title: title ?? this.title,
      date: date ?? this.date,
      content: content ?? this.content,
      isBookMarked: isBookMarked ?? this.isBookMarked,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory NotesModel.fromMap(Map<String, dynamic> map) => NotesModel(
        id: map["id"],
        title: map["title"],
        content: map["content"],
        date: map["date"],
        isBookMarked: map["isBookMarked"] == 1,
        isArchived: map["isArchived"] == 1,
        isDeleted: map["isDeleted"] == 1,
      );
}
