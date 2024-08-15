class AppUser {
  String uid;
  String email;
  String userType;

  AppUser({required this.uid, required this.email, required this.userType});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      userType: map['userType'],
    );
  }
}
