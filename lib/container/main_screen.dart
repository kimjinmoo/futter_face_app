import 'package:camera/camera.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_app/container/main_detail.dart';
import 'package:flutter_face_app/container/sliding_card.dart';
import 'package:flutter_face_app/core/camera.dart';
import 'package:flutter_face_app/core/image_upload.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:flutter_face_app/service/api_service.dart';
import 'package:flutter_face_app/utils/admob.dart';
import 'package:flutter_face_app/utils/notice_utils.dart';
import 'package:flutter_face_app/utils/rank_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void dispose() {
    Ads.hideBannerAd();
    super.dispose();
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

  void onRef() async {
    NoticeUtils.showSnackBar(_scaffoldKey, "분석이 완료 되어 리로드 됩니다.");
    await ApiService.syncImageEngine(uid);

    List<ImageEngineResponse> list = await ApiService.fetch();
    if (list.length > 0) {
      open(MaterialPageRoute(
          builder: (context) => MainDetail(imageEngineResponse: list[0])));
    }
    setState(() {});
  }

  void firebaseCloudMessagingListeners() async {
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

  _launchURL(type) async {
    String url = "https://www.grepiu.com";
    switch(type) {
      case "home":
        break;
      case "license":
        url = "http://data.grepiu.com/faceapp/license.html";
        break;
      case "policies":
        url = "http://data.grepiu.com/faceapp/ko_policies.html";
        break;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      NoticeUtils.showSnackBar(_scaffoldKey, "서버에 문제가 생겼습니다.");
    }
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
          drawerEnableOpenDragGesture: false,
          // endDrawerEnableOpenDragGesture: false,
          endDrawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Text(
                    'ID\n${uid}',
                    style: TextStyle(color: Colors.white),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                  ),
                ),
                ListTile(
                  title: Text('개발자 홈페이지'),
                  onTap: () {
                    _launchURL("home");
                  },
                ),
                ListTile(
                  title: Text('개인정보 수집안내'),
                  onTap: () {
                    _launchURL("policies");
                  },
                ),
                ListTile(
                  title: Text('open source license'),
                  onTap: () {
                    _launchURL("license");
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('1.0.0'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
              ],
            ),
          ),
          key: _scaffoldKey,
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.topLeft,
                      height: 75,
                      child: Text(
                        "우리 어때?",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    )),
                    InkWell(
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Center(
                          child: Text(
                            "추가정보",
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ),
                      onTap: () {
                        _scaffoldKey.currentState.openEndDrawer();
                      },
                    )
                  ],
                ),
                Container(
                    child: FutureBuilder<List<ImageEngineResponse>>(
                  future: ApiService.fetch(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ImageEngineResponse> obj = snapshot.data;
                      return Container(
                        height: MediaQuery.of(context).size.height*0.7,
                        child: _cardListView(obj),
                      );
                    }
                    return Container(
                      child: Text('업로드된 이미지 없음'),
                    );
                  },
                )),
              ],
            ),
          ),
          floatingActionButton: Container(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
            child: _fab(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: Container(
            height: 50,
            color: Colors.transparent,
          )),
    );
  }

  Widget emptyPicture() {
    return Card(
        margin: EdgeInsets.only(left: 18, right: 18, bottom: 24),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              color: Colors.transparent,
              child: Text(
                "사진을 찍어보세요!",
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: Column(
              children: [
                SizedBox(
                  height: 18,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Image.asset(
                    "assets/images/couple.jpg",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                // ClipRRect(
                //     borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                //     child:
                // ),
                SizedBox(
                  height: 8,
                ),
                Expanded(
                    child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "사진 분석을 통한 애정도 분석!!\n애정도로 친구와 소통해보시죠!!",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ))
              ],
            ))
          ],
        ));
  }

  showDeleteAlertDialog(String id) {
    Widget btnDelete = FlatButton(
        color: Colors.red,
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

  Widget _cardListView(data) {
    return data.length > 0
        ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: SlidingCard(
                    showDeleteHandler: () =>
                        showDeleteAlertDialog(data[index].id),
                    showDetailHandler: () => open(MaterialPageRoute(
                        builder: (context) =>
                            MainDetail(imageEngineResponse: data[index]))),
                    imageUrl: data[index].imageUrl,
                    comment: '${RankUtils.parser(data[index].json).comment}',
                  ));
            })
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.90,
            height: MediaQuery.of(context).size.height * 0.55,
            child: emptyPicture());
  }

  Widget _fab() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton.extended(
              heroTag: "upload",
              icon: Icon(Icons.add_a_photo_outlined),
              label: Text("파일 업로드"),
              backgroundColor: Colors.black,
              onPressed: () {
                open(MaterialPageRoute(builder: (context) => ImageUpload()));
              }),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton.extended(
              heroTag: "takePicture",
              icon: Icon(Icons.camera),
              label: Text("사진찍기"),
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                open(MaterialPageRoute(
                    builder: (context) => CameraHome(widget.cameras)));
              }),
        )
      ],
    );
  }
}
