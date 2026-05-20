import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/config/app_config.dart';
import 'package:todo/view/home/home.dart';

import '../../view/sign up/sign_up.dart';

class SplashServices {
  static void checkLogin() async {
    if (!AppConfig.firebaseAvailable) {
      Get.off(() => HomePage());
      return;
    }
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final String? uid = pref.getString('UID');
    if (uid == null || uid.isEmpty) {
      Get.off(() => SignUp());
    } else {
      Get.off(() => HomePage());
    }
  }
}
