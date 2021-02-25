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

  static MapEntry maxEmotion(Map<String, double> emotion) {
    var sortedKeys = emotion.keys.toList(growable: false)
      ..sort((k1, k2) => emotion[k1].compareTo(emotion[k2]));
    LinkedHashMap sortedMap = new LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => emotion[k]);
    print("sort : ${sortedMap}");
    return sortedMap.entries.last;
  }

  static String getEmotionStatus(MapEntry entry) {
    print("getEmotion : ${entry}");
    String emotionStatus;
    switch(entry.key) {
      case "neutral":
        emotionStatus = "무표정";
        break;
      case "sad":
        emotionStatus = "슬픔";
        break;
      case "surprise":
        emotionStatus = "놀람";
        break;
      case "happy":
        emotionStatus = "행복";
        break;
      case "fear":
        emotionStatus = "공포";
        break;
      case "disgust":
        emotionStatus = "싫음";
        break;
      case "angry":
        emotionStatus = "화남";
        break;
    }
    return emotionStatus;
  }

  static int getAffection(Map<String, double> emotion) {
    final int addNeutral = 0;
    final int addHappy = 3;
    final int addSad = -1;
    final int addSurprise = 1;
    final int addFear = -2;
    final int addDisgust = -3;
    final int addAngry = -3;

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
    if(score > 100) {
      status = "천년에 한번 나오는 찐사랑!!";
    }  else if(score < 50 && score > 0){
      status = "평범한 사랑!!";
    } else {
      status = "우리는 남보다 못한 사이";
    }

    return status;
  }
}
