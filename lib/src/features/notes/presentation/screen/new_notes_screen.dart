import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scribble/src/core/utils/extensions.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import '../bloc/notes_bloc/notes_bloc.dart';

class NewNotesScreen extends StatefulWidget {
  const NewNotesScreen({super.key});

  @override
  State<NewNotesScreen> createState() => _NewNotesScreenState();
}

class _NewNotesScreenState extends State<NewNotesScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late ValueNotifier<bool> bookMarkNotifier;
  late ValueNotifier<bool> readOnlyNotifier;

  late FocusNode titleFocusNode;
  late FocusNode contentFocusNode;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();

    bookMarkNotifier = ValueNotifier(false);
    readOnlyNotifier = ValueNotifier(false);

    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    bookMarkNotifier.dispose();
    readOnlyNotifier.dispose();

    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String date = DateTime.now().toIso8601String();
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        //simple if condition to check if either one of
        ////the field is not empty then save the note
        if (titleController.text.isNotEmpty ||
            contentController.text.isNotEmpty) {
          final note = Note(
            isArchived: false,
            isDeleted: false,
            title: titleController.text,
            modifiedAt: date,
            createdAt: date,
            content: contentController.text,
            isBookMarked: bookMarkNotifier.value,
            isReadOnly: readOnlyNotifier.value,
          );
          context.read<NotesBloc>().add(AddNotesEvent(note: note));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          forceMaterialTransparency: true,
          surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          actions: [
            //Toggling this will make the note read only
            IconButton(
              onPressed: () => readOnlyNotifier.value = !readOnlyNotifier.value,
              icon: ValueListenableBuilder(
                valueListenable: readOnlyNotifier,
                builder: (context, readOnly, child) {
                  return readOnly
                      ? Icon(Icons.lock_rounded)
                      : Icon(Icons.lock_open_rounded);
                },
              ),
            ),
            //Toggling this would bookmark the note
            IconButton(
              onPressed: () => bookMarkNotifier.value = !bookMarkNotifier.value,
              icon: ValueListenableBuilder(
                valueListenable: bookMarkNotifier,
                builder: (context, isBookMarked, child) {
                  return isBookMarked
                      ? Icon(Icons.bookmark_rounded)
                      : Icon(Icons.bookmark_outline_rounded);
                },
              ),
            ),
            SizedBox(width: 4),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: readOnlyNotifier,
          builder: (context, readOnly, child) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  readOnly: readOnly,
                  keyboardAppearance: Theme.of(context).brightness,
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 55,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) => null,
                  focusNode: titleFocusNode,
                  onEditingComplete: () => contentFocusNode.nextFocus(),
                  onTapOutside: (event) => contentFocusNode.nextFocus(),
                  controller: titleController,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 30,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: 'Title',
                    hintStyle: TextStyle(fontSize: 30),
                    border: InputBorder.none,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        date.yMMMEdFormat,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 15,
                        ),
                      ),
                      Text('|'),
                      ValueListenableBuilder(
                        valueListenable: contentController,
                        builder: (context, value, child) => Text(
                          "${value.text.length} characters",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.titleMedium?.color,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  readOnly: readOnly,
                  focusNode: contentFocusNode,
                  onEditingComplete: () => contentFocusNode.unfocus(),
                  onTapOutside: (event) => contentFocusNode.unfocus(),
                  keyboardAppearance: Theme.of(context).brightness,
                  minLines: 1,
                  maxLines: 1000,
                  controller: contentController,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintMaxLines: 100,
                    hintText: 'Type something...',
                    hintStyle: TextStyle(fontSize: 18),
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
