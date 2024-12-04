import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/presentation/screens/settings_screen.dart';
import 'notes_screen.dart';
import 'secret_login_screen.dart';
import 'todo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          titleSpacing: 20,
          title: GestureDetector(
            onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SecretLoginScreen(),
            )),
            child: Text(
              'scribble',
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ));
                },
                icon: const Icon(Icons.settings_rounded)),
          ],
        ),
        body: PageView(
          children: [NotesScreen(), TodoScreen()],
        ));
  }
}
