import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  final Widget? child;
  const CustomBackButton({
    super.key,
    this.width = 40,
    this.height = 40,
    this.radius = 12,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget content = child ??
        Icon(
          Icons.arrow_back_ios_new_rounded,
          color: scheme.onPrimary,
          size: 18,
        );
    final List<Color> gradientColors = <Color>[
      scheme.primary,
      scheme.secondary,
    ];
    final Color shadowColor = scheme.primary.withOpacity(.25);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(1, 0)),
          BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 1)),
          BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(-1, 0)),
          BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, -1)),
        ],
      ),
      child: content,
    );
  }
}
