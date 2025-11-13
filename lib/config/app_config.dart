class AppConfig {
  static const bool firebaseAvailable =
      bool.fromEnvironment('USE_FIREBASE', defaultValue: false);
}
