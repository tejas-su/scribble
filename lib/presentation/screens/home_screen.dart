import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/presentation/screens/settings_screen.dart';
import '../../cubit/page_view_cubit.dart';
import 'notes_screen.dart';
import 'todo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PageController? controller = PageController();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleSpacing: 20,
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
                      controller.nextPage(
                          duration: Durations.medium1, curve: Easing.linear);
                    },
                    icon: const Icon(Icons.today_rounded));
              } else {
                return IconButton(
                    onPressed: () {
                      context.read<PageViewCubit>().togglePage(0);
                      controller.previousPage(
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
        ],
      ),
      body: PageView(
        controller: controller,
        onPageChanged: (value) {
          context.read<PageViewCubit>().togglePage(value);
        },
        children: [NotesScreen(), TodoScreen()],
      ),
    );
  }
}
