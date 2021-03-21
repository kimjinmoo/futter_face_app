import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/utils/file_utils.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  GlobalKey _globalKey = new GlobalKey();
  int rotate = 0;
  bool isRequest = false;

  rotateImage() async {
    setState(() {
      rotate += 90;
      if (rotate >= 360) rotate = 0;
    });
  }

  void uploadImage() async {
    if (!isRequest) {
      setState(() {
        this.isRequest = true;
      });
      NoticeUtils.showSnackBarLongTime(_scaffoldKey, '잠시 기다려주세요...사진을 분석중입니다.');
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      file.writeAsBytesSync(await FileUtils.capturePng(_globalKey));
      // temp file
      final tempFile =
          await FileUtils.compressFile(imagePath: file.path, compressRate: 50);

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
        tempFile.delete();
        file.delete(recursive: true);
        NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
        Navigator.pop(context);
      } else {
        setState(() {
          this.isRequest = false;
        });
        NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
        tempFile.delete();
        file.delete(recursive: true);
        NoticeUtils.showSnackBar(
            _scaffoldKey, 'error ${response.statusMessage}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldKey,
        // backgroundColor: Colors.transparent,
        bottomNavigationBar: Container(
          height: 55,
          color: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: widget.image == null
                    ? Text(
                        "1. [갤러리 열기]로 이미지를 선택해주세요\n2. 업로드 후 이미지에 얼굴이 위로 가게 해주세요\n3. 분석으로 애정도를 측정해보세요!",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      )
                    : RepaintBoundary(
                        key: _globalKey,
                        child: RotationTransition(
                            turns: new AlwaysStoppedAnimation(rotate / 360),
                            child: Image.file(
                              File(widget.image.path),
                              fit: BoxFit.contain,
                            )),
                      ),
              ),
              Align(
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "분석하는 인물을 정상적으로 맞춰주세요.\n확인 되면 분석을 클릭하세요!",
                    style: TextStyle(
                        backgroundColor: Colors.black26,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ),
              isRequest?LinearProgressIndicator(
                backgroundColor: Colors.pink,
              ):SizedBox(),
              Positioned(
                child: AppBar(
                  title: Text("뒤로가기"),
                  backgroundColor: Colors.transparent,
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
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          padding: EdgeInsets.only(left: 20, bottom: 10, right: 20),
          child: Stack(
            children: [
              widget.image == null
                  ? SizedBox()
                  : Align(
                      alignment: Alignment.center,
                      child: FloatingActionButton.extended(
                        heroTag: "rotate",
                        backgroundColor: Colors.green,
                        icon: Icon(Icons.rotate_right),
                        label: Text("회전"),
                        onPressed: rotateImage,
                        tooltip: '얼굴이 위로 가게 해주세요.',
                      ),
                    ),
              widget.image == null
                  ? SizedBox()
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton.extended(
                        heroTag: "requestImage",
                        backgroundColor: Colors.red,
                        icon: Icon(Icons.calculate),
                        label: Text("분석"),
                        onPressed: () {
                          uploadImage();
                        },
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
