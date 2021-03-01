import 'dart:collection';

import 'package:flutter_face_app/domain/people_result.dart';
import 'package:flutter_face_app/domain/rank_response.dart';
import 'package:flutter_face_app/utils/emotion_utils.dart';

class Result {
  // 애정도 상태
  String comment;

  // 비교 결과
  int affection;

  // 애정 결과
  String affectionStatus;

  // 부호
  String sign;

  // 부호 코맨
  String signComment;

  // 왼쪽 사람
  PeopleResult leftPeople;

  // 오른쪽 사람
  PeopleResult rightPeople;

  Result isEmpty() {
    this.comment = "분석이 안끝났습니다..";
    this.affectionStatus = "분석중입니다...";
    return this;
  }

  Result isNoPeople() {
    this.comment = "사람으로 판단이 안되는군요..!!";
    this.affectionStatus = "사람이 아닙니다..!";
    return this;
  }

  Result isSingle(RankResponse rankResponse) {
    this.leftPeople = PeopleResult().init(rankResponse);
    this.comment = "셀카를 찍으셨군요?";
    this.affectionStatus = "혼자 셀카를 찍으셨군요!";
    return this;
  }

  Result isCouple(RankResponse leftPeople, RankResponse rightPeople) {
    this.comment = "연인 OK! 클릭해서 상세보기!!";
    this.leftPeople = PeopleResult().init(leftPeople);
    this.rightPeople = PeopleResult().init(rightPeople);
    this.affection = this.leftPeople.affection.ceil()+this.rightPeople.affection.ceil();
    if(this.leftPeople.affection > this.rightPeople.affection) {
      this.sign = ">";
      this.signComment = "왼쪽분이 더 좋아하네요";
    } else {
      this.sign = "<";
      this.signComment = "오른쪽분이 더 좋아하네요";
    }
    this.affectionStatus = EmotionUtils.getAffectionStatus(this.affection);
    return this;
  }

  Result isAboveThree() {
    this.comment = "사람이 여려명이시네요...";
    return this;
  }
}
