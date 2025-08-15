import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  ///On dismissed function is called when the user
  ///slides the card to the left, mainly used to add functionality
  ///like delete, or anything
  final Function() onDismissed;

  ///The function to take place when the icon is pressed in the dissmissable widget
  final Function(BuildContext)? onPressedSlidable;

  //Icon: optional
  final IconData? icon;

  //On long press action
  final Function()? onLongPress;

  ///Is selected, whether this card is selected or not
  final bool isSelected;

  const NotesCard({
    super.key,
    this.icon,
    required this.onPressedSlidable,
    required this.onDismissed,
    this.onLongPress,
    this.title = '',
    this.date = '',
    this.content = '',
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Slidable(
        key: const ValueKey(0),
        direction: Axis.horizontal,
        endActionPane: ActionPane(
            dismissible: DismissiblePane(onDismissed: onDismissed),
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                autoClose: true,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                onPressed: onPressedSlidable,
                backgroundColor: Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete_rounded,
              ),
            ]),
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
              color:isSelected?Theme.of(context).listTileTheme.selectedTileColor: Theme.of(context).cardColor,
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
      ),
    );
  }
}
