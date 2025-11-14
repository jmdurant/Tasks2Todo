import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:todo/view_model/responsive.dart';

class BackColors extends StatelessWidget {
  const BackColors({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<Color> primaryRamp = _gradientRamp(scheme.primary);
    final List<Color> secondaryRamp = _gradientRamp(scheme.secondary);
    final List<Color> tertiaryRamp =
        _gradientRamp(scheme.tertiary);
    final List<Color> surfaceRamp =
        _gradientRamp(scheme.primaryContainer.withOpacity(.8));

    return Container(
      color: scheme.surface,
      margin: const EdgeInsets.only(top: 30),
      child: Stack(
        children: [
          Positioned(
            top: 100,
            child: Container(
              height: size.height * 0.5,
              width: size.width * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: primaryRamp,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -50,
            child: Container(
              height: size.height * 0.5,
              width: size.width * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: primaryRamp,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              height: size.height * 0.5,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: secondaryRamp,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            child: Container(
              height: size.height * 0.3,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: secondaryRamp,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            left: 1,
            top: !Responsive.isTablet(context) ? 100 : 200,
            right: 1,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: tertiaryRamp,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              height: size.height * 0.3,
              width: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: surfaceRamp,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 30, sigmaX: 30),
              child: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> _gradientRamp(Color base) {
  const List<double> opacities = <double>[0, .1, .2, .3, .4, .4, .3, .2, .1, 0];
  return opacities.map((double o) => base.withOpacity(o)).toList();
}
