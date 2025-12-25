import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scribble/src/features/notes/presentation/widgets/notes_card.dart';
import 'package:scribble/src/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shimmer/shimmer.dart';

class NotesLoadingScreen extends StatelessWidget {
  final int itemCount;
  const NotesLoadingScreen({super.key, this.itemCount = 15});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).cardColor.withAlpha(255),
      highlightColor: Theme.of(context).cardColor.withAlpha(1),
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: context.watch<SettingsCubit>().state.isGrid ? 2 : 1,
        ),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.all(18),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return const NotesCard(onTap: null);
        },
      ),
    );
  }
}
