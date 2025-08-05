import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');
  final _authService = AuthService();

  String _generateRandomUid5() {
    final rand = Random();
    return (10000 + rand.nextInt(90000)).toString();
  }

  Future<void> createUser(String uid, String email) async {
    final uid5 = _generateRandomUid5();
    await _users.doc(uid).set({
      'uid': uid,
      'email': email,
      'uid5': uid5,
      'friends': [],
    });
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final user = _authService.auth.currentUser;
    if (user == null) return null;
    final doc = await _users.doc(user.uid).get();
    return AppUser.fromMap(doc.data()!);
  }

  Future<AppUser?> getUserByUid5(String uid5) async {
    final snap = await _users.where('uid5', isEqualTo: uid5).get();
    if (snap.docs.isEmpty) return null;
    return AppUser.fromMap(snap.docs.first.data());
  }

  Future<void> addFriend(String myUid, String otherUid) async {
    await _users.doc(myUid).update({
      'friends': FieldValue.arrayUnion([otherUid])
    });
    await _users.doc(otherUid).update({
      'friends': FieldValue.arrayUnion([myUid])
    });
  }
}
