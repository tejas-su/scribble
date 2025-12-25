import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

AppBar scribbleAppBar(BuildContext context) {
  return AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: const Icon(Icons.menu_rounded, size: 24),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
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
      );
}