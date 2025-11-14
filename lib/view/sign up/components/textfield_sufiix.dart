import 'package:flutter/material.dart';

class TextFieldSufix extends StatelessWidget {
  const TextFieldSufix({super.key, required this.icon,this.size=18});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color shadowColor = scheme.primary.withOpacity(.3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors:[
                scheme.primary,
                scheme.secondary,
                scheme.primary,
              ]
            ),
            boxShadow:  [
              BoxShadow(
                  color: shadowColor,
                  offset: const Offset(1, 0)),
              BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 1)),
              BoxShadow(
                  color: shadowColor,
                  offset: const Offset(-1, 0)),
              BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, -1)),
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
