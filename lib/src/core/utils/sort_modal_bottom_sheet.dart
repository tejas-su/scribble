import 'package:flutter/material.dart';

/// Callback function for the sort modal bottom sheet, gives the selected index
typedef SortModalBottomSheetCallback = void Function(int selectedIndex);

/// Sort modal bottom sheet, shows a bottom sheet with a list of options to sort the notes
/// 1. Modified Date
/// 2. Created Date
Future<void> sortModalBottomSheet(
  BuildContext context,
  int selectedIndex,
  SortModalBottomSheetCallback callback,
) async {
  return await showModalBottomSheet(
    enableDrag: true,
    isScrollControlled: true,
    showDragHandle: true,
    context: context,
    builder: (context) {
      return SizedBox(
        width: double.infinity,
        height: 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: .min,
            children: [
              Text(
                'Sort by',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              //Filter by modified date
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  callback(0);
                },
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                selected: selectedIndex == 0,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainer,
                leading: selectedIndex == 0 ? Icon(Icons.check) : SizedBox(),
                title: Text('Modified Date'),
              ),
              //Filter by created date
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  callback(1);
                },
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                selected: selectedIndex == 1,
                selectedColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                ),
                tileColor: Theme.of(context).colorScheme.surfaceContainer,
                leading: selectedIndex == 1 ? Icon(Icons.check) : SizedBox(),
                title: Text('Created Date'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
