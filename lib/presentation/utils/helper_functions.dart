import 'package:flutter/material.dart';

Future<dynamic> showAlertDialog(
    {required BuildContext context,
    String action_1 = 'Cancel',
    String action_2 = 'Delete',
    required String title,
    required String content,
    Function()? onPressed}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(action_1,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.titleSmall!.color))),
          TextButton(
              onPressed: onPressed,
              child: Text(
                action_2,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                ),
              )),
        ],
      );
    },
  );
}
