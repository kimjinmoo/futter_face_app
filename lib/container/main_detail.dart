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
  GlobalKey _globalKey = new GlobalKey();

  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
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
      bottomNavigationBar: Container(
        height: 55,
        color: Colors.transparent,
      ),
      appBar: AppBar(
        title: Text("뒤로가기"),
        actions: [
          FlatButton.icon(
              color: Colors.transparent,
              onPressed: () async {
                final tempDir = await getTemporaryDirectory();
                final file =
                    await new File('${tempDir.path}/image.jpg').create();
                file.writeAsBytesSync(await _capturePng());
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
      body: widget.imageEngineResponse == null
          ? SizedBox()
          : Column(
              children: [
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
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          color: Colors.black26,
                          padding: EdgeInsets.only(bottom: 20),
                          child: Column(
                            children: [
                              Text('${result.affectionStatus}',
                                style: TextStyle(
                                    fontSize: 28,
                                    color: Colors.white),
                              ),
                              (result.leftPeople != null &&
                                  result.rightPeople == null)
                                  ? Container(
                                child: Column(
                                  children: [
                                    Text("감정 : ${result.leftPeople.emotionStatus}", style: TextStyle(color: Colors.yellow, fontSize: 20),),
                                  ],
                                ),
                              )
                                  : SizedBox(),
                              (result.leftPeople != null &&
                                      result.rightPeople != null)
                                  ? Container(
                                child: Column(
                                  children: [
                                    Text("애정 스코어 : ${result.affection}", style: TextStyle(color: Colors.yellow),),
                                    Text("더 좋아하는 사람 : ${result.sign}", style: TextStyle(color: Colors.yellow, fontSize: 20),),
                                    Text("왼쪽 감정 : ${result.leftPeople.emotionStatus}", style: TextStyle(color: Colors.yellow, fontSize: 20),),
                                    Text("오른쪽  감정 : ${result.leftPeople.emotionStatus}", style: TextStyle(color: Colors.yellow, fontSize: 20),),
                                  ],
                                ),
                              )
                                  : SizedBox()
                            ],
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
