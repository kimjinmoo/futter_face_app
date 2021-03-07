
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/container/main_screen.dart';
import 'package:flutter_face_app/empty_camera.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/service/api_service.dart';

final FirebaseMessaging messaging = FirebaseMessaging();

/// 스플래시 화면
class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SplashState();
}

class _SplashState extends State<Splash>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // 에러 여부
  bool onError = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/splash.jpg"),
                fit: BoxFit.cover)),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Text("1.0.0", style: TextStyle(color: Colors.white),),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void permission() async {
    await messaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }


  init() async {
    if (Platform.isIOS)  permission();
    ApiService.init(await messaging.getToken());
    // camera get
    List<CameraDescription> cameras = await availableCameras();
    // 지연
    await Future.delayed(const Duration(seconds: 2), () {});
    // 카메라 체크
    if (cameras.length < 1) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return EmptyCamera();
      }));
    }
    // 홈으로 이동
    if (!onError) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MainScreen(cameras: cameras)
          ),
          (route) => false);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return EmptyCamera();
      }));
    }
  }
}
