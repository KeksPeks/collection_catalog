import 'package:flutter/material.dart';

import '../pages/catalog_details_page.dart';

import '../../data/models/catalog_item_model.dart';

/// Карточка элемента каталога.
class CatalogItemCard extends StatelessWidget {
  final CatalogItemModel item;

  const CatalogItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogDetailsPage(item: item),
      ),
    );
  },
  child: Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [

            // Заглушка под изображение
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image,
                size: 40,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(item.platform),

                  Text(item.genre),

                  Text('${item.publisher}, ${item.year}'),

                  const SizedBox(height: 8),

                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              item.isOwned
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: item.isOwned
                  ? Colors.green
                  : Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}
}