import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/item_provider.dart';
import '../providers/category_provider.dart';
import '../models/item.dart';
import '../widgets/item_grid_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _fetchItemsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchItemsFuture =
        Provider.of<ItemProvider>(context, listen: false).fetchAllItems();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    List<Item> filteredItems =
        itemProvider.items.where((item) {
          return item.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'PakeAja',
          style: TextStyle(
            color: Color(0xFF0B57D0),
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF0B57D0),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Available Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B57D0),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.filter_list, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Icon(Icons.sort, color: Colors.grey[600]),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _fetchItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (filteredItems.isEmpty) {
                    return const Center(
                      child: Text(
                        'No items available.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: GridView.builder(
                      itemCount: filteredItems.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.6,
                          ),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ItemGridCard(item: item, categories: categories);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
