import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:scribble/src/core/utils/constants.dart';

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/empty_list.json'),
          Text(emptyPlaceHolder, style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
