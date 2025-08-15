import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scribble/src/core/utils/share_plus_util.dart';
import '../bloc/notes_bloc/notes_bloc.dart';
import '../../data/models/notes/notes.dart';

class UpdateNotesScreen extends StatefulWidget {
  final Notes note;
  final int index;

  const UpdateNotesScreen({
    super.key,
    required this.note,
    required this.index,
  });

  @override
  State<UpdateNotesScreen> createState() => _UpdateNotesScreenState();
}

class _UpdateNotesScreenState extends State<UpdateNotesScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  late FocusNode titleFocusNode;
  late FocusNode contentFocusNode;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);

    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.yMMMEd().format(DateTime.now()).toString();

    //To listen to changes of bookmark state and build the ui as necessary
    final notesLoadedState =
        context.watch<NotesBloc>().state as NotesLoadedState;
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            final notes = Notes(
                title: titleController.text,
                date: date.toString(),
                content: contentController.text,
                isBookmarked: notesLoadedState.note[widget.index].isBookmarked);
            context
                .read<NotesBloc>()
                .add(UpdateNotesEvent(notes: notes, index: widget.index));
          },
          child: Scaffold(
            appBar: AppBar(
              forceMaterialTransparency: true,
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<NotesBloc>().add(UpdateNotesEvent(
                        notes: widget.note.copyWith(
                            isBookmarked: !notesLoadedState
                                .note[widget.index].isBookmarked),
                        index: widget.index));
                  },
                  icon: notesLoadedState.note[widget.index].isBookmarked
                      ? Icon(Icons.bookmark_rounded)
                      : Icon(Icons.bookmark_outline_rounded),
                ),
                IconButton(
                    onPressed: () async {
                      await shareNote(
                        title: widget.note.title,
                        content: widget.note.content,
                      );
                    },
                    icon: Icon(Icons.share_rounded))
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
                    controller: titleController,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontSize: 30),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      hintText: 'Title 👀',
                      hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 30),
                      border: InputBorder.none,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      widget.note.date,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 15),
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
                        fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(20),
                      hintMaxLines: 100,
                      hintText: 'Type something...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 18),
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
