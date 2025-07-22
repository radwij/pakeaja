import 'package:flutter/material.dart';
import '../models/rental.dart';
import '../services/rental_service.dart';

class RentalProvider with ChangeNotifier {
  final RentalService _service = RentalService();
  List<Rental> _rentedOut = [];
  List<Rental> get rentedOut => _rentedOut;
  List<Rental> _activeRentals = [];
  List<Rental> get activeRentals => _activeRentals;

  Future<void> fetchRentedOut(String ownerId) async {
    _rentedOut = await _service.getOngoingRentalsForOwner(ownerId);
    notifyListeners();
  }

  Future<void> fetchActiveRentals(String renterId) async {
    _activeRentals = await _service.getOngoingRentalsForRenter(renterId);
    notifyListeners();
  }
}
