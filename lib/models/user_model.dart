class AppUser {
  final String uid;
  final String email;
  final String uid5;
  final List<String> friends;

  AppUser({
    required this.uid,
    required this.email,
    required this.uid5,
    required this.friends,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      uid5: map['uid5'],
      friends: List<String>.from(map['friends'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'uid5': uid5,
      'friends': friends,
    };
  }
}
