import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final Widget widget;
  const IconContainer({super.key, required this.widget});
  @override
  Widget build(BuildContext context) {
    var size=MediaQuery.sizeOf(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color borderColor = scheme.primary;
    final Color shadowColor = scheme.primary.withOpacity(.3);
    return Container(
      height: 60,
      width: size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: scheme.surface,
        border: Border.all(
          color: borderColor,
        ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                offset: const Offset(1,0)
            ),
            BoxShadow(
                color: shadowColor,
                offset: const Offset(0,1)
            ),
            BoxShadow(
                color: shadowColor,
                offset: const Offset(-1,0)
            ),
            BoxShadow(
                color: shadowColor,
                offset: const Offset(0,-1)
            ),
          ]
      ),
      child: widget,
    );
  }
}
