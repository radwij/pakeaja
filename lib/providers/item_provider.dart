import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import 'package:image_picker/image_picker.dart';

class ItemProvider with ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<Item> _items = [];
  List<Item> get items => _items;

  Future<void> addItem({
    required String title,
    required String description,
    required String category,
    required String location,
    required double pricePerDay,
    required double deposit,
    required List<XFile> images,
    required int stock,
  }) async {
    final imageUrls = await _itemService.uploadImages(images);

    final item = Item(
      ownerId: _itemService.currentUserId,
      title: title,
      description: description,
      category: category,
      location: location,
      pricePerDay: pricePerDay,
      deposit: deposit,
      images: imageUrls,
      createdAt: DateTime.now(),
      stock: stock,
      availableCount: stock,
    );

    await _itemService.addItem(item);
    notifyListeners();
  }

  Future<void> fetchAllItems() async {
    final fetched = await _itemService.getAllItems();
    _items = fetched;
    notifyListeners();
  }
}
