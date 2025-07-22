import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // A great package for date formatting
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';
import '../providers/item_provider.dart';
import '../providers/auth_provider.dart';
import '../models/item.dart';
import '../models/rental.dart';
import '../utils/currency.dart';
import '../services/rental_service.dart';

class RentedOutScreen extends StatefulWidget {
  const RentedOutScreen({Key? key}) : super(key: key);

  @override
  State<RentedOutScreen> createState() => _RentedOutScreenState();
}

class _RentedOutScreenState extends State<RentedOutScreen> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    // CORRECTED: Initialize the future immediately. This is safe because
    // Provider.of with listen: false does not register a dependency.
    _fetchFuture = _refresh();
  }

  Future<void> _refresh() async {
    // This check is good practice, though not strictly necessary in this exact flow.
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
    await rentalProvider.fetchRentedOut(authProvider.firebaseUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0B57D0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        title: const Text(
          'Items Rented Out',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final rentalProvider = Provider.of<RentalProvider>(context);
          final rentals = rentalProvider.rentedOut;

          if (rentals.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                final rental = rentals[index];
                return _buildRentalCard(context, rental);
              },
            ),
          );
        },
      ),
    );
  }

  // --- Helper widgets to create a clean and modern UI ---

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0B57D0)),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.handshake_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Nothing is Rented Out',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When a user rents one of your items, it will appear here. Pull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalCard(BuildContext context, Rental rental) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final item = itemProvider.getItemById(rental.itemId);

    if (item == null) {
      return Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: const Text(
            'Item Not Found',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Rental ID: ${rental.id}'),
          leading: const Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.grey.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Image and Title ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.images.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // --- Rental Details ---
            _buildDetailRow(
              context,
              Icons.person_outline,
              "Rented by",
              text: rental.renterId.substring(0, 10) + '...',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.date_range_outlined,
              "Period",
              text:
                  '${DateFormat('d MMM y').format(rental.startDate)} - ${DateFormat('d MMM y').format(rental.endDate)}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.monetization_on_outlined,
              "Total Earned",
              text: formatRupiah(rental.totalPrice),
              textColor: const Color(0xFF0B57D0),
            ),
            const Divider(height: 24),
            // --- Action Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Mark as Finished'),
                onPressed: () async {
                  // This entire block is original functionality
                  await RentalService().completeRental(rental.id!, item.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rental marked as completed.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // We call setState to rebuild with the new future,
                    // ensuring the UI reflects the refreshed data.
                    setState(() {
                      _fetchFuture = _refresh();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for creating consistent detail rows
  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title, {
    String? text,
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text('$title: ', style: TextStyle(color: Colors.grey.shade700)),
        Expanded(
          child: Text(
            text ?? '',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Helper extension on ItemProvider for cleaner code
extension ItemProviderExtension on ItemProvider {
  Item? getItemById(String id) {
    final results = items.where((item) => item.id == id);
    return results.isNotEmpty ? results.first : null;
  }
}
