import 'package:flutter/material.dart';

import '../../data/models/catalog_item_model.dart';

/// Экран подробной информации.
class CatalogDetailsPage extends StatelessWidget {
  final CatalogItemModel item;

  const CatalogDetailsPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Container(
                width: 180,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 16),

            Text("Платформа: ${item.platform}"),
            Text("Жанр: ${item.genre}"),
            Text("Разработчик: ${item.developer}"),
            Text("Издатель: ${item.publisher}"),
            Text("Год: ${item.year}"),

            const SizedBox(height: 12),

            Row(
              children: [
                const Text("В коллекции: "),
                Icon(
                  item.isOwned
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: item.isOwned
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Описание",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 8),

            Text(item.description),
          ],
        ),
      ),
    );
  }
}