// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'notes.g.dart';

//to generate the code run => dart run build_runner build
@HiveType(typeId: 1)
class Notes extends Equatable {
  final bool isSelected;
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final bool isBookmarked;
  @HiveField(3)
  const Notes({
    this.isSelected = false,
    this.isBookmarked = false,
    required this.title,
    required this.date,
    required this.content,
  });

  @override
  List<Object?> get props => [title, date, content, isBookmarked, isSelected];

  Notes copyWith(
      {String? title,
      String? date,
      String? content,
      bool? isBookmarked,
      bool? isSelected}) {
    return Notes(
      title: title ?? this.title,
      date: date ?? this.date,
      content: content ?? this.content,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
