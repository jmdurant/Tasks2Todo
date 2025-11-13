import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../data/local/local_auth_service.dart';
import '../../data/network/firebase/firebase_services.dart';
import '../../util/utils.dart';
import '../../view/home/home.dart';
import 'settings_controller.dart';


class SignInController extends GetxController{
  RxBool emailFocus=false.obs;
  RxBool passwordFocus=false.obs;
  RxBool correctEmail=false.obs;
  RxBool showPassword=true.obs;
  RxBool loading=false.obs;
  final email=TextEditingController().obs;
  final password=TextEditingController().obs;
  final SettingsController settingsController =
      Get.find<SettingsController>();


  void loginAccount(){
    if(!correctEmail.value){
      Utils.showSnackBar('Warning', 'Enter Correct Email', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    if(password.value.text.toString().length<6){
      Utils.showSnackBar('Warning', 'Password length should greater than 5', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }

    if (settingsController.useLocalOnly.value) {
      _loginLocally();
      return;
    }

    FirebaseService.loginAccount();

  }
  void setLoading(bool value){
    loading.value=value;
  }
  void validateEmail(){
    correctEmail.value=Utils.validateEmail(email.value.text.toString());
  }
  void onFocusEmail(){
    emailFocus.value=true;
    passwordFocus.value=false;
  }
  void onFocusPassword(){
    emailFocus.value=false;
    passwordFocus.value=true;
  }
  void onTapOutside(BuildContext context){
    emailFocus.value=false;
    passwordFocus.value=false;
    FocusScope.of(context).unfocus();
}

  Future<void> _loginLocally() async {
    setLoading(true);
    final String? error = await LocalAuthService.login(
      email: email.value.text.trim(),
      password: password.value.text.trim(),
    );
    setLoading(false);
    if (error != null) {
      Utils.showSnackBar(
          'Error',
          error,
          const Icon(
            FontAwesomeIcons.triangleExclamation,
            color: Colors.pink,
          ));
      return;
    }
    Utils.showSnackBar(
        'Login',
        'Welcome back! (Offline mode)',
        const Icon(
          Icons.done,
          color: Colors.white,
        ));
    Get.to(HomePage());
  }
}
