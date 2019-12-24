
class User {
  String userId;
  String userName;
  String userEmail;
  String userImage;
  String userPhone;
  String pushToken;
  String createdOn;
  String userStatus;
  bool paymentStatus;
  List searchIndex;
  List users;


  User(
      this.userId,
      this.userName,
      this.userEmail,
      this.userImage,
      this.userPhone,
      this.pushToken,
      this.createdOn,
      this.searchIndex,
      this.users,
      this.userStatus,
      this.paymentStatus);

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'userEmail': userEmail,
    'userImage': userImage,
    'userPhone': userPhone,
    'pushToken': pushToken,
    'createdOn': createdOn,
    'searchIndex': searchIndex,
    'users': users,
    'userStatus': userStatus,
    'paymentStatus': paymentStatus,
  };
}

//class User {
//  final String userId;
//  final String userName;
//  final String userEmail;
//  final String userImage;
//  final String userPhone;
//  final String pushToken;
//  final List userList;
//
//  User({
//    this.userId,
//    this.userName,
//    this.userEmail,
//    this.userImage,
//    this.userPhone,
//    this.pushToken,
//    this.userList,
//  });
//
//  Map<String, Object> toJson() {
//    return {
//      'userId': userId,
//      'userName': userName,
//      'userEmail': userEmail == null ? '' : userEmail,
//      'userImage': userImage,
//      'userPhone': userPhone,
//      'pushToken': pushToken,
//      'userList': userList,
//    };
//  }
//
//  factory User.fromJson(Map<String, Object> doc) {
//    User user = new User(
//      userId: doc['userId'],
//      userName: doc['userName'],
//      userEmail: doc['userEmail'],
//      userImage: doc['userImage'],
//      userPhone: doc['userPhone'],
//      pushToken: doc['pushToken'],
//      userList: doc['userList'],
//    );
//    return user;
//  }
//
//  factory User.fromDocument(DocumentSnapshot doc) {
//    return User.fromJson(doc.data);
//  }
//}
