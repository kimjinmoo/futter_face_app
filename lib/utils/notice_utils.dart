import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoticeUtils {
  static void showSnackBar(
      GlobalKey<ScaffoldState> _scaffoldKey, String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  static void showSnackBarLongTime(
      GlobalKey<ScaffoldState> _scaffoldKey, String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(minutes: 1),
    ));
  }

  static void hideSnackBarLongTime(GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
  }
}
