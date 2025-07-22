import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    _categories = await _service.fetchCategories();
    notifyListeners();
  }
}
