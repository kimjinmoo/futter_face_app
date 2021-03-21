import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/utils/file_utils.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CameraImageEdit extends StatefulWidget {
  final XFile image;

  CameraImageEdit(this.image);

  @override
  State createState() {
    return CameraImageEditState();
  }
}

class CameraImageEditState extends State<CameraImageEdit> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isProgress = false;

  rotateImage() async {
    await FlutterExifRotation.rotateImage(path: widget.image.path);
    setState(() {});
  }

  void uploadImage() async {
    if (!isProgress) {
      setState(() {
        isProgress = true;
      });
      NoticeUtils.showSnackBarLongTime(
          _scaffoldKey, '사진을 업로드중입니다.\n분석서버 요청 후 창이 전환 됩니다.');
      File tempFile =
          await FileUtils.compressFile(imagePath: widget.image.path, compressRate: 70);
      User user = await ApiService.getUser();
      // 세로 모드 확인해야함
      var response = await ApiService.uploadImage(
          user: user,
          filePath: tempFile.path,
          fileName: path.basename(tempFile.path));
      if (response.statusCode == 200) {
        ImageEngineResponse result =
            ImageEngineResponse.fromJson(response.data);
        ApiService.insert(result);
        tempFile.delete(recursive: true);
        NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
        isProgress = false;
        Navigator.pop(context);
      } else {
        NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
        tempFile.delete(recursive: true);
        NoticeUtils.showSnackBar(
            _scaffoldKey, 'error ${response.statusMessage}');
        isProgress = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("뒤로가기"),
          // backgroundColor: Colors.transparent,
          elevation: 0,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(
                context,
                'OK',
              );
            },
          ),
        ),
        // backgroundColor: Colors.transparent,
        bottomNavigationBar: Container(
          height: 55,
          color: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: Center(
          child: widget.image == null
              ? Text(
                  "1. [갤러리 열기]로 이미지를 선택해주세요\n2. 업로드 후 이미지에 얼굴이 위로 가게 해주세요\n3. 분석 요청으로 애정도를 측정해보세요!",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                )
              : Image.file(File(widget.image.path), fit: BoxFit.contain),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          padding: EdgeInsets.only(left: 20, bottom: 10, right: 20),
          child: Stack(
            children: [
              widget.image == null
                  ? SizedBox()
                  : isProgress
                      ? SizedBox()
                      : Align(
                          alignment: Alignment.bottomLeft,
                          child: FloatingActionButton.extended(
                            heroTag: "rotate",
                            backgroundColor: Colors.green,
                            icon: Icon(Icons.rotate_right),
                            label: Text("회전(얼굴 맞춤)"),
                            onPressed: rotateImage,
                            tooltip: '얼굴이 위로 가게 해주세요.',
                          ),
                        ),
              widget.image == null
                  ? SizedBox()
                  : isProgress
                      ? SizedBox()
                      : Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton.extended(
                            heroTag: "requestImage",
                            backgroundColor: Colors.red,
                            icon: Icon(Icons.calculate),
                            label: Text("분석 요청"),
                            onPressed: uploadImage,
                            tooltip: '분석 요청',
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
