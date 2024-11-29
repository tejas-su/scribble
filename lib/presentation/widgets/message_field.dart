import 'package:flutter/material.dart';
import 'package:scribble/presentation/themes/themes.dart';

class MessageField extends StatelessWidget {
  final String prompt;
  final TextEditingController? controller;
  final Function()? onSubmitted;
  const MessageField(
      {super.key,
      required this.controller,
      required this.onSubmitted,
      required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        controller: controller,
        minLines: 1,
        maxLines: 2,
        enableInteractiveSelection: true,
        enableSuggestions: true,
        autocorrect: true,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          hintText: prompt,
          hintStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              gapPadding: 30,
              borderRadius: BorderRadius.all(Radius.circular(15))),
          suffixIcon: IconButton(
            iconSize: 30,
            onPressed: onSubmitted,
            icon: const Icon(
              Icons.add_rounded,
            ),
          ),
        ),
      ),
    );
  }
}
