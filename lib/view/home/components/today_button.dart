import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view_model/controller/home_controller.dart';

class TodayButton extends StatelessWidget {
  const TodayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller=Get.put(HomeController());
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => controller.pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeIn),
      child: Container(
        height: 50,
        width: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow:  [
              BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(.35),
                  offset: const Offset(0, 5),
                  blurRadius: 20
              )
            ],
            gradient:  LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.primary
                ]
            )
        ),
        child:  Text(
          'Today',style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
        ),
      ),
    );
  }
}
