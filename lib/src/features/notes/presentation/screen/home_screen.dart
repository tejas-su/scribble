import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scribble/src/features/settings/presentation/screen/settings_screen.dart';
import '../bloc/page_view_cubit.dart';
import 'notes_screen.dart';
import '../../../todos/presentation/screen/todo_screen.dart';

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
    List<Map<String, dynamic>> options = [
      {
        "name": "Notes",
        "icon": Icon(Icons.lightbulb_outline, size: 22),
      },
      {
        "name": "Todo's",
        "icon": Icon(Icons.notifications_outlined, size: 22),
      },
      {
        "name": "Archive",
        "icon": Icon(Icons.archive_outlined, size: 22),
      },
      {
        "name": "Hidden",
        "icon": Icon(Icons.fingerprint_outlined, size: 22),
      },
      {
        "name": "Deleted",
        "icon": Icon(Icons.delete_outline, size: 22),
      },
      {
        "name": "Settings",
        "icon": Icon(Icons.settings_outlined, size: 22),
      },
    ];
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Title
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Text(
                  'scribble',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
              //Options
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    var option = options[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          spacing: 5,
                          children: [
                            option["icon"],
                            Text(
                              option["name"],
                              style: GoogleFonts.inter(
                                color: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.color,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        // titleSpacing: 20,
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, size: 28));
        }),
        centerTitle: true,
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
