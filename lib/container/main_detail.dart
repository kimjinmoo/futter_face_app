import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/result.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:flutter_face_app/utils/rank_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

///
/// 이미지 상세보기
///
class MainDetail extends StatefulWidget {
  final ImageEngineResponse imageEngineResponse;

  MainDetail({this.imageEngineResponse});

  @override
  State createState() {
    return MainDetailState();
  }
}

class MainDetailState extends State<MainDetail> {
  bool isProcess = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _globalKey = new GlobalKey();

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Result result = RankUtils.parser(widget.imageEngineResponse.json);

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      bottomNavigationBar: Container(
        height: 55,
        color: Colors.transparent,
      ),
      body: widget.imageEngineResponse == null
          ? SizedBox()
          : Column(
              children: [
                AppBar(
                  iconTheme: IconThemeData(
                    color: Colors.black54, //change your color here
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    "뒤로가기",
                    style: TextStyle(color: Colors.black54),
                  ),
                  actions: [
                    FlatButton.icon(
                        color: Colors.transparent,
                        onPressed: () async {
                          NoticeUtils.showSnackBar(_scaffoldKey, "공유를 준비합니다.");
                          final tempDir = await getTemporaryDirectory();
                          final file =
                              await new File('${tempDir.path}/image.jpg')
                                  .create();
                          file.writeAsBytesSync(await _capturePng());
                          NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
                          // 공유
                          await Share.shareFiles(['${tempDir.path}/image.jpg'],
                              subject: "공유");
                          // 삭제
                          file.delete();
                        },
                        icon: Icon(Icons.share),
                        label: Text("공유하기"))
                  ],
                ),
                Expanded(
                    child: RepaintBoundary(
                  key: _globalKey,
                  child: Stack(
                    children: [
                      RotatedBox(
                        quarterTurns: 1,
                        child: CachedNetworkImage(
                          imageUrl: widget.imageEngineResponse.imageUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.all(6),
                          child: Column(
                            children: [
                              Opacity(
                                opacity: 0.5,
                                child: Container(
                                    padding: EdgeInsets.all(5),
                                    color: Colors.black38,
                                    child: Text(
                                      "우리어때",
                                      style: TextStyle(color: Colors.white),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1,
                          height: 170,
                          color: Colors.black38,
                          padding: EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  '${result.affectionStatus}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Colors.white),
                                ),
                                (result.leftPeople != null &&
                                        result.rightPeople == null)
                                    ? Container(
                                        child: Column(
                                          children: [
                                            Text(
                                              "감정상태 : ${result.leftPeople.emotionStatus}",
                                              style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                (result.leftPeople != null &&
                                        result.rightPeople != null)
                                    ? Container(
                                        child: Column(
                                          children: [
                                            Text(
                                              "총 점수 : ${result.affection}",
                                              style: TextStyle(
                                                  color: Colors.pinkAccent,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "애정도 상세\n${result.leftPeople.affection} vs ${result.rightPeople.affection}",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ))
              ],
            ),
    );
  }
}
