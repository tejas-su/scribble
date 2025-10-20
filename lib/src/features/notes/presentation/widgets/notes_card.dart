import 'package:flutter/material.dart';

class NotesCard extends StatelessWidget {
  /// On tap function: When the user taps on the card
  final Function()? onTap;

  /// The title of the card
  final String? title;

  ///The date or timestamp for the date field,
  /// by default its '' or empty string
  final String? date;

  ///The content to be shown in detail
  final String? content;

  ///Icon: optional
  final IconData? icon;

  ///On long press action
  final Function()? onLongPress;

  ///To fetch the details of the user tapped position
  final Function(TapDownDetails)? onTapDown;

  const NotesCard({
    super.key,
    this.icon,
    this.onLongPress,
    this.title = '',
    this.date = '',
    this.content = '',
    required this.onTap,
    this.onTapDown,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onLongPress: onLongPress,
      onTap: onTap,
      child: Badge(
        alignment: Alignment.topRight,
        largeSize: 30,
        backgroundColor: Colors.transparent,
        label: Icon(
          icon,
          size: 25,
        ),
        child: Container(
          //width: fixes a bug in which the container dosent expand
          //to its full screen width
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Theme.of(context).cardColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  title.toString(),
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  date.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  content.toString(),
                  maxLines: 10,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      overflow: TextOverflow.fade),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
