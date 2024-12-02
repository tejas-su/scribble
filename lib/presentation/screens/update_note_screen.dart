import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../notes_bloc/notes_bloc.dart';
import '../../models/notes/notes.dart';

class UpdateNotesScreen extends StatelessWidget {
  final Notes note;
  final int index;

  const UpdateNotesScreen({
    super.key,
    required this.note,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.yMMMEd().format(DateTime.now()).toString();
    final TextEditingController titleController =
        TextEditingController(text: note.title);
    final TextEditingController contentController =
        TextEditingController(text: note.content);
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
                  isBookmarked: notesLoadedState.note[index].isBookmarked);
              context
                  .read<NotesBloc>()
                  .add(UpdateNotesEvent(notes: notes, index: index));
            },
            child: Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      context.read<NotesBloc>().add(UpdateNotesEvent(
                          notes: note.copyWith(
                              isBookmarked:
                                  !notesLoadedState.note[index].isBookmarked),
                          index: index));
                    },
                    icon: notesLoadedState.note[index].isBookmarked
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
                        note.date,
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 15),
                      ),
                    ),
                    TextField(
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
