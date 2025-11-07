import 'package:mobile_anemia_detector/features/herd_management/data/models/animal_model.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/analysis_model.dart';
import 'package:mobile_anemia_detector/features/herd_management/domain/enums/anemia_status.dart';

class AnimalOverview {
  AnimalOverview({
    required this.animal,
    required this.latestAnalysis,
    required this.status,
  });

  final AnimalModel animal;
  final AnalysisModel? latestAnalysis;
  final AnemiaStatus status;

  double? get score => latestAnalysis?.score;

  DateTime? get lastAnalysisDate => latestAnalysis?.recordedAt;

  int? get daysSinceLastAnalysis {
    final lastDate = lastAnalysisDate;
    if (lastDate == null) return null;
    return DateTime.now().difference(lastDate).inDays;
  }
}

