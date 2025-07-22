import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item.dart';
import 'auth_service.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  String get currentUserId => _authService.currentUser?.uid ?? '';

  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> urls = [];
    for (var image in images) {
      final ref = _storage
          .ref()
          .child('items')
          .child(currentUserId)
          .child('${DateTime.now().millisecondsSinceEpoch}_${image.name}');
      final uploadTask = await ref.putFile(File(image.path));
      final url = await uploadTask.ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> addItem(Item item) async {
    await _firestore.collection('items').add(item.toMap());
  }

  Future<List<Item>> getAllItems() async {
    final query =
        await _firestore
            .collection('items')
            .orderBy('createdAt', descending: true)
            .get();
    return query.docs
        .map((doc) => Item.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }
}
