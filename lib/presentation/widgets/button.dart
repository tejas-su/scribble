import 'package:flutter/material.dart';
import '/presentation/themes/themes.dart';

class NavButton extends StatelessWidget {
  final Function()? onTap;
  final Widget? icon;
  final double height;
  final double width;
  const NavButton(
      {super.key,
      required this.icon,
      this.height = 50,
      this.width = 50,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            color: grey, borderRadius: BorderRadius.all(Radius.circular(10))),
        child: icon,
      ),
    );
  }
}
