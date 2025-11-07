import 'package:isar/isar.dart';
import 'package:mobile_anemia_detector/core/database/app_database.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/animal_model.dart';

class AnimalRepository {
  AnimalRepository();

  Future<Isar> get _db async => AppDatabase.instance.database;

  Future<List<AnimalModel>> getAll({bool sortByName = true}) async {
    final isar = await _db;
    return isar.animalModels
        .where()
        .sortByUpdatedAtDesc()
        .thenByTagId()
        .findAll();
  }

  Stream<List<AnimalModel>> watchAll() async* {
    final isar = await _db;
    yield* isar.animalModels.watchLazy().asyncMap((_) => getAll());
  }

  Future<AnimalModel?> getById(int id) async {
    final isar = await _db;
    return isar.animalModels.get(id);
  }

  Future<AnimalModel?> getByTag(String tagId) async {
    final isar = await _db;
    return isar.animalModels.filter().tagIdEqualTo(tagId).findFirst();
  }

  Future<int> upsert(AnimalModel animal) async {
    final isar = await _db;

    return isar.writeTxn<int>(() async {
      final existing = await isar.animalModels
          .filter()
          .tagIdEqualTo(animal.tagId)
          .findFirst();

      if (existing != null) {
        animal
          ..id = existing.id
          ..createdAt = existing.createdAt
          ..updatedAt = DateTime.now().toUtc();
      } else {
        animal
          ..createdAt = DateTime.now().toUtc()
          ..updatedAt = DateTime.now().toUtc();
      }

      return isar.animalModels.put(animal);
    });
  }

  Future<void> delete(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.animalModels.delete(id);
    });
  }
}

