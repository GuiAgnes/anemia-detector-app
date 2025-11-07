import 'package:isar/isar.dart';
import 'package:mobile_anemia_detector/core/database/app_database.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/analysis_model.dart';

class AnalysisRepository {
  AnalysisRepository();

  Future<Isar> get _db async => AppDatabase.instance.database;

  Future<AnalysisModel?> getById(int id) async {
    final isar = await _db;
    return isar.analysisModels.get(id);
  }

  Future<List<AnalysisModel>> getByAnimal(int animalId) async {
    final isar = await _db;
    return isar.analysisModels
        .where()
        .animalIdEqualTo(animalId)
        .sortByRecordedAtDesc()
        .findAll();
  }

  Future<List<AnalysisModel>> getAll() async {
    final isar = await _db;
    return isar.analysisModels.where().sortByRecordedAtDesc().findAll();
  }

  Stream<List<AnalysisModel>> watchByAnimal(int animalId) async* {
    final isar = await _db;
    yield* isar.analysisModels
        .where()
        .animalIdEqualTo(animalId)
        .watch(fireImmediately: true)
        .asyncMap((_) => getByAnimal(animalId));
  }

  Future<AnalysisModel?> getLatestForAnimal(int animalId) async {
    final isar = await _db;
    return isar.analysisModels
        .where()
        .animalIdEqualTo(animalId)
        .sortByRecordedAtDesc()
        .findFirst();
  }

  Future<List<AnalysisModel>> getLatestAnalysesForAllAnimals() async {
    final isar = await _db;
    final all = await isar.analysisModels
        .where()
        .sortByAnimalId()
        .thenByRecordedAtDesc()
        .findAll();

    final Map<int, AnalysisModel> byAnimal = {};
    for (final analysis in all) {
      byAnimal.putIfAbsent(analysis.animalId, () => analysis);
    }
    return byAnimal.values.toList();
  }

  Future<int> addAnalysis(AnalysisModel analysis) async {
    final isar = await _db;
    return isar.writeTxn<int>(() async {
      analysis.createdAt = DateTime.now().toUtc();
      return isar.analysisModels.put(analysis);
    });
  }

  Future<void> deleteByAnimal(int animalId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.analysisModels
          .filter()
          .animalIdEqualTo(animalId)
          .deleteAll();
    });
  }
}

