import 'package:flutter/material.dart';

import '../themes/themes.dart';

class TodoCard extends StatelessWidget {
  final String todo;
  final String date;
  const TodoCard({super.key, required this.todo, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo,
                  maxLines: 2,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 18),
                ),
                Text(
                  date,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 14),
                ),
              ],
            ),
            const Checkbox(
              value: true,
              onChanged: null,
            )
          ],
        ),
      ),
    );
  }
}
