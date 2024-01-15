import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../notes_bloc/notes_bloc.dart';
import '/models/notes.dart';
import '/utils/utils.dart';
import '../widgets/button.dart';
import '/presentation/themes/themes.dart';

class UpdateNotesScreen extends StatelessWidget {
  final int index;
  final String? title;
  final String? content;
  final String? date;
  final BuildContext context;

  const UpdateNotesScreen(
      {super.key,
      required this.index,
      required this.title,
      required this.content,
      required this.date,
      required this.context});

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.yMMMEd().format(DateTime.now()).toString();
    final TextEditingController titleController =
        TextEditingController(text: title);
    final colorindex = Random().nextInt(15);
    final TextEditingController contentController =
        TextEditingController(text: content);
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: black,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 10),
                child: NavButton(
                  onTap: () {
                    showUnsavedDialog(context, index, titleController.text,
                        contentController.text, date);
                  },
                  icon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/icons/left-arrow.png',
                    ),
                  ),
                ),
              ),
              backgroundColor: black,
            ),
            floatingActionButton: NavButton(
              height: 55,
              width: 55,
              icon: Icon(
                Icons.save_rounded,
                color: colors[colorindex],
                size: 30,
              ),
              onTap: () {
                /*create the class instance so that it can be stored, its just like a box which contains 
                      values and we are putting inside that  */
                final notes = Notes(
                  title: titleController.text,
                  date: date.toString(),
                  content: contentController.text,
                );
                context
                    .read<NotesBloc>()
                    .add(UpdateNotes(notes: notes, index: index));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Notes updated Successfully')));
              },
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    minLines: 1,
                    maxLines: 3,
                    controller: titleController,
                    style: const TextStyle(color: white, fontSize: 30),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: 'Title 👀',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 30),
                      border: InputBorder.none,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      date,
                      style:
                          const TextStyle(color: Colors.white30, fontSize: 15),
                    ),
                  ),
                  TextField(
                    minLines: 1,
                    maxLines: 1000,
                    controller: contentController,
                    style: const TextStyle(color: white, fontSize: 20),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintMaxLines: 100,
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 18),
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

  //show unsaved changes dialog to user if not saved

  void showUnsavedDialog(BuildContext context, int index, String title,
      String content, String date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors[3],
          contentTextStyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: black),
          titleTextStyle: const TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: black),
          title: const Text(
            'Forgot to save? 🤔',
          ),
          content: const Text(dialog),
          actions: <Widget>[
            TextButton(
              style: const ButtonStyle(
                  textStyle: MaterialStatePropertyAll(TextStyle(
                      fontSize: 20,
                      color: black,
                      fontWeight: FontWeight.w500))),
              onPressed: () {
                Navigator.of(context).pop(context);
                Navigator.of(context).pop(context);
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: black, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              style: const ButtonStyle(
                  textStyle: MaterialStatePropertyAll(TextStyle(
                      fontSize: 20,
                      color: black,
                      fontWeight: FontWeight.w500))),
              onPressed: () {
                /*create the class instance so that it can be stored, its just like a box which contains 
                      values and we are putting inside that  */
                final notes = Notes(
                  title: title,
                  date: date,
                  content: content,
                );
                context
                    .read<NotesBloc>()
                    .add(UpdateNotes(notes: notes, index: index));

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Notes updated Successfully')));

                Navigator.of(context).pop();
                Navigator.of(context).pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
