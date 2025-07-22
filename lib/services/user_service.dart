import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<void> saveUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
  }) async {
    await _users.doc(userId).set({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    });
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<String?> getUserName(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['name'] as String?;
    }
    return null;
  }
}
