import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile_anemia_detector/core/database/app_database.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/animal_model.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/analysis_model.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/repositories/animal_repository.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/repositories/analysis_repository.dart';
import 'package:mobile_anemia_detector/features/herd_management/domain/entities/animal_overview.dart';
import 'package:mobile_anemia_detector/features/herd_management/domain/entities/dashboard_summary.dart';
import 'package:mobile_anemia_detector/features/herd_management/domain/enums/anemia_status.dart';

class HerdNotifier extends ChangeNotifier {
  HerdNotifier({
    required AnimalRepository animalRepository,
    required AnalysisRepository analysisRepository,
    this.reminderThresholdDays = 30,
    this.healthyThreshold = 70.0,
    this.borderlineThreshold = 50.0,
  })  : _animalRepository = animalRepository,
        _analysisRepository = analysisRepository;

  final AnimalRepository _animalRepository;
  final AnalysisRepository _analysisRepository;

  final int reminderThresholdDays;
  final double healthyThreshold;
  final double borderlineThreshold;

  bool _initialized = false;
  bool _isLoading = true;

  List<AnimalOverview> _animals = [];
  DashboardSummary? _summary;

  StreamSubscription<void>? _animalSubscription;
  StreamSubscription<void>? _analysisSubscription;

  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;
  List<AnimalOverview> get animals => _animals;
  DashboardSummary? get summary => _summary;

  List<AnimalOverview> get animalsInRisk {
    final risky = _animals
        .where((overview) => overview.status == AnemiaStatus.anemic)
        .toList()
      ..sort((a, b) {
        final aScore = a.score ?? double.infinity;
        final bScore = b.score ?? double.infinity;
        return aScore.compareTo(bScore);
      });
    return risky.take(5).toList();
  }

  List<AnimalOverview> get animalsNeedingAttention {
    final now = DateTime.now();
    final needing = _animals.where((overview) {
      final lastDate = overview.lastAnalysisDate;
      if (lastDate == null) return true;
      final diff = now.difference(lastDate).inDays;
      return diff >= reminderThresholdDays;
    }).toList()
      ..sort((a, b) {
        final aDays = a.daysSinceLastAnalysis ?? reminderThresholdDays + 1;
        final bDays = b.daysSinceLastAnalysis ?? reminderThresholdDays + 1;
        return bDays.compareTo(aDays);
      });
    return needing;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _reload();
    final isar = await AppDatabase.instance.database;
    _animalSubscription = isar.animalModels.watchLazy().listen((_) => _reload());
    _analysisSubscription = isar.analysisModels.watchLazy().listen((_) => _reload());
  }

  Future<void> createOrUpdateAnimal(AnimalModel animal) async {
    await _animalRepository.upsert(animal);
  }

  Future<void> addAnalysis(AnalysisModel analysis) async {
    await _analysisRepository.addAnalysis(analysis);
  }

  Future<void> refresh() async {
    await _reload();
  }

  Future<void> _reload() async {
    _isLoading = true;
    notifyListeners();

    final animals = await _animalRepository.getAll(sortByName: true);
    final List<AnimalOverview> overview = [];

    for (final animal in animals) {
      final latest = await _analysisRepository.getLatestForAnimal(animal.id);
      overview.add(
        AnimalOverview(
          animal: animal,
          latestAnalysis: latest,
          status: _classify(latest?.score),
        ),
      );
    }

    _animals = overview;
    _summary = _computeSummary(overview);
    _isLoading = false;
    notifyListeners();
  }

  DashboardSummary _computeSummary(List<AnimalOverview> items) {
    if (items.isEmpty) {
      return DashboardSummary(
        totalAnimals: 0,
        withAnalyses: 0,
        percentageHealthy: 0,
        percentageBorderline: 0,
        percentageAnemic: 0,
      );
    }

    final total = items.length;
    final withAnalyses = items.where((item) => item.latestAnalysis != null).length;
    final healthy =
        items.where((item) => item.status == AnemiaStatus.healthy).length;
    final borderline =
        items.where((item) => item.status == AnemiaStatus.borderline).length;
    final anemic =
        items.where((item) => item.status == AnemiaStatus.anemic).length;

    double toPercentage(int count) {
      if (withAnalyses == 0) return 0;
      return (count / withAnalyses) * 100;
    }

    return DashboardSummary(
      totalAnimals: total,
      withAnalyses: withAnalyses,
      percentageHealthy: toPercentage(healthy),
      percentageBorderline: toPercentage(borderline),
      percentageAnemic: toPercentage(anemic),
    );
  }

  AnemiaStatus _classify(double? score) {
    if (score == null) return AnemiaStatus.unknown;
    if (score >= healthyThreshold) return AnemiaStatus.healthy;
    if (score >= borderlineThreshold) return AnemiaStatus.borderline;
    return AnemiaStatus.anemic;
  }

  @override
  void dispose() {
    _animalSubscription?.cancel();
    _analysisSubscription?.cancel();
    super.dispose();
  }
}

