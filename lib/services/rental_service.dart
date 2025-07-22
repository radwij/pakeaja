import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rental.dart';

class RentalService {
  final _rentals = FirebaseFirestore.instance.collection('rentals');
  final _items = FirebaseFirestore.instance.collection('items');

  Future<void> createRental(Rental rental) async {
    final doc = await _rentals.add(rental.toMap());
    try {
      await _items.doc(rental.itemId).update({
        'availableCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Failed to update availableCount: $e');
    }
  }

  Future<void> completeRental(String rentalId, String itemId) async {
    await _rentals.doc(rentalId).update({
      'status': 'completed',
      'returnedAt': DateTime.now().toIso8601String(),
    });
    // Increment availableCount
    await _items.doc(itemId).update({
      'availableCount': FieldValue.increment(1),
    });
  }

  Future<List<Rental>> getActiveRentalsForUser(String userId) async {
    final snap =
        await _rentals
            .where('renterId', isEqualTo: userId)
            .where('status', isEqualTo: 'ongoing')
            .get();
    return snap.docs.map((doc) => Rental.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Rental>> getRentalHistoryForUser(String userId) async {
    final snap =
        await _rentals
            .where('renterId', isEqualTo: userId)
            .where('status', whereIn: ['completed', 'cancelled'])
            .get();
    return snap.docs.map((doc) => Rental.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Rental>> getOngoingRentalsForOwner(String ownerId) async {
    final snap =
        await FirebaseFirestore.instance
            .collection('rentals')
            .where('ownerId', isEqualTo: ownerId)
            .where('status', isEqualTo: 'ongoing')
            .get();
    return snap.docs.map((doc) => Rental.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<Rental>> getOngoingRentalsForRenter(String renterId) async {
    final snap =
        await FirebaseFirestore.instance
            .collection('rentals')
            .where('renterId', isEqualTo: renterId)
            .where('status', isEqualTo: 'ongoing')
            .get();
    return snap.docs.map((doc) => Rental.fromMap(doc.id, doc.data())).toList();
  }
}
