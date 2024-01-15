import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/models/notes.dart';
import 'package:scribble/presentation/screens/new_notes_screen.dart';
import '../../notes_bloc/notes_bloc.dart';
import '../../utils/utils.dart';
import '../widgets/notes_card.dart';
import '/presentation/widgets/button.dart';
import '/presentation/themes/themes.dart';
import 'update_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorindex = Random().nextInt(15);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        foregroundColor: black,
        backgroundColor: black,
        title: Text(
          'Scribble',
          style: GoogleFonts.merriweather(
            color: white,
            fontSize: 35,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 8, bottom: 8),
            child: NavButton(
                height: 55,
                width: 80,
                onTap: () {
                  context.read<NotesBloc>().add(ToggleGridViewEvent());
                },
                icon: Center(
                  child: BlocBuilder<NotesBloc, NotesState>(
                    builder: (context, state) {
                      return Text(
                        state is NotesLoaded && state.isGrid == 1
                            ? 'GRID'
                            : 'LIST',
                        style: TextStyle(
                            color: colors[colorindex],
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                )),
          ),
        ],
      ),
      floatingActionButton: NavButton(
          height: 55,
          width: 55,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NewNotesScreen(),
              )),
          icon: Icon(
            Icons.add_rounded,
            weight: 100,
            size: 35,
            color: colors[colorindex],
          )),
      backgroundColor: black,
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: white,
            ));
          }
          if (state is NotesLoaded) {
            return MasonryGridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: state.isGrid),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemCount: state.note.length,
              itemBuilder: (context, index) {
                Notes notes = state.note[index]; //index position
                return NotesCard(
                  onLongPress: () {
                    context
                        .read<NotesBloc>()
                        .add(DeleteNotes(notes: state.note, index: index));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Notes Deleted Successfully')));
                  },
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UpdateNotesScreen(
                          index: index,
                          context: context,
                          content: notes.content,
                          title: notes.title,
                          date: notes.date),
                    ));
                  },
                  date: notes.date,
                  title: notes.title,
                  content: notes.content,
                );
              },
            );
          } else {
            return const Center(
                child: Text(
              'Oops something went wrong 😩',
              style: TextStyle(fontSize: 15, color: white),
            ));
          }
        },
      ),
    );
  }
}
