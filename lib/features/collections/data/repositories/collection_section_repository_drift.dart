import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

import '../../domain/entities/collection_section.dart';
import '../../domain/repositories/collection_section_repository.dart';


/// Drift-реализация репозитория разделов коллекций.
class CollectionSectionRepositoryDrift
    implements CollectionSectionRepository {
  final AppDatabase database;

  CollectionSectionRepositoryDrift(
    this.database,
  );


  @override
  Future<List<CollectionSection>> getSections(
    String collectionId,
  ) async {
    final rows = await (database.select(
      database.collectionSectionTable,
    )
          ..where(
            (table) =>
                table.collectionId.equals(
              collectionId,
            ),
          )
          ..orderBy([
            (table) =>
                OrderingTerm.asc(
              table.sortOrder,
            ),
          ]))
        .get();

    return rows
        .map(
          _mapToEntity,
        )
        .toList();
  }


  @override
  Future<CollectionSection?> getSection(
    String id,
  ) async {
    final row =
        await (database.select(
      database.collectionSectionTable,
    )
          ..where(
            (table) =>
                table.id.equals(id),
          ))
            .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _mapToEntity(row);
  }


  @override
  Future<void> saveSection(
    CollectionSection section,
  ) async {
    await database.into(
      database.collectionSectionTable,
    ).insert(
      CollectionSectionTableCompanion(
        id: Value(section.id),
        collectionId: Value(
          section.collectionId,
        ),
        parentId: Value(
          section.parentId,
        ),
        name: Value(
          section.name,
        ),
        createdAt: Value(
          section.createdAt,
        ),
        updatedAt: Value(
          section.updatedAt,
        ),
        sortOrder: Value(
          section.sortOrder,
        ),
      ),
    );
  }


  @override
  Future<void> updateSection(
    CollectionSection section,
  ) async {
    await (database.update(
      database.collectionSectionTable,
    )
          ..where(
            (table) =>
                table.id.equals(
              section.id,
            ),
          ))
        .write(
      CollectionSectionTableCompanion(
        collectionId: Value(
          section.collectionId,
        ),
        parentId: Value(
          section.parentId,
        ),
        name: Value(
          section.name,
        ),
        updatedAt: Value(
          section.updatedAt,
        ),
        sortOrder: Value(
          section.sortOrder,
        ),
      ),
    );
  }


  @override
  Future<void> deleteSection(
    String id,
  ) async {
    await (database.delete(
      database.collectionSectionTable,
    )
          ..where(
            (table) =>
                table.id.equals(id),
          ))
        .go();
  }


  CollectionSection _mapToEntity(
    CollectionSectionTableData row,
  ) {
    return CollectionSection(
      id: row.id,
      collectionId: row.collectionId,
      parentId: row.parentId,
      name: row.name,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}