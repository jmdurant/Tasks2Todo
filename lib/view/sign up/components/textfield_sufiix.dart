import 'package:flutter/material.dart';

class TextFieldSufix extends StatelessWidget {
  const TextFieldSufix({super.key, required this.icon,this.size=18});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color shadowColor = scheme.primary.withValues(alpha: 0.3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: scheme.primary,
            boxShadow:  [
              BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ]),
        child:  Icon(
          icon,
          color: scheme.onPrimary,
          size: size,
        ),
      ),
    );
  }
}
