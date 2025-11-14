import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view_model/controller/home_controller.dart';
import 'dates.dart';
class DateContainer extends StatelessWidget {
  final int index;
  DateContainer({super.key, required this.index});
  final controller=Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color fallbackShadow = theme.shadowColor;
    var size=MediaQuery.sizeOf(context);
    return Obx(() {
      final bool isSelected = controller.currentIndex.value==index;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
          height: 110,
          width: 70,
          margin:  EdgeInsets.only(left: size.width*0.05),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.primary,
                        scheme.secondary,
                      ],
                    )
                  : null,
              color: isSelected ? null : scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? scheme.primary.withOpacity(.35)
                      : fallbackShadow.withOpacity(.08),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ]
          ),
          child: Dates(index: index)
      );
    });
  }
}
