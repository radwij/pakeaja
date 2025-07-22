import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryService {
  final _categoriesRef = FirebaseFirestore.instance.collection('categories');

  Future<List<Category>> fetchCategories() async {
    final snapshot = await _categoriesRef.get();
    return snapshot.docs
        .map((doc) => Category.fromMap(doc.id, doc.data()))
        .toList();
  }
}
