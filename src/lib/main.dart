import 'package:flutter/widgets.dart';
import 'package:vocabulary_advancer/app/base/va_app.dart';
import 'package:vocabulary_advancer/shell/bootstrapper.dart';
import 'package:vocabulary_advancer/shell/environment.dart';

void main() {
  setupApp(profile: Profile.dev);
  runApp(VAApp());
}
