import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../notes_bloc/notes_bloc.dart';
import '../../models/notes/notes.dart';

class NewNotesScreen extends StatelessWidget {
  final bool isHomeScreen;
  const NewNotesScreen({super.key, required this.isHomeScreen});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    String date = DateFormat.yMMMEd().format(DateTime.now()).toString();
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            //simple if condition to check if either one of
            ////the field is not empty then save the note
            if (titleController.text.isNotEmpty ||
                contentController.text.isNotEmpty) {
              final notes = Notes(
                title: titleController.text,
                date: date.toString(),
                content: contentController.text,
              );
              isHomeScreen
                  ? context.read<NotesBloc>().add(AddNotesEvent(notes: notes))
                  : context
                      .read<SecretNotesBloc>()
                      .add(AddNotesEvent(notes: notes));
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              forceMaterialTransparency: true,
              surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: 'Title 👀',
                      hintStyle: TextStyle(
                        fontSize: 30,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      date,
                      style: const TextStyle(fontSize: 15),
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
        ));
  }
}
