import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/item_attachment.dart';
import 'item_service_provider.dart';

/// Получение вложений предмета.
final itemAttachmentsProvider = FutureProvider.family<List<ItemAttachment>, String>(
  (ref, itemId) {
    return ref.watch(itemServiceProvider).getAttachments(itemId);
  },
);
