import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'bookmarks.g.dart';

@HiveType(typeId: 3)
class Bookmarks extends Equatable {
  @HiveField(0)
  final bool isBookMarked;
  @HiveField(1)
  const Bookmarks({required this.isBookMarked});
  @override
  List<Object?> get props => [isBookMarked];
}
