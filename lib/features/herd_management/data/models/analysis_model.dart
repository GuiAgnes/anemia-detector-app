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
    this.anemiaClassification,
    this.classificationConfidence,
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

  /// Classificação de anemia: 'Normal', 'Leve', 'Moderada', 'Grave'
  String? anemiaClassification;

  /// Confiança da classificação (0.0 a 1.0)
  double? classificationConfidence;

  late DateTime createdAt;
}

