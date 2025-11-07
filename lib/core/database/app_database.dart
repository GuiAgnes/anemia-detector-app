import 'dart:async';

import 'package:isar/isar.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/animal_model.dart';
import 'package:mobile_anemia_detector/features/herd_management/data/models/analysis_model.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Isar? _isar;

  Future<Isar> get database async {
    if (_isar != null) {
      return _isar!;
    }

    return _initialize();
  }

  Future<Isar> _initialize() async {
    if (_isar != null) {
      return _isar!;
    }

    return Future.sync(() async {
      // Double-check locking to avoid race conditions during initialization
      if (_isar != null) {
        return _isar!;
      }

      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [AnimalModelSchema, AnalysisModelSchema],
        directory: dir.path,
        inspector: false,
      );

      return _isar!;
    });
  }
}

