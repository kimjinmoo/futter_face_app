class ImageEngineResponse {
  final int idx;
  final String id;
  final String imageUrl;
  final String resultText;
  final String json;

  ImageEngineResponse(
      {this.idx, this.id, this.imageUrl, this.resultText, this.json});

  Map<String, dynamic> toMap() {
    return {
      'idx': idx,
      'id': id,
      'imageUrl': imageUrl,
      'resultText': resultText,
      'json': json == null ? "" : json
    };
  }

  factory ImageEngineResponse.fromJson(Map<String, dynamic> json) {
    return ImageEngineResponse(
        id: json['id'],
        imageUrl: json['imageUrl'],
        resultText: json['resultText'],
        json: json['json']);
  }
}
