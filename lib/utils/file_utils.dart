import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<File> copyRotatedFile(
      {String imagePath, int addRotate = 0}) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    // final height = originalImage.height;
    // final width = originalImage.width;
    //
    // final exifData = await readExifFromBytes(imageBytes);

    img.Image fixedImage;
    // fixedImage = img.copyRotate(originalImage, 0);
    // if (height < width) {
    //   // rotate
    //   if (exifData['Image Orientation'].printable.contains('Rotated 90')) {
    //     fixedImage = img.copyRotate(originalImage, 270);
    //   } else if (exifData['Image Orientation'].printable.contains('180')) {
    //     fixedImage = img.copyRotate(originalImage, -90);
    //   } else {
    //     fixedImage = img.copyRotate(originalImage, 0);
    //   }
    // }
    // 엔진이 270로 인식되어 변경
    // fixedImage = img.copyRotate(originalImage, 270+addRotate);
    // fixedImage = img.copyRotate(originalImage, 0);

    String dir = (await getTemporaryDirectory()).path;
    File temp = new File('$dir/${path.basename(originalFile.path)}');

    final fixedFile =
        await temp.writeAsBytes(img.encodeJpg(originalImage, quality: 50));
    return fixedFile;
  }

  static Future<File> compressFile(
      {String imagePath, int compressRate}) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    String dir = (await getTemporaryDirectory()).path;
    File temp = new File('$dir/${path.basename(originalFile.path)}');

    final fixedFile =
    await temp.writeAsBytes(img.encodeJpg(originalImage, quality: compressRate));
    return fixedFile;
  }
}
