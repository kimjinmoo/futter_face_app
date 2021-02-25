import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/splash.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TYO',
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColorBrightness: Brightness.dark,
        brightness: Brightness.light,
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: Splash(),
    );
  }
}

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } on CameraException catch (e) {
    print(e.description);
  }
  runApp(App());
}
