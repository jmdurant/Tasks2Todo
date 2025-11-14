import 'package:flutter/material.dart';

import '../../sign in/components/back_button.dart';
class SignUpBar extends StatelessWidget {
  const SignUpBar({super.key});
  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ) ?? const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    return  Row(
      children: [
        const CustomBackButton(),
        const SizedBox(
          width: 20,
        ),
        Text(
          'Sign up',
          style: titleStyle,
        )
      ],
    );
  }
}
