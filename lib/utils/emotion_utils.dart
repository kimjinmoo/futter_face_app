import 'dart:collection';

import 'package:flutter_face_app/domain/people_result.dart';
import 'package:flutter_face_app/domain/rank_response.dart';

class EmotionUtils {
  static Map<String, double> parseToMap(RankResponse rankResponse) {
    Map<String, double> emotion = {
      "neutral": rankResponse.neutral,
      "surprise": rankResponse.surprise,
      "sad": rankResponse.sad,
      "happy": rankResponse.happy,
      "fear": rankResponse.fear,
      "disgust": rankResponse.disgust,
      "angry": rankResponse.angry
    };

    return emotion;
  }

  static MapEntry maxEmotion(Map emotion) {
    var sortedKeys = emotion.keys.toList(growable: false)
      ..sort((k1, k2) => emotion[k2].compareTo(emotion[k1]));
    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => emotion[k]);
    return sortedMap.entries.last;
  }

  static String getEmotionStatus(MapEntry entry) {
    String emotionStatus = "";
    switch (entry.key) {
      case "neutral":
        emotionStatus = "아무생각없음";
        break;
      case "sad":
        emotionStatus = "개슬픔";
        break;
      case "surprise":
        emotionStatus = "개놀람";
        break;
      case "happy":
        emotionStatus = "찐행복";
        break;
      case "fear":
        emotionStatus = "찐공포";
        break;
      case "disgust":
        emotionStatus = "개싫음";
        break;
      case "angry":
        emotionStatus = "개화남";
        break;
    }
    return emotionStatus;
  }

  static int getAffection(Map emotion) {
    final int addNeutral = 1;
    final int addHappy = 3;
    final int addSad = -1;
    final int addSurprise = 1;
    final int addFear = -1;
    final int addDisgust = -1;
    final int addAngry = -1;

    num totalScore = 0;

    for (var k in emotion.keys) {
      switch(k) {
        case "neutral":
          totalScore+=(emotion[k]*100).ceil()*addNeutral;
          break;
        case "sad":
          totalScore+=(emotion[k]*100).ceil()*addSad;
          break;
        case "surprise":
          totalScore+=(emotion[k]*100).ceil()*addSurprise;
          break;
        case "happy":
          totalScore+=(emotion[k]*100).ceil()*addHappy;
          break;
        case "fear":
          totalScore+=(emotion[k]*100).ceil()*addFear;
          break;
        case "disgust":
          totalScore+=(emotion[k]*100).ceil()*addDisgust;
          break;
        case "angry":
          totalScore+=(emotion[k]*100).ceil()*addAngry;
          break;
      }
    }
    return totalScore;
  }

  static String getAffectionStatus(int score) {
    String status = "";
    if (score > 100) {
      status = "연애 초기\n애절한 사랑을 하고 계시네요!!";
    } else if (score < 100 && score >= 50) {
      status = "따듯한 온도..\n좋은 관계시군요!!";
    } else if (score < 50 && score >= 0) {
      status = "사랑을 하고 있긴 합니다..!!";
    } else if (score < 0 && score >= -50) {
      status = "우리는 남보다 못한 사이";
    } else {
      status = "최악...만나면 안되는 상태";
    }

    return status;
  }
}
