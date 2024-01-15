import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import '../themes/themes.dart';

class NotesCard extends StatelessWidget {
  final Function()? onTap;
  final Function()? onLongPress;
  final String? title;
  final String? date;
  final String? content;

  const NotesCard(
      {super.key,
      this.title = '',
      this.date = '',
      this.content = '',
      required this.onLongPress,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final index = Random().nextInt(15);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: colors[index],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(
                title.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                date.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: grey,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                content.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.fade),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
