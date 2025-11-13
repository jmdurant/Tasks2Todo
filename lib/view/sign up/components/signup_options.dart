import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../data/network/firebase/firebase_services.dart';
import '../../../view_model/controller/settings_controller.dart';
import 'icon_container.dart';

class SignUpOptions extends StatelessWidget {
  SignUpOptions({super.key});

  final SettingsController settingsController =
      Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!settingsController.firebaseAvailable) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: const Text(
            'Firebase disabled in this build. Enable USE_FIREBASE to sign in with Google.',
            textAlign: TextAlign.center,
          ),
        );
      }
      if (settingsController.useLocalOnly.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: const Text(
            'Enable cloud sync to use Google sign-in.',
            textAlign: TextAlign.center,
          ),
        );
      }
      return GestureDetector(
        onTap: () => FirebaseService.signInWithGoogle(),
        child: const IconContainer(
            widget: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                FontAwesomeIcons.google,
                  size: 18,
                  color: Colors.orange,
                ),
                SizedBox(width: 10,),
                Text('Continue with Google'),
              ],
            )),
      );
    });
  }
}
