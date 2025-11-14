import 'package:flutter/material.dart';

class PeriorityContainer extends StatelessWidget {
  final String text;
  final bool selected;

  const PeriorityContainer(
      {super.key, required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(selected ? 3 : 0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: selected ? scheme.primary : scheme.surfaceVariant),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.onPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? scheme.primary : scheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
