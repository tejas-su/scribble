import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/src/features/home/presentation/bloc/page_view_cubit.dart';
import 'package:scribble/src/features/settings/presentation/screen/settings_screen.dart';
import 'features/notes/presentation/screen/notes_screen.dart';
import 'features/todos/presentation/screen/todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController pageController;
  @override
  initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'scribble',
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        actions: [
          BlocBuilder<PageViewCubit, int>(
            builder: (context, page) {
              if (page == 0) {
                return IconButton(
                    onPressed: () {
                      context.read<PageViewCubit>().togglePage(1);
                      pageController.nextPage(
                          duration: Durations.medium1, curve: Easing.linear);
                    },
                    icon: const Icon(Icons.today_rounded));
              } else {
                return IconButton(
                    onPressed: () {
                      context.read<PageViewCubit>().togglePage(0);
                      pageController.previousPage(
                          duration: Durations.medium1, curve: Easing.linear);
                    },
                    icon: const Icon(Icons.edit_rounded));
              }
            },
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ));
              },
              icon: const Icon(Icons.settings_rounded)),
          SizedBox(width: 8)
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) =>
            context.read<PageViewCubit>().togglePage(value),
        children: [NotesScreen(), TodoScreen()],
      ),
    );
  }
}
