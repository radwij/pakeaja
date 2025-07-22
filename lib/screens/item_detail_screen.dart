import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../models/rental.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/currency.dart';
import '../services/rental_service.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  const ItemDetailScreen({required this.itemId, Key? key}) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRenting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickDates(BuildContext context) async {
    final now = DateTime.now();
    final start = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (start == null) return;
    final end = await showDatePicker(
      context: context,
      initialDate: start.add(const Duration(days: 1)),
      firstDate: start.add(const Duration(days: 1)),
      lastDate: start.add(const Duration(days: 30)),
    );
    if (end == null) return;
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  Future<void> _rentItem(Item item, String ownerId, String renterId) async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select rental dates')),
      );
      return;
    }
    setState(() => _isRenting = true);
    try {
      final days = _endDate!.difference(_startDate!).inDays;
      final totalPrice = days * item.pricePerDay;
      final rental = Rental(
        id: '',
        itemId: item.id!,
        renterId: renterId,
        ownerId: ownerId,
        startDate: _startDate!,
        endDate: _endDate!,
        status: 'ongoing',
        depositPaid: true,
        pricePerDay: item.pricePerDay,
        totalPrice: totalPrice,
        returnedAt: null,
      );
      await RentalService().createRental(rental);
      if (mounted) {
        await Provider.of<ItemProvider>(context, listen: false).fetchAllItems();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rental started!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to rent: $e')));
    } finally {
      if (mounted) setState(() => _isRenting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Item? item;
    try {
      item = itemProvider.items.firstWhere((it) => it.id == widget.itemId);
    } catch (e) {
      item = null;
    }

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found')));
    }

    final categoryName =
        categoryProvider.categories
            .firstWhere(
              (cat) => cat.id == item!.category,
              orElse: () => Category(id: item!.category, name: item.category),
            )
            .name;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B57D0)),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Color(0xFF0B57D0),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          if (item.images.isNotEmpty)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 320,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: item.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: Image.network(
                          item!.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 320,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ),
                if (item.images.length > 1)
                  Positioned(
                    bottom: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(item.images.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentPage == index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? const Color(0xFF0B57D0)
                                    : Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        categoryName,
                        style: const TextStyle(
                          color: Color(0xFF0B57D0),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on, color: Colors.grey, size: 18),
                    Expanded(
                      child: Text(
                        item.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B57D0),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Stock: ${item.stock}',
                        style: const TextStyle(
                          color: Color(0xFF388E3C),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Available: ${item.availableCount}',
                        style: const TextStyle(
                          color: Color(0xFFF57C00),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Color(0xFF0B57D0)),
                    const SizedBox(width: 4),
                    Text(
                      '${formatRupiah(item.pricePerDay)}/day',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B57D0),
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Deposit: ${formatRupiah(item.deposit)}',
                        style: const TextStyle(
                          color: Color(0xFF0B57D0),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (_startDate != null && _endDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF0B57D0),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rental: ${_startDate!.toLocal().toString().split(' ')[0]} - ${_endDate!.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B57D0),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          item.availableCount > 0
              ? Container(
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child:
                    _isRenting
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await _pickDates(context);
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _startDate == null || _endDate == null
                                      ? 'Select Dates'
                                      : 'Change Dates',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0B57D0),
                                  elevation: 0,
                                  side: const BorderSide(
                                    color: Color(0xFF0B57D0),
                                    width: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    (_startDate != null &&
                                            _endDate != null &&
                                            !_isRenting)
                                        ? () => _rentItem(
                                          item!,
                                          item.ownerId,
                                          authProvider.firebaseUser.uid,
                                        )
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B57D0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Rent',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
              )
              : Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Not Available'),
                ),
              ),
    );
  }
}
