import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyCamera extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Text("카메라가 없습니다."),
      ),
    );
  }
}