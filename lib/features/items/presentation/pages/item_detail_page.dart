import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/item_value.dart';

import '../providers/item_provider.dart';

/// Страница просмотра предмета коллекции.
class ItemDetailPage extends ConsumerWidget {
  final String itemId;

  const ItemDetailPage({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final itemAsync = ref.watch(
      itemProvider(
        itemId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Предмет',
        ),
      ),
      body: itemAsync.when(
        data: (item) {
          if (item == null) {
            return const Center(
              child: Text(
                'Предмет не найден',
              ),
            );
          }

          final valuesAsync = ref.watch(
            itemValuesProvider(
              item.id,
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'ID: ${item.id}',
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Коллекция: ${item.collectionId}',
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                'Раздел: ${item.sectionId ?? "Нет"}',
              ),
              const Divider(),
              const Text(
                'Поля',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              valuesAsync.when(
                data: (values) {
                  if (values.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(
                        top: 12,
                      ),
                      child: Text(
                        'Нет заполненных полей',
                      ),
                    );
                  }

                  return Column(
                    children: values
                        .map(
                          (value) =>
                              _ValueTile(
                            value: value,
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                },
                error: (error, stack) {
                  return Text(
                    error.toString(),
                  );
                },
              ),
            ],
          );
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stack) {
          return Center(
            child: Text(
              error.toString(),
            ),
          );
        },
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final ItemValue value;

  const _ValueTile({
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      title: Text(
        value.fieldId,
      ),
      subtitle: Text(
        value.value,
      ),
    );
  }
}