import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:todo/view/sign%20up/components/textfield_sufiix.dart';

import '../../../view_model/controller/signin_controller.dart';
import '../../../view_model/controller/signup_controller.dart';

class InputField extends StatelessWidget {
  InputField(
      {super.key,
      required this.onTap,
      required this.focus,
      required this.hint,
      required this.controller,
      this.correct,
      required this.onChange,
      this.hideText,
      this.showPass,
      this.prefix
      });

  final bool focus;
  final String hint;
  final TextEditingController controller;
  final VoidCallback onTap;
  final VoidCallback onChange;
  final VoidCallback? showPass;
  final bool? hideText;
  final bool? correct;
  final Widget? prefix;
  final _signUpController = Get.put(SignupController());
  final _signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.all(focus ? 2 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: focus ? scheme.primary : null,
      ),
      child: TextFormField(
        controller: controller,
        onTap: onTap,
        onTapOutside: (event) {
          _signUpController.onTapOutside(context);
          _signInController.onTapOutside(context);
        },
        onChanged: (value) {
          onChange();
        },
        obscureText: hideText ?? false,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        decoration: InputDecoration(
          filled: true,
          prefixIcon: prefix,
          suffixIcon: hideText == null
              ? correct == true
                  ? const TextFieldSufix(
                      icon: Icons.done,
                    )
                  : null
              : _signUpController.password.value.text.toString().isNotEmpty
                  ? GestureDetector(
                      onTap: showPass,
                      child: hideText!
                          ? const TextFieldSufix(
                              icon: FontAwesomeIcons.eye,
                              size: 13,
                            )
                          : const TextFieldSufix(
                              icon: FontAwesomeIcons.eyeLowVision,
                              size: 13,
                            ),
                    )
                  : const SizedBox(),
          fillColor: scheme.surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          hoverColor: scheme.primary.withValues(alpha: 0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          hintText: hint,
          hintStyle: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.normal, fontSize: 12),
        ),
      ),
    );
  }
}
