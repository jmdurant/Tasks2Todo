import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/utils.dart';
import '../../../view_model/controller/home_controller.dart';

class TaskTitle extends StatelessWidget {
  TaskTitle({super.key, required this.index, required this.ind});
  final int index;
  final int ind;
  final int randomColor1=Random().nextInt(9);
  final int randomColor2=Random().nextInt(9);
  final  controller =Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final List<Color> palette = Utils.tagColors(context);
    final Color colorOne = palette[randomColor1 % palette.length];
    final Color colorTwo = palette[randomColor2 % palette.length];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         Text(
          controller.list[ind][index].title,
          style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '${controller.list[ind][index].startTime} - ${controller.list[ind][index].endTime}',
          style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 10,),
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 10),
              decoration: BoxDecoration(
                color: colorOne.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Text(
                Utils.tags[Random().nextInt(13)],
                style: TextStyle(color: colorOne, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10,),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 10),
              decoration: BoxDecoration(
                  color: colorTwo.withOpacity(.2),
                  borderRadius: BorderRadius.circular(10)
              ),
              child:  Text(
                Utils.tags[Random().nextInt(13)],
                style: TextStyle(color: colorTwo, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ],
    );
  }
}
