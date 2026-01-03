import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../util/utils.dart';
import '../../../view_model/controller/home_controller.dart';

class Dates extends StatelessWidget {
  const Dates({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final date = DateTime.now().add(Duration(days: index));

    return Obx(() {
      final bool isSelected = controller.currentIndex.value == index;
      final Color textColor = isSelected ? Colors.white : Colors.black;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Utils.getMonth(date),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              height: 0,
            ),
          ),
          Text(
            Utils.getDate(date),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              height: 0,
            ),
          ),
          Text(
            Utils.getDay(date),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      );
    });
  }
}