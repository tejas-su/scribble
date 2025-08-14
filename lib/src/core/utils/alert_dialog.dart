import 'package:flutter/material.dart';

Future<dynamic> showAlertDialog(
    {required BuildContext context,
    String action_1 = 'Cancel',
    String action_2 = 'Delete',
    Color? action2Color = Colors.redAccent,
    required String title,

    ///Override the default text buttons if required
    bool overrideActions = false,

    ///The list of actions, mainly text buttons or icon button
    List<Widget>? actions,
    Widget? content,
    Function()? onPressed}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: overrideActions
            ? actions
            : [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(action_1,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .color))),
                TextButton(
                    onPressed: onPressed,
                    child: Text(
                      action_2,
                      style: TextStyle(
                        color: action2Color,
                        fontSize: 18,
                      ),
                    )),
              ],
      );
    },
  );
}
