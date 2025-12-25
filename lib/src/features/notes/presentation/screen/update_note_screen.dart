import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scribble/src/core/utils/extensions.dart';
import 'package:scribble/src/core/utils/share_plus_util.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import '../bloc/notes_bloc/notes_bloc.dart';

class UpdateNotesScreen extends StatefulWidget {
  final Note note;
  final int id;

  const UpdateNotesScreen({super.key, required this.note, required this.id});

  @override
  State<UpdateNotesScreen> createState() => _UpdateNotesScreenState();
}

class _UpdateNotesScreenState extends State<UpdateNotesScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late FocusNode titleFocusNode;
  late FocusNode contentFocusNode;
  late ValueNotifier<bool> isBookMarked;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);

    isBookMarked = ValueNotifier(widget.note.isBookMarked);

    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    isBookMarked.dispose();

    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String dateForDatabase = DateTime.now().toIso8601String();

    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            final note = Note(
              isArchived: widget.note.isArchived,
              isDeleted: widget.note.isDeleted,
              title: titleController.text,
              modifiedAt: dateForDatabase,
              createdAt: widget.note.createdAt,
              content: contentController.text,
              isBookMarked: isBookMarked.value,
            );
            context.read<NotesBloc>().add(
              UpdateNotesEvent(note: note, id: widget.id),
            );
          },
          child: Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              actions: [
                ValueListenableBuilder(
                  valueListenable: isBookMarked,
                  builder: (context, value, child) => IconButton(
                    onPressed: () {
                      //Update the local state
                      isBookMarked.value = !isBookMarked.value;
                      //Update the database
                      context.read<NotesBloc>().add(
                        BookmarkNotesEvent(
                          id: widget.id,
                          bookMark: !isBookMarked.value,
                        ),
                      );
                    },
                    icon: value
                        ? Icon(Icons.bookmark_rounded)
                        : Icon(Icons.bookmark_outline_rounded),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await shareNote(
                      title: widget.note.title,
                      content: widget.note.content,
                    );
                  },
                  icon: Icon(Icons.share_rounded),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    focusNode: titleFocusNode,
                    onEditingComplete: () => contentFocusNode.nextFocus(),
                    onTapOutside: (event) => contentFocusNode.nextFocus(),
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
                    controller: titleController,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 30,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      hintText: 'Title 👀',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 30,
                      ),
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
                          widget.note.modifiedAt.yMMMEdFormat,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.titleMedium?.color,
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
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      hintMaxLines: 100,
                      hintText: 'Type something...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
