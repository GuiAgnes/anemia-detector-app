enum AnemiaStatus { healthy, borderline, anemic, unknown }

extension AnemiaStatusX on AnemiaStatus {
  String get label {
    switch (this) {
      case AnemiaStatus.healthy:
        return 'Saudável';
      case AnemiaStatus.borderline:
        return 'Limítrofe';
      case AnemiaStatus.anemic:
        return 'Anêmico';
      case AnemiaStatus.unknown:
        return 'Sem dados';
    }
  }
}

