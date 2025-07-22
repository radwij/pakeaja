import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';
import '../providers/item_provider.dart';
import '../providers/auth_provider.dart';
import '../models/item.dart';
import '../models/rental.dart';
import '../utils/currency.dart';

class CurrentlyRentingScreen extends StatefulWidget {
  const CurrentlyRentingScreen({Key? key}) : super(key: key);

  @override
  State<CurrentlyRentingScreen> createState() => _CurrentlyRentingScreenState();
}

class _CurrentlyRentingScreenState extends State<CurrentlyRentingScreen> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future directly. This is safe and correct.
    _fetchFuture = _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
    await rentalProvider.fetchActiveRentals(authProvider.firebaseUser!.uid);
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
          'Currently Renting',
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
          final rentals = rentalProvider.activeRentals;

          if (rentals.isEmpty) {
            return _buildEmptyState();
          }

          // Added RefreshIndicator for better user experience
          return RefreshIndicator(
            onRefresh: _refresh,
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: rentals.length,
              itemBuilder: (context, index) {
                final rental = rentals[index];
                final item = Provider.of<ItemProvider>(
                  context,
                  listen: false,
                ).getItemById(rental.itemId);
                return _buildRentalCard(context, rental, item);
              },
            ),
          );
        },
      ),
    );
  }

  // --- UI Helper Widgets ---

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
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: Colors.grey.shade700),
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
            const Icon(
              Icons.shopping_basket_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              'No Active Rentals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items you are currently renting will appear here. Go explore and rent something!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysLeft(DateTime endDate) {
    final difference = endDate.difference(DateTime.now());
    if (difference.isNegative) {
      return "Expired";
    }
    final days = difference.inDays;
    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} left';
    }
    final hours = difference.inHours;
    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} left';
    }
    final minutes = difference.inMinutes;
    return '$minutes minute${minutes > 1 ? 's' : ''} left';
  }

  Widget _buildRentalCard(BuildContext context, Rental rental, Item? item) {
    if (item == null) {
      return Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.only(bottom: 16),
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

    final daysLeft = _getDaysLeft(rental.endDate);
    final isExpired = rental.endDate.isBefore(DateTime.now());

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
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.images.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(
              context,
              Icons.date_range_outlined,
              "Rental Period",
              text:
                  '${DateFormat('d MMM y').format(rental.startDate)} - ${DateFormat('d MMM y').format(rental.endDate)}',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.monetization_on_outlined,
              "Total Paid",
              text: formatRupiah(rental.totalPrice),
              textColor: const Color(0xFF0B57D0),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.hourglass_bottom_outlined,
              "Time Left",
              text: daysLeft,
              textColor:
                  isExpired ? Colors.red.shade700 : Colors.green.shade800,
            ),
          ],
        ),
      ),
    );
  }

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

extension on ItemProvider {
  Item? getItemById(String id) {
    return items.where((item) => item.id == id).firstOrNull;
  }
}
