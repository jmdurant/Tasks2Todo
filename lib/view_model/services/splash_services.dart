import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/view/home/home.dart';

import '../../view/sign up/sign_up.dart';
import '../controller/home_controller.dart';
import '../controller/new_task_controller.dart';

class SplashServices{
  static void checkLogin()async{
    SharedPreferences pref=await SharedPreferences.getInstance();
    String? uid=pref.getString('TOKEN');
    if(uid==null){
      Get.off(() => SignUp());
    }else{
      Get.put(HomeController());
      Get.put(NewTaskController());
      Get.off(() => HomePage());
    }
  }
}