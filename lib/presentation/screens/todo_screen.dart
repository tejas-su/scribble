import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/presentation/widgets/message_field.dart';
import 'package:scribble/presentation/widgets/todo_card.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        titleSpacing: 20,
        foregroundColor: Theme.of(context).appBarTheme.backgroundColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: null,
        title: Text(
          'scribble',
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              padding: const EdgeInsets.all(15),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TodoCard(
                      date: 'Nov,$index, Sunday',
                      todo: 'Test Todo UI',
                    ));
              },
            ),
          ),
          MessageField(
              controller: controller,
              onSubmitted: null,
              prompt: 'Write your TODO')
        ],
      ),
    );
  }
}
