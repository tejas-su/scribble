import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends Equatable {
  @HiveField(0)
  final bool isGrid;
  @HiveField(1)
  final bool isDarkMode;
  @HiveField(2)
  const Settings({required this.isGrid, required this.isDarkMode});
  @override
  List<Object?> get props => [isGrid, isDarkMode];
}
