import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/utils/file_utils.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageUpload extends StatefulWidget {
  @override
  State createState() {
    return ImageUploadState();
  }
}

class ImageUploadState extends State<ImageUpload> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isProgress = false;

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {});
      } else {
        print('이미지가 없음');
      }
    });
  }

  void uploadImage() async {
    if (!isProgress) {
      setState(() {
        isProgress = true;
      });
      NoticeUtils.showSnackBarLongTime(
          _scaffoldKey, '잠시만 기다려주세요..사진을 확인하고 있습니다.');
      File tempFile = await FileUtils.compressFile(
          imagePath: _image.path, compressRate: 80);
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
    return Scaffold(
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
            Center(
              child: _image == null
                  ? Text(
                      "1. [갤러리]로 이미지를 선택해주세요\n2. 업로드 이미지를 확인하세요.\n3. 분석을 눌러 애정도를 측정해보세요!",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                    )
                  : Image.file(
                      _image,
                      fit: BoxFit.contain,
                    ),
            ),
            isProgress?LinearProgressIndicator(
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
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.only(left: 20, bottom: 10, right: 20),
        child: Stack(
          children: [
            isProgress
                ? SizedBox()
                : Align(
                    alignment: Alignment.bottomLeft,
                    child: FloatingActionButton.extended(
                      heroTag: "upload",
                      backgroundColor: Colors.black,
                      icon: Icon(Icons.add_a_photo_outlined),
                      label: Text("갤러리"),
                      onPressed: getImage,
                      tooltip: '이미지 불러오기',
                    ),
                  ),
            _image == null
                ? SizedBox()
                : isProgress
                    ? SizedBox()
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                          heroTag: "requestImage",
                          backgroundColor: Colors.red,
                          icon: Icon(Icons.calculate),
                          label: Text("분석"),
                          onPressed: uploadImage,
                          tooltip: '분석',
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
