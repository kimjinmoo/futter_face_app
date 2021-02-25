import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/container/main_detail.dart';
import 'package:flutter_face_app/container/sliding_card.dart';
import 'package:flutter_face_app/core/camera.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/utils/ad_manager.dart';
import 'package:flutter_face_app/utils/admob.dart';
import 'package:flutter_face_app/utils/rank_utils.dart';

FirebaseMessaging messaging = FirebaseMessaging();

class MainScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  MainScreen({this.cameras});

  @override
  createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String uid = "";
  String pushId = "";

  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();
    init();
    Ads.initialize();
    Ads.showBannerAd();
  }

  void init() async {
    User user = await ApiService.getUser();
    // 싱크 초기화
    await ApiService.syncImageEngine(user.uid);
    // 유저 Set
    setState(() {
      this.uid = user.uid;
      this.pushId = user.pushId;
    });
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onRef() async {
    showInSnackBar("분석이 완료 되어 리로드 됩니다.");
    await ApiService.syncImageEngine(uid);

    List<ImageEngineResponse> list = await ApiService.fetch();
    if (list.length > 0) {
      open(MaterialPageRoute(
          builder: (context) => MainDetail(imageEngineResponse: list[0])));
    }
    setState(() {});
  }

  void firebaseCloudMessagingListeners() async {
    print("enroll listeners");

    messaging.configure(onMessage: (Map<String, dynamic> message) async {
      onRef();
      print("onMessage: $message");
      // setState(() {});
    }, onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
    }, onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
    });
  }

  void open(MaterialPageRoute pageRoute) {
    // Ads.hideBannerAd();
    Navigator.push(context, pageRoute).then((value) {
      // Ads.showBannerAd();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          key: _scaffoldKey,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.topLeft,
                  height: 75,
                  child: Text(
                    "우리 어때?",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                    child: FutureBuilder<List<ImageEngineResponse>>(
                  future: ApiService.fetch(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ImageEngineResponse> obj = snapshot.data;
                      return _cardListView(obj);
                    }
                    return Container(
                      child: Text('업로드된 이미지 없음'),
                    );
                  },
                )),
              ],
            ),
          ),
          floatingActionButton: _fab(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: Container(
            height: 55,
            color: Colors.transparent,
          )),
    );
  }

  showDeleteAlertDialog(String id) {
    Widget btnDelete = FlatButton(
        onPressed: () async {
          await ApiService.delete(id).then((value) => setState(() {}));
          setState(() {});
          Navigator.pop(context);
        },
        child: Text("삭제"));
    Widget btnCancel = FlatButton(
        onPressed: () async {
          Navigator.pop(context);
        },
        child: Text("취소"));

    AlertDialog dialog = AlertDialog(
      title: Text(
        "경고",
        style: TextStyle(fontSize: 20),
      ),
      content: Text("삭제하시면 복구가 불가능합니다. 삭제 하시겠습니까?"),
      actions: [btnDelete, btnCancel],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  ListView _cardListView(data) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return SizedBox(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.55,
              child: SlidingCard(
                showDeleteHandler: () =>
                    showDeleteAlertDialog(data[index].id),
                showDetailHandler: () => open(MaterialPageRoute(
                    builder: (context) =>
                        MainDetail(imageEngineResponse: data[index]))),
                imageUrl: data[index].imageUrl,
                comment: '${RankUtils.parser(data[index].json).comment}',
              ));
          // return Container(
          //   height: 350,
          //   child: GestureDetector(
          //     onTap: () {
          //       open(MaterialPageRoute(builder: (context) => MainDetail(imageEngineResponse: data[index])));
          //     },
          //     child: Card(
          //       color: Colors.amber,
          //       child: Column(
          //         children: [
          //           Align(
          //             alignment: Alignment.topRight,
          //             child: RaisedButton.icon(
          //               label: Text("삭제"),
          //               color: Colors.amber,
          //               icon: Icon(Icons.remove),
          //               onPressed: () async {
          //                 await ApiService.delete(data[index].id)
          //                     .then((value) => setState(() {}));
          //                 setState(() {});
          //               },
          //             ),
          //           ),
          //           Expanded(
          //               child: RotatedBox(
          //             quarterTurns: 1,
          //             child: CachedNetworkImage(
          //               imageUrl: data[index].imageUrl,
          //               imageBuilder: (context, imageProvider) => Container(
          //                 decoration: BoxDecoration(
          //                   image: DecorationImage(
          //                     image: imageProvider,
          //                     fit: BoxFit.fitWidth,
          //                   ),
          //                 ),
          //               ),
          //               placeholder: (context, url) =>
          //                   CircularProgressIndicator(),
          //               errorWidget: (context, url, error) => Icon(Icons.error),
          //             ),
          //           )),
          //           Container(
          //             margin: EdgeInsets.all(10),
          //             child: Text(
          //               '${RankUtils.parser(data[index].json)}',
          //               style: TextStyle(color: Colors.black26),
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //   ),
          // );
        });
  }

  Widget _fab() {
    return FloatingActionButton.extended(
        icon: Icon(Icons.camera),
        label: Text("사진찍기"),
        backgroundColor: Colors.red,
        onPressed: () {
          open(MaterialPageRoute(
              builder: (context) => CameraHome(widget.cameras)));
        });
  }
}
