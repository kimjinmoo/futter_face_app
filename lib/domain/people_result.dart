import 'package:flutter_face_app/domain/rank_response.dart';
import 'package:flutter_face_app/utils/emotion_utils.dart';

class PeopleResult {
  // 애정도
  int affection = 0;
  // 감정상태
  String emotionStatus = "";

  // 생성자
  PeopleResult init(RankResponse rankResponse) {
    var emotion = EmotionUtils.parseToMap(rankResponse);
    this.emotionStatus = EmotionUtils.getEmotionStatus(EmotionUtils.maxEmotion(emotion));
    this.affection = EmotionUtils.getAffection(emotion);
    return this;
  }
}