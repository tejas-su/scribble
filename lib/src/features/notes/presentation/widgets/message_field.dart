import 'package:flutter/material.dart';

class MessageField extends StatelessWidget {
  ///Hint text to be sghown in the input field
  final String? prompt;

  ///The text editing controller to handle the input text
  final TextEditingController? controller;

  ///To handle the function when pressed on the icon
  final Function()? onSubmitted;

  ///The icon to be showed in the trailing part of the text field
  ///Defaults to the add icon
  final IconData? icon;

  ///To handle the input data, mainly to validate or submit the data
  final Function(String)? onComplete;

  ///Optional keyboard type
  final TextInputType? keyboardType;

  ///Defaults to false, used to obscure the text, maily for password or case sensitive
  ///fields
  final bool obscureText;

  ///Size of the trailing icon in the text field
  ///Defaults to 30
  final double? iconSize;

  ///Max lines use this carefully, for multiple lines or any other
  ///Make sure defien max and min lines to 1 if using the obscure text =true
  final int? maxLines;
  final int? minLines;

  ///Padding of the text field defaults to 8px
  final double padding;

  ///Text to be shown when there is an error
  final String? errorText;

  /// To open the keyboard automatically whenever the textfield is called or appears
  final bool autofocus;

  /// Label text
  final String? labelText;

  ///Validator: Function(String?)? validator
  final String? Function(String?)? validator;
  const MessageField({
    this.validator,
    this.errorText,
    this.labelText,
    this.autofocus = false,
    this.onComplete,
    this.keyboardType,
    super.key,
    this.padding = 8,
    this.iconSize = 30,
    this.maxLines,
    this.minLines,
    this.icon = Icons.add_rounded,
    this.obscureText = false,
    required this.controller,
    this.onSubmitted,
    this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: TextFormField(
        keyboardAppearance: Theme.of(context).brightness,
        autofocus: autofocus,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        enableInteractiveSelection: true,
        enableSuggestions: true,
        autocorrect: true,
        validator: validator,
        onFieldSubmitted: onComplete,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
            labelStyle: TextStyle(fontSize: 20),
            labelText: labelText,
            contentPadding: const EdgeInsets.all(20),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            hintText: prompt,
            hintStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                gapPadding: 30,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            suffixIcon: GestureDetector(
              onTap: onSubmitted,
              child: Icon(icon),
            ),
            errorText: errorText,
            errorStyle: TextStyle(fontSize: 15)),
      ),
    );
  }
}
