import 'package:mobile_anemia_detector/features/herd_management/domain/enums/anemia_status.dart';

class DashboardSummary {
  DashboardSummary({
    required this.totalAnimals,
    required this.withAnalyses,
    required this.percentageHealthy,
    required this.percentageBorderline,
    required this.percentageAnemic,
  });

  final int totalAnimals;
  final int withAnalyses;
  final double percentageHealthy;
  final double percentageBorderline;
  final double percentageAnemic;

  bool get hasAnimals => totalAnimals > 0;

  Map<AnemiaStatus, double> get percentages => {
        AnemiaStatus.healthy: percentageHealthy,
        AnemiaStatus.borderline: percentageBorderline,
        AnemiaStatus.anemic: percentageAnemic,
      };
}

