class User {
  final String uid;
  final String pushId;

  User({this.uid, this.pushId});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'push_id': pushId
    };
  }
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'],
        pushId: json['pushId']
    );
  }
}
