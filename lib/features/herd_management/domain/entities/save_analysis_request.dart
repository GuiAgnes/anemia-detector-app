class SaveAnalysisRequest {
  const SaveAnalysisRequest({
    required this.animalId,
    required this.recordedAt,
    this.actionTaken,
    this.notes,
  });

  final int animalId;
  final DateTime recordedAt;
  final String? actionTaken;
  final String? notes;
}

