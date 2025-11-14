import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view/home/components/task_detail_col.dart';
import '../../../util/utils.dart';
import '../../../view_model/controller/home_controller.dart';

class TaskDetailContainer extends StatelessWidget {
  TaskDetailContainer({super.key, required this.index, required this.ind});
  final int index;
  final int ind;
  final  controller =Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      confirmDismiss: (direction) async{
       return await Utils.showWarningDialog(context, 'Remove Task', 'Are you sure to remove this task', 'Confirm', () {
         controller.db.delete(controller.list[ind][index].key, 'Tasks');
         controller.list[ind].remove(controller.list[ind][index]);
       });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            boxShadow:  [
              BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.2),
                  offset: const Offset(0, 5),
                  blurRadius: 10
              ),
            ],
            color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Image.asset(
              Utils.images[controller.list[ind][index].image],
              height: 100,
              width: 100,
            ),
            const Spacer(flex: 1,),
            TaskTitle(index: index, ind: ind),
            const Spacer(flex: 2,),
            controller.list[ind][index].status=='complete' ? Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ]
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(.4),
                        offset: const Offset(0, 10),
                        blurRadius: 10
                    )
                  ]
              ),
              child: Icon(Icons.done,color: Theme.of(context).colorScheme.onPrimary,),
            ):
             Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: PopupMenuButton(
                  onSelected:(value)=> controller.onTaskComplete(value, index, ind, controller.list[ind][index].key,context),
                  surfaceTintColor: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert_rounded,color: Theme.of(context).colorScheme.onSurfaceVariant,size: 24,),
                  shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,

                  ),
                  itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        height: 25,
                        value: 1,
                        child: Row(
                          children: [
                            Icon(Icons.edit_note,color: Theme.of(context).colorScheme.primary,size: 14,),
                            const SizedBox(width: 8,),
                            Text('Edit')
                          ],
                        )),
                    PopupMenuItem(
                        height: 25,
                        value: 2,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,color: Theme.of(context).colorScheme.primary,size: 14,),
                            const SizedBox(width: 8,),
                            Text('Delete')
                          ],
                        )),
                    PopupMenuItem(
                        height: 25,
                        value: 3,
                        child: Row(
                          children: [
                            Icon(Icons.done_all_outlined,color: Theme.of(context).colorScheme.primary,size: 14,),
                            const SizedBox(width: 8,),
                            Text('Complete')
                          ],
                        )),
                  ];
                },)
              ),
            ),

          ],
        ),
      ),
    );
  }
}


