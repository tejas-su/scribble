import 'package:flutter/material.dart';

void showSnackBar({required String text, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      shape: BeveledRectangleBorder(),
      backgroundColor: Colors.transparent,
      duration: Durations.medium1,
      content: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          style:
              TextStyle(color: Theme.of(context).textTheme.titleLarge!.color),
        ),
      )));
}
