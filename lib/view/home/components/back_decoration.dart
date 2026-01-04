import 'package:flutter/material.dart';

class BackColors extends StatelessWidget {
  const BackColors({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surface,
    );
  }
}
