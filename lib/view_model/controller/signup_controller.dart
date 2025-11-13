import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../data/local/local_auth_service.dart';
import '../../data/network/firebase/firebase_services.dart';
import '../../util/utils.dart';
import 'settings_controller.dart';

class SignupController extends GetxController{
  RxBool nameFocus=false.obs;
  RxBool emailFocus=false.obs;
  RxBool passwordFocus=false.obs;
  RxBool correctEmail=false.obs;
  RxBool correctName=false.obs;
  RxBool showPassword=true.obs;
  RxBool loading=false.obs;
  final email=TextEditingController().obs;
  final name=TextEditingController().obs;
  final password=TextEditingController().obs;
  final SettingsController settingsController =
      Get.find<SettingsController>();
  void validateEmail(){
    correctEmail.value=Utils.validateEmail(email.value.text.toString());
  }
  void validateName(){
    correctName.value=name.value.text.toString().length>5;
  }
  void setLoading(bool value){
    loading.value=value;
  }
  void createAccount(){
    if(!correctName.value){
      Utils.showSnackBar('Warning', 'Enter Correct Name', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    if(!correctEmail.value){
      Utils.showSnackBar('Warning', 'Enter Correct Email', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    if(password.value.text.toString().length<6){
      Utils.showSnackBar('Warning', 'Password length should greater than 5', const Icon(FontAwesomeIcons.triangleExclamation,color: Colors.pink,));
      return;
    }
    if (settingsController.useLocalOnly.value) {
      _createLocalAccount();
      return;
    }
    FirebaseService.createAccount();
  }

  void onFocusEmail(){
    emailFocus.value=true;
    nameFocus.value=false;
    passwordFocus.value=false;
  }
  void onFocusName(){
    emailFocus.value=false;
    nameFocus.value=true;
    passwordFocus.value=false;
  }
  void onFocusPassword(){
    emailFocus.value=false;
    nameFocus.value=false;
    passwordFocus.value=true;
  }
  void onTapOutside(BuildContext context){
    emailFocus.value=false;
    nameFocus.value=false;
    passwordFocus.value=false;
    FocusScope.of(context).unfocus();
  }
  Future<void> _createLocalAccount() async {
    setLoading(true);
    await LocalAuthService.createAccount(
      name: name.value.text.trim(),
      email: email.value.text.trim(),
      password: password.value.text.trim(),
    );
    setLoading(false);
  }
}
