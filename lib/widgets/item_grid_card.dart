import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../utils/currency.dart';

class ItemGridCard extends StatelessWidget {
  final Item item;
  final List<Category> categories;

  const ItemGridCard({Key? key, required this.item, required this.categories})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryName =
        categories
            .firstWhere(
              (cat) => cat.id == item.category,
              orElse: () => Category(id: item.category, name: item.category),
            )
            .name;

    return GestureDetector(
      onTap: () {
        context.push('/item/${item.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.images.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: Image.network(
                    item.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0B57D0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            item.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Available: ${item.availableCount}',
                        style: const TextStyle(
                          color: Color(0xFF0B57D0),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${formatRupiah(item.pricePerDay)}/day',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B57D0),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
