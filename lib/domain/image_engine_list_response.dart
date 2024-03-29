import 'package:flutter_face_app/domain/image_engine_response.dart';

class ImageEngineListResponse {
  final List<ImageEngineResponse> list;

  ImageEngineListResponse({this.list});

  factory ImageEngineListResponse.fromJson(dynamic json) {
    dynamic obj = (json as List)
        ?.map((e) => e == null
        ? null
        : ImageEngineResponse.fromJson(e as Map<String, dynamic>))
        ?.toList();

    return ImageEngineListResponse(list: obj);
  }
}
