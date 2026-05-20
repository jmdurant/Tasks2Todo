import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../util/utils.dart';
import '../../../view/home/home.dart';
import '../../../view_model/controller/signin_controller.dart';
import '../../../view_model/controller/signup_controller.dart';
import '../../shared pref/shared_pref.dart';

void _navigateToHome() {
  Get.off(() => HomePage());
}

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseDatabase database = FirebaseDatabase.instance;

  /// Profile node for the signed-in user. Keyed by Firebase Auth uid — *never*
  /// by email-prefix (which collides across domains and breaks on dotted
  /// locals).
  static DatabaseReference _profileRef(String uid) =>
      database.ref('Accounts').child(uid);

  /// Task storage node for the signed-in user.
  static DatabaseReference _tasksRef(String uid) =>
      database.ref('Tasks').child(uid);

  static Future<void> createAccount() async {
    final SignupController signUpController = Get.find<SignupController>();
    signUpController.setLoading(true);
    final String email = signUpController.email.value.text.trim();
    final String name = signUpController.name.value.text.trim();
    final String password = signUpController.password.value.text;

    try {
      final UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User user = cred.user!;
      await _profileRef(user.uid).set(<String, Object?>{
        'name': name,
        'email': email,
      });
      await UserPref.setUser(
        name: name,
        email: email,
        uid: user.uid,
        token: await user.getIdToken() ?? '',
      );
      Utils.showSnackBar(
        'Sign up',
        'Account is successfully created',
        const Icon(Icons.done, color: Colors.white),
      );
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(
        'Error',
        e.message ?? 'Sign up failed',
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
      );
    } catch (e) {
      Utils.showSnackBar(
        'Error',
        Utils.extractFirebaseError(e.toString()),
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
      );
    } finally {
      signUpController.setLoading(false);
    }
  }

  static Future<void> loginAccount() async {
    final SignInController signInController = Get.find<SignInController>();
    signInController.setLoading(true);
    final String email = signInController.email.value.text.trim();
    final String password = signInController.password.value.text;

    try {
      final UserCredential cred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User user = cred.user!;
      final DataSnapshot snap = await _profileRef(user.uid).get();
      final String displayName =
          snap.child('name').value?.toString() ?? user.displayName ?? email;
      await UserPref.setUser(
        name: displayName,
        email: snap.child('email').value?.toString() ?? email,
        uid: user.uid,
        token: await user.getIdToken() ?? '',
      );
      Utils.showSnackBar(
        'Sign in',
        'Successfully logged in. Welcome back!',
        const Icon(Icons.done, color: Colors.white),
      );
      _navigateToHome();
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(
        'Error',
        e.message ?? 'Sign in failed',
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
      );
    } catch (e) {
      Utils.showSnackBar(
        'Error',
        Utils.extractFirebaseError(e.toString()),
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
      );
    } finally {
      signInController.setLoading(false);
    }
  }

  static Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: const <String>['email']);
      final GoogleSignInAuthentication authentication = account.authentication;
      if (authentication.idToken == null) {
        Utils.showSnackBar(
          'Error',
          'Unable to fetch credentials from Google. Please try again.',
          const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
        );
        return;
      }
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null || user.email == null) {
        Utils.showSnackBar(
          'Error',
          'Google account is missing required information.',
          const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
        );
        return;
      }
      final String email = user.email!;
      final String name =
          user.displayName ?? account.displayName ?? email;
      await _profileRef(user.uid).set(<String, Object?>{
        'name': name,
        'email': email,
      });
      await UserPref.setUser(
        name: name,
        email: email,
        uid: user.uid,
        token: await user.getIdToken() ?? '',
      );
      Utils.showSnackBar(
        'Login',
        'Successfully logged in with Google.',
        const Icon(Icons.done, color: Colors.white),
      );
      _navigateToHome();
    } on GoogleSignInException catch (error) {
      Utils.showSnackBar(
        'Error',
        error.description ?? 'Google sign-in was cancelled.',
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
      );
    } catch (e) {
      Utils.showSnackBar(
        'Error',
        Utils.extractFirebaseError(e.toString()),
        const Icon(FontAwesomeIcons.triangleExclamation, color: Colors.red),
      );
    }
  }

  static Future<void> signInWithApple() async {}

  /// Total task count for the signed-in user.
  static Future<int> childCount() async {
    final User? user = auth.currentUser;
    if (user == null) return 0;
    final snap = await _tasksRef(user.uid).get();
    return snap.children.length;
  }

  /// Update a single field on a task in the cloud.
  static Future<void> update(
      String key, String updateKey, String updateValue) async {
    final User? user = auth.currentUser;
    if (user == null) return;
    await _tasksRef(user.uid).child(key).update(<String, Object?>{
      updateKey: updateValue,
    });
  }
}
