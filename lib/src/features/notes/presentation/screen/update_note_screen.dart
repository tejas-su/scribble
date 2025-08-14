import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/notes_bloc/notes_bloc.dart';
import '../../data/notes/notes.dart';

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
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note.title);
    contentController = TextEditingController(text: widget.note.content);
  }

  late TextEditingController titleController;

  late TextEditingController contentController;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.yMMMEd().format(DateTime.now()).toString();

    //To listen to changes of bookmark state and build the ui as necessary
    final notesLoadedState =
        context.watch<NotesBloc>().state as NotesLoadedState;
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: PopScope(
            onPopInvokedWithResult: (didPop, result) {
              final notes = Notes(
                  title: titleController.text,
                  date: date.toString(),
                  content: contentController.text,
                  isBookmarked:
                      notesLoadedState.note[widget.index].isBookmarked);
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
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
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
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 30),
                        border: InputBorder.none,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        widget.note.date,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 15),
                      ),
                    ),
                    TextField(
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
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
