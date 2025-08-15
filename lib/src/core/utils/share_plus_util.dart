import 'package:share_plus/share_plus.dart';

Future<void> shareNote({required String title, required String content}) async {
  await SharePlus.instance.share(ShareParams(
      title: title.trim().isEmpty ? ' ' : title,
      subject: title.trim().isEmpty ? ' ' : title,
      text: content.trim().isEmpty ? ' ' : content));
}
