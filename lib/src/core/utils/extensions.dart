import 'package:intl/intl.dart';

extension StringToFormattedDate on String {
  String get yMMMEdFormat {
    final parsed = DateTime.tryParse(this);
    if (parsed == null) return this;
    return DateFormat.yMMMEd().format(parsed);
  }
}
