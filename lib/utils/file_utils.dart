import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<File> compressFile({String imagePath, int compressRate}) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    String dir = (await getTemporaryDirectory()).path;
    File temp = new File('$dir/${path.basenameWithoutExtension(originalFile.path)}.jpg');

    final fixedFile = await temp
        .writeAsBytes(img.encodeJpg(originalImage, quality: compressRate));
    return fixedFile;
  }

  ///
  /// 컨퍼넌트 캡처
  ///
  static Future<Uint8List> capturePng(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData.buffer.asUint8List();
    } catch (e) {
      print("error : ${e}");
    }
    return null;
  }
}
