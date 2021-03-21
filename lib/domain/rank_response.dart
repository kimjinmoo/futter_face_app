class RankResponse {
  final List box;
  final double angry;
  final double disgust;
  final double happy;
  final double fear;
  final double sad;
  final double surprise;
  final double neutral;

  RankResponse(
      {this.box,
      this.angry,
      this.disgust,
      this.happy,
      this.fear,
      this.sad,
      this.surprise,
      this.neutral});

  factory RankResponse.fromJson(Map<String, dynamic> json) {
    if (json['emotions'] == null) {
      return RankResponse();
    }
    //set emotions
    var emotions = json['emotions'];
    var box = json['box'];

    return RankResponse(
        box: box,
        angry: emotions['angry'],
        disgust: emotions['disgust'],
        happy: emotions['happy'],
        fear: emotions['fear'],
        sad: emotions['sad'],
        surprise: emotions['surprise'],
        neutral: emotions['neutral']);
  }
}
