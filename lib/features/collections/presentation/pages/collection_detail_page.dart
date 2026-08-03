import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../fields/presentation/pages/add_field_page.dart';
import '../../../fields/presentation/pages/edit_field_page.dart';
import '../../../fields/presentation/providers/field_provider.dart';
import '../../../fields/presentation/providers/field_service_provider.dart';

/// Страница просмотра коллекции и её полей.
class CollectionDetailPage extends ConsumerStatefulWidget {
  final String collectionId;
  final String collectionName;

  const CollectionDetailPage({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  ConsumerState<CollectionDetailPage> createState() =>
      _CollectionDetailPageState();
}

class _CollectionDetailPageState
    extends ConsumerState<CollectionDetailPage> {

  Future<bool> _confirmDelete(String name) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Удалить поле?',
          ),
          content: Text(
            name,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Отмена',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Удалить',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }


  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(
      fieldsProvider(
        widget.collectionId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collectionName,
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            fieldsProvider(
              widget.collectionId,
            ),
          );
        },

        child: fieldsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (error, stack) => Center(
            child: Text(
              error.toString(),
            ),
          ),

          data: (fields) {
            return ListView(
              padding: const EdgeInsets.all(
                16,
              ),

              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.collectionName,
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .titleLarge,
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          'Количество полей: ${fields.length}',
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Text(
                          'Коллекция: ${widget.collectionId}',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                if (fields.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        'Поля отсутствуют',
                      ),
                    ),
                  )

                else
                  ...fields.map(
                    (field) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            field.label,
                          ),

                          subtitle: Text(
                            field.type.name,
                          ),

                          trailing:
                              PopupMenuButton<String>(
                            onSelected:
                                (value) async {

                              if (value == 'edit') {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditFieldPage(
                                      field: field,
                                    ),
                                  ),
                                );

                                if (!mounted) {
                                  return;
                                }

                                ref.invalidate(
                                  fieldsProvider(
                                    widget.collectionId,
                                  ),
                                );
                              }


                              if (value == 'delete') {
                                final confirm =
                                    await _confirmDelete(
                                  field.label,
                                );

                                if (!mounted) {
                                  return;
                                }

                                if (confirm) {
                                  final service =
                                      await ref.read(
                                    fieldServiceProvider.future,
                                  );

                                  await service.deleteField(
                                    field.id,
                                  );

                                  if (!mounted) {
                                    return;
                                  }

                                  ref.invalidate(
                                    fieldsProvider(
                                      widget.collectionId,
                                    ),
                                  );
                                }
                              }
                            },

                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  'Изменить',
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Удалить',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        child: const Icon(
          Icons.add,
        ),

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddFieldPage(
                collectionId:
                    widget.collectionId,
              ),
            ),
          );

          if (!mounted) {
            return;
          }

          ref.invalidate(
            fieldsProvider(
              widget.collectionId,
            ),
          );
        },
      ),
    );
  }
}