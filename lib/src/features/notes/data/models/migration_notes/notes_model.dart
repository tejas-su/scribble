import 'package:scribble/src/features/notes/domain/enitities/note.dart';

class NotesModel extends Note {
  const NotesModel({
    super.id,
    required super.title,
    required super.content,
    required super.modifiedAt,
    required super.createdAt,
    required super.isBookMarked,
    required super.isArchived,
    required super.isDeleted,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": super.id,
      "title": super.title,
      "modifiedAt": super.modifiedAt,
      "createdAt": super.createdAt,
      "content": super.content,
      "isBookMarked": super.isBookMarked ? 1 : 0,
      "isArchived": super.isArchived ? 1 : 0,
      "isDeleted": super.isDeleted ? 1 : 0,
    };
  }

  NotesModel copyWith({
    String? title,
    String? date,
    String? createdAt,
    String? content,
    bool? isBookMarked,
    bool? isArchived,
    bool? isDeleted,
  }) {
    return NotesModel(
      title: title ?? this.title,
      modifiedAt: date ?? this.modifiedAt,
      createdAt: createdAt ?? this.createdAt,
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
    modifiedAt: map["modifiedAt"],
    createdAt: map["createdAt"],
    isBookMarked: map["isBookMarked"] == 1,
    isArchived: map["isArchived"] == 1,
    isDeleted: map["isDeleted"] == 1,
  );

  factory NotesModel.fromEntity(Note note) => NotesModel(
    id: note.id,
    title: note.title,
    content: note.content,
    modifiedAt: note.modifiedAt,
    createdAt: note.createdAt,
    isBookMarked: note.isBookMarked,
    isArchived: note.isArchived,
    isDeleted: note.isDeleted,
  );
}
