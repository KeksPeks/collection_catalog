import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/catalog_item_card.dart';

import '../providers/catalog_provider.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return CatalogItemCard(
			  item: item,
			);
        },
      ),
    );
  }
}