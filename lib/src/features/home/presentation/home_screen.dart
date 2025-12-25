import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scribble/src/features/home/presentation/widgets/scribble_appbar.dart';
import 'package:scribble/src/features/home/presentation/widgets/scribble_drawer.dart';
import 'bloc/page_view_cubit.dart';
import '../../notes/presentation/screen/notes_screen.dart';
import '../../todos/presentation/screen/todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController pageController;
  late ValueNotifier<int> pageNotifier;
  @override
  initState() {
    super.initState();
    pageController = PageController();
    pageNotifier = ValueNotifier<int>(0);
    pageNotifier.value = 0;
  }

  @override
  void dispose() {
    pageController.dispose();
    pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ScribbleDrawer(
        pageController: pageController,
        pageNotifier: pageNotifier,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: scribbleAppBar(context),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (value) =>
            context.read<PageViewCubit>().togglePage(value),
        children: [NotesScreen(), TodoScreen()],
      ),
    );
  }
}
