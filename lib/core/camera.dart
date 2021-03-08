import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:image/image.dart' as img;

class CameraHome extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraHome(this.cameras);

  @override
  _CameraHomeState createState() {
    return _CameraHomeState();
  }
}

class _CameraHomeState extends State<CameraHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // 기본값 Set
  CameraController controller;
  XFile imageFile;

  double _minAvailableZoom;
  double _maxAvailableZoom;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  int _pointers = 0;

  bool isProgress = false;
  bool isFront = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(widget.cameras);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(widget.cameras);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _fab() {
    return Stack(
      children: [
        Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              heroTag: "btn_take1",
              child: Icon(Icons.flip_camera_android),
              backgroundColor: Colors.blue,
              onPressed: () {
                onNewCameraSelected(widget.cameras);
                setState(() {});
              },
            )
            // FloatingActionButton.extended(
            //   heroTag: "btn_take1",
            //   icon: Icon(Icons.flip_camera_android),
            //   backgroundColor: Colors.blue,
            //   label: SizedBox(),
            //   onPressed: () {
            //     onNewCameraSelected(widget.cameras);
            //     setState(() {});
            //   },
            // ),
            ),
        Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: "btn_take2",
              child: Icon(Icons.camera),
              backgroundColor: Colors.red,
              onPressed: isProgress
                  ? () {
                      NoticeUtils.showSnackBar(
                          _scaffoldKey, '분석중입니다..잠시만 기다려줴요.');
                    }
                  : onTakePictureButtonPressed,
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: Container(
          height: 55,
          color: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   title: Text("사진찍기"),
        // ),
        key: _scaffoldKey,
        body: Stack(
          children: [
            SafeArea(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: _cameraPreviewWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
              ),
            ),
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
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: _fab(),
            )
          ],
        ),
      ),
    );
  }

  void onCaptureOrientationLockButtonPressed() async {
    if (controller != null) {
      if (controller.value.isCaptureOrientationLocked) {
        await controller.unlockCaptureOrientation();
        NoticeUtils.showSnackBar(_scaffoldKey, "회전 잠김");
      } else {
        await controller.lockCaptureOrientation();
        NoticeUtils.showSnackBar(_scaffoldKey,
            '회전 잠김 ${controller.value.lockedCaptureOrientation.toString().split('.').last}');
      }
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        '카메라를 준비하고 있습니다.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Container(
        child: Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            child: CameraPreview(controller),
          ),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onNewCameraSelected(List<CameraDescription> cameras) async {
    CameraDescription cameraDescription;

    if (controller != null) {
      await controller.dispose();
    }

    if (isFront) {
      cameraDescription = cameras
          .firstWhere((el) => el.lensDirection == CameraLensDirection.back);
      setState(() {
        isFront = false;
      });
    } else {
      cameraDescription = cameras
          .firstWhere((el) => el.lensDirection == CameraLensDirection.front);
      setState(() {
        isFront = true;
      });
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high,
        enableAudio: false);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        NoticeUtils.showSnackBar(_scaffoldKey,
            '카메라에 문제가 있습니다. 메시지 : ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
      await Future.wait([
        controller
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        controller
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  ///
  /// 사진찍는 이벤트
  ///
  void onTakePictureButtonPressed() {
    // process true;
    isProgress = true;
    // take picture
    NoticeUtils.showSnackBarLongTime(_scaffoldKey, '사진을 찍기위해 준비중에 있습니다.');
    takePicture().then((XFile file) async {
      NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
      NoticeUtils.showSnackBarLongTime(
          _scaffoldKey, '사진을 분석중입니다.\n완료 되면 자동으로 화면이 종료 됩니다.');
      if (mounted) {
        setState(() {
          imageFile = file;
        });
        await fixExifRotation(file.path);
        User user = await ApiService.getUser();
        // 세로 모드 확인해야함
        var response = await new Dio()
            .post("http://gsapi.grepiu.com:8080/prototype/engine/images",
                data: FormData.fromMap({
                  "uid": user.uid,
                  "pushId": user.pushId,
                  "file": await MultipartFile.fromFile(file.path,
                      filename: file.name)
                }))
            .catchError((e) {
          print('e : ${e}');
        });
        if (response.statusCode == 200) {
          ImageEngineResponse result =
              ImageEngineResponse.fromJson(response.data);
          ApiService.insert(result);
          File(file.path).delete(recursive: true);
          NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
          Navigator.pop(context);
        } else {
          NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
          isProgress = false;
          File(file.path).delete(recursive: true);
          NoticeUtils.showSnackBar(
              _scaffoldKey, 'error ${response.statusMessage}');
        }
      }
    });
  }

  Future<XFile> takePicture() async {
    if (!controller.value.isInitialized) {
      NoticeUtils.showSnackBar(_scaffoldKey, '카메라를 선택해주세요');
      return null;
    }
    if (controller.value.isTakingPicture) {
      // 사진 찍고 있을 경우 대기
      return null;
    }
    try {
      return await controller.takePicture();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    NoticeUtils.showSnackBar(
        _scaffoldKey, '에러 발생: ${e.code}\n${e.description}');
  }

  Future<File> fixExifRotation(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    final height = originalImage.height;
    final width = originalImage.width;

    final exifData = await readExifFromBytes(imageBytes);

    img.Image fixedImage;
    // fixedImage = img.copyRotate(originalImage, 0);
    if (height < width) {
      // rotate
      if (exifData['Image Orientation'].printable.contains('Rotated 90')) {
        fixedImage = img.copyRotate(originalImage, 270);
      } else if (exifData['Image Orientation'].printable.contains('180')) {
        fixedImage = img.copyRotate(originalImage, -90);
      } else {
        fixedImage = img.copyRotate(originalImage, 0);
      }
    }
    //fixedImage = img.copyRotate(originalImage, 90);
    final fixedFile =
        await originalFile.writeAsBytes(img.encodeJpg(fixedImage, quality: 50));

    return fixedFile;
  }
}
