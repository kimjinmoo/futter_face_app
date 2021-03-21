import 'dart:convert';

import 'package:flutter_face_app/domain/rank_list_response.dart';
import 'package:flutter_face_app/domain/rank_response.dart';
import 'package:flutter_face_app/domain/result.dart';

class RankUtils {
  static Result parser(String json) {
    RankListResponse response = RankListResponse.fromJson(json);
    if (response == null) {
      return Result().isEmpty();
    }
    if (response.people.length > 0) {
      int cnt = response.people.length;
      switch (cnt) {
        case 1:
          return Result().isSingle(response.people[0]);
        case 2:
          // String json = jsonEncode(response.people.asMap());
          Comparator<RankResponse> rankComparator =
              (RankResponse a, RankResponse b) =>
                  b.box[0].toString().compareTo(a.box[0].toString());
          response.people.sort(rankComparator);
          return Result().isCouple(response.people[0], response.people[1]);
        default:
          return Result().isAboveThree();
      }
    } else {
      return Result().isNoPeople();
    }
  }
}
