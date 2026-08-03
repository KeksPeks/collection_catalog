import '../entities/collection_section.dart';
import '../repositories/collection_section_repository.dart';

class CollectionSectionService {

  final CollectionSectionRepository repository;


  CollectionSectionService(
    this.repository,
  );


  Future<List<CollectionSection>> getSections(
    String collectionId,
  ) {
    return repository.getSections(
      collectionId,
    );
  }


  Future<void> createSection(
    CollectionSection section,
  ) {
    return repository.saveSection(
      section,
    );
  }


  Future<void> updateSection(
    CollectionSection section,
  ) {
    return repository.updateSection(
      section,
    );
  }


  Future<void> deleteSection(
    String id,
  ) {
    return repository.deleteSection(
      id,
    );
  }
}