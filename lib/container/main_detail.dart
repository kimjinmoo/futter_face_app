import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/result.dart';
import 'package:flutter_face_app/utils/file_utils.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:flutter_face_app/utils/rank_utils.dart';
import 'package:path/path.dart';
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

  @override
  Widget build(BuildContext context) {
    Result result = RankUtils.parser(widget.imageEngineResponse.json);

    return Scaffold(
        extendBodyBehindAppBar: false,
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          height: 50,
          color: Colors.transparent,
        ),
        body: widget.imageEngineResponse == null
            ? SizedBox()
            : SafeArea(
                child: Stack(
                children: [
                  Container(
                      child: RepaintBoundary(
                    key: _globalKey,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.imageEngineResponse.imageUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 190,
                            color: Colors.black87,
                            padding: EdgeInsets.only(bottom: 20),
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    '${result.affectionStatus}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
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
                                              Padding(
                                                padding: EdgeInsets.all(2),
                                                child: Text(
                                                  "총 점수",
                                                  style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              new Opacity(
                                                  opacity: 1.0,
                                                  child: new Container(
                                                      height: 50.0,
                                                      width: 50.0,
                                                      decoration:
                                                          new ShapeDecoration(
                                                        shape: new CircleBorder(
                                                            side: BorderSide
                                                                .none),
                                                        color: Colors.pink,
                                                      ),
                                                      child: new Center(
                                                          child: new Text(
                                                        "${result.affection}",
                                                        style: new TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15.0),
                                                      )))),
                                              Padding(
                                                padding: EdgeInsets.all(2),
                                                child: Text(
                                                  "애정도 상세",
                                                  style: TextStyle(
                                                      color: Colors.white54,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              Text(
                                                  "${result.leftPeople.affection} vs ${result.rightPeople.affection}",
                                                  style: new TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15.0))
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            margin: EdgeInsets.all(6),
                            child: Row(
                              children: [
                                Expanded(child: SizedBox()),
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/images/icon.jpg",
                                      height: 25,
                                      width: 25,
                                    ),
                                    Opacity(
                                      opacity: 0.5,
                                      child: Container(
                                          padding: EdgeInsets.all(5),
                                          color: Colors.black38,
                                          child: Text(
                                            "우리어때",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  Positioned(
                      child: AppBar(
                    iconTheme: IconThemeData(
                      color: Colors.black54, //change your color here
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title: Text(
                      "뒤로가기",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ))
                ],
              )),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: "share",
          backgroundColor: Colors.amberAccent,
          icon: Icon(
            Icons.share,
            color: Colors.black87,
          ),
          label: Text(
            "공유",
            style: TextStyle(color: Colors.black87),
          ),
          onPressed: () async {
            if(!isProcess) {
              setState(() {
                isProcess = true;
              });
              try {
                NoticeUtils.showSnackBar(_scaffoldKey, "공유를 준비합니다.");
                // path 패키지를 사용하여 이미지가 저장될 경로를 지정합니다.
                final path = join(
                  (await getTemporaryDirectory()).path,
                  'image.png',
                );
                File file = new File(path);
                Uint8List img = await FileUtils.capturePng(_globalKey);
                await file.writeAsBytes(img);
                // temp file
                File tempFile = await FileUtils.compressFile(
                    imagePath: file.path, compressRate: 90);
                NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
                // 공유
                await Share.shareFiles(['${tempFile.path}'], text: "공유");
                setState(() {
                  this.isProcess = false;
                });
                // 삭제
                tempFile.delete();
                file.delete();
              } catch (e) {
                throw e;
                setState(() {
                  this.isProcess = false;
                });
                NoticeUtils.hideSnackBarLongTime(_scaffoldKey);
                NoticeUtils.showSnackBar(_scaffoldKey, "Error : ${e}");
              }
            }

          },
          tooltip: '공유하기',
        ));
  }
}
