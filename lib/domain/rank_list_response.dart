import 'dart:convert';

import 'package:flutter_face_app/domain/rank_response.dart';

class RankListResponse {
  final List<RankResponse> people;

  RankListResponse({this.people});

  factory RankListResponse.fromJson(String json) {
    JsonCodec codec = new JsonCodec();
    try {
      final jsonObj = codec.decode(json);

      return RankListResponse(
          people: (jsonObj as List)
              ?.map((e) => e == null
              ? null
              : RankResponse.fromJson(e as Map<String, dynamic>))
              ?.toList());
    } catch (e) {
      return null;
    }
  }
}
