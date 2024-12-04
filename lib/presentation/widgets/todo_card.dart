import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TodoCard extends StatelessWidget {
  final String todo;
  final String date;
  final Function() onDismissed;
  final Function(BuildContext)? onPressedSlidable;
  final Function(bool?)? onChanged;
  final bool value;
  const TodoCard({
    super.key,
    this.onPressedSlidable,
    this.onChanged,
    required this.onDismissed,
    required this.value,
    required this.todo,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
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
      child: Container(
        height: 90,
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo,
                    maxLines: 1,
                    style: TextStyle(
                        color: value
                            ? Colors.grey
                            : Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 18),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                        color: value
                            ? Colors.grey
                            : Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 14),
                  ),
                ],
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
              )
            ],
          ),
        ),
      ),
    );
  }
}
