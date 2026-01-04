import 'package:flutter/material.dart';
import 'package:todo/view/home/components/task_page_view.dart';

import 'change_button_roe.dart';

class TaskPageBody extends StatelessWidget {
  const TaskPageBody({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: Container(
              margin: const EdgeInsets.only(top: 25),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40)),
                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
              child:  TaskPageView(),
            )),
        ChangeButtonRow(),
      ],
    );
  }
}