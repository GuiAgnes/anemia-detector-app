import 'package:isar/isar.dart';

part 'analysis_model.g.dart';

@collection
class AnalysisModel {
  AnalysisModel({
    required this.animalId,
    required this.recordedAt,
    required this.score,
    required this.originalImagePath,
    required this.segmentedImagePath,
    this.actionTaken,
    this.notes,
  }) {
    createdAt = DateTime.now().toUtc();
  }

  Id id = Isar.autoIncrement;

  @Index()
  late int animalId;

  @Index()
  late DateTime recordedAt;

  double score;

  String originalImagePath;
  String segmentedImagePath;

  String? actionTaken;
  String? notes;

  late DateTime createdAt;
}

