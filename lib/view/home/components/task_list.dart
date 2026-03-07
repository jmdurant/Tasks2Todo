import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view/home/components/task_detail_container.dart';
import 'package:todo/view_model/controller/home_controller.dart';
import 'package:todo/view_model/responsive.dart';
class TaskList extends StatelessWidget {
   const TaskList({super.key, required this.index});
   final int index;
  @override
  Widget build(BuildContext context) {
    return  Responsive(
        tablet: Grid(crossAsis: 2, ratio: 3,ind: index,),
        largeTablet: Grid(crossAsis: 3, ratio: 3,ind: index,),
        mobile: Grid(
          ratio: 3,
          crossAsis: 1,
          ind:index ,
        ));
  }
}



class Grid extends StatelessWidget {
  final int crossAsis;
  final double ratio;
 final int ind;
  final controller = Get.find<HomeController>();
   Grid({super.key, required this.crossAsis, required this.ratio, required this.ind});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filteredTasks = controller.filteredTasksForDay(ind);
      final hasFilters = controller.hasActiveFilters;

      if (filteredTasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasFilters ? 'No tasks match filters' : 'No tasks for this day',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => controller.resetFilters(),
                  icon: Icon(Icons.clear_all, size: 18, color: Theme.of(context).colorScheme.primary),
                  label: Text(
                    'Clear filters',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.only(top: 40),
        itemCount: filteredTasks.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAsis, childAspectRatio: ratio),
        itemBuilder: (context, index) {
          return TaskDetailContainer(
            index: index,
            ind: ind,
            filteredTasks: filteredTasks,
          );
        },
      );
    });
  }
}























