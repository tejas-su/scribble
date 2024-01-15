import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
part 'notes.g.dart';

//to generate the code run => dart run build_runner build
@HiveType(typeId: 1)
class Notes extends Equatable {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final String content;
  @HiveField(3)
  const Notes({
    required this.title,
    required this.date,
    required this.content,
  });

  Notes copyWith({
    String? title,
    String? content,
    String? date,
  }) {
    return Notes(
      title: title ?? this.title,
      date: date ?? this.date,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [title, date, content];
}
