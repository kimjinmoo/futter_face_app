import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_face_app/domain/image_engine_list_response.dart';
import 'package:flutter_face_app/domain/image_engine_response.dart';
import 'package:flutter_face_app/domain/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  // 시작시 App을 초기화 한다.
  static void init(String fcmToken) {
    getDB();
    initUser(fcmToken);
  }

  static Future<Database> getDB() async {
    // 데이터베이스를 열고 참조 값을 얻습니다.
    Database database = await openDatabase(
        // 데이터베이스 경로를 지정합니다. 참고: `path` 패키지의 `join` 함수를 사용하는 것이
        // 각 플랫폼 별로 경로가 제대로 생성됐는지 보장할 수 있는 가장 좋은 방법입니다.
        join(await getDatabasesPath(), 'imageEngine_database.db'),
        onCreate: (db, version) {
      db.execute(
        "CREATE TABLE image_engine(idx INTEGER PRIMARY KEY, id TEXT, imageUrl TEXT, resultText text, json text)",
      );
      db.execute("CREATE TABLE user(uid TEXT PRIMARY KEY, push_id TEXT)");
    }, version: 1);

    return database;
  }

  static Future<void> initUser(pushId) async {
    final Database db = await getDB();
    User user = await getUser();
    if (user == null) {
      //test
      //30e4a133-6832-56ee-b15e-b274b3983188
      String uid = Uuid().v1().toString();
      db.insert("user", User(uid: uid, pushId: pushId).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      User updateUser = User(uid: user.uid, pushId: pushId);
      db.update("user", updateUser.toMap(),
          where: "uid = ?", whereArgs: [user.uid]);
    }
  }

  static Future<User> getUser() async {
    // 데이터베이스 reference를 얻습니다.
    final Database db = await getDB();
    List<Map<String, dynamic>> user = await db.query("user");
    List<User> u = List.generate(user.length, (index) {
      //test
      // 30e4a133-6832-56ee-b15e-b274b3983188
      return User(uid: "30e4a133-6832-56ee-b15e-b274b3983188", pushId: user[index]['push_id']);
      // return User(uid: user[index]['uid'], pushId: user[index]['push_id']);
    });
    return u.length > 0 ? u[0] : null;
  }

  static Future<void> insert(ImageEngineResponse imageEngine) async {
    // 데이터베이스 reference를 얻습니다.
    final Database db = await getDB();
    await db.insert(
      'image_engine',
      imageEngine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> syncImageEngine(String uid) async {
    await deleteAll();
    Response response = await Dio().get(
        "http://gsapi.grepiu.com:8080/prototype/engine/images/?uid=${uid}");
    if (response.statusCode == 200) {
      if(response.data == null || response.data == "") {
        return;
      }
      ImageEngineListResponse l =
          ImageEngineListResponse.fromJson(response.data);
      List<ImageEngineResponse> list = await fetch();
      l.list.reversed.forEach((dbObj) {
        insert(dbObj);
      });
    }
  }

  static Future<void> update(ImageEngineResponse obj) async {
    final Database db = await getDB();
    await db.update('image_engine', obj.toMap(),
        where: "idx = ?", whereArgs: [obj.idx]);
  }

  static Future<List<ImageEngineResponse>> fetch() async {
    final Database db = await getDB();

    final List<Map<String, dynamic>> maps =
        await db.query('image_engine', orderBy: "idx DESC");
    // List<Map<String, dynamic>를 List<Dog>으로 변환합니다.
    return List.generate(maps.length, (i) {
      return ImageEngineResponse(
          idx: maps[i]['idx'],
          id: maps[i]['id'],
          imageUrl: maps[i]['imageUrl'],
          resultText: maps[i]['resultText'],
          json: maps[i]['json']);
    });
  }

  static Future<void> delete(String id) async {
    // 데이터베이스 reference를 얻습니다.
    final db = await getDB();

    Response response = await Dio().delete("http://gsapi.grepiu.com:8080/prototype/engine/image/${id}");

    if(response.statusCode == 200) {
      // 데이터베이스에서 Dog를 삭제합니다.
      await db.delete(
        'image_engine',
        where: "id = ?",
        whereArgs: [id],
      );
    }
  }

  static Future<void> deleteAll() async {
    // 데이터베이스 reference를 얻습니다.
    final db = await getDB();

    // 데이터베이스에서 Dog를 삭제합니다.
    await db.delete(
      'image_engine'
    );
  }
}
