import 'package:flutter/material.dart';

class ChangeIconButton extends StatelessWidget {
  const ChangeIconButton({super.key, required this.icon});
  final Widget icon;
  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return  Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.secondary,
          boxShadow: [
            BoxShadow(
                color: scheme.secondary.withOpacity(.3),
                offset: const Offset(0, 10),
                blurRadius: 10
            )
          ]
      ),
      child: icon,
    );
  }
}
