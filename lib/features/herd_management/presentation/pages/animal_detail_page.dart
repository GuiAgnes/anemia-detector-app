import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../anemia_detection/presentation/pages/analysis_capture_page.dart';
import '../../data/models/analysis_model.dart';
import '../../data/models/animal_model.dart';
import '../../data/repositories/analysis_repository.dart';
import '../../domain/enums/anemia_status.dart';
import '../controllers/herd_notifier.dart';
import 'add_animal_page.dart';

class AnimalDetailPage extends StatefulWidget {
  const AnimalDetailPage({super.key, required this.animal});

  final AnimalModel animal;

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> {
  late AnimalModel _animal;
  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
  }

  Future<void> _editAnimal() async {
    final updated = await Navigator.of(context).push<AnimalModel>(
      MaterialPageRoute(builder: (_) => AddAnimalPage(animal: _animal)),
    );

    if (updated != null) {
      setState(() {
        _animal = updated;
      });
    }
  }

  Future<void> _startNewAnalysis() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisCapturePage(preselectedAnimal: _animal),
      ),
    );
  }

  Future<void> _exportPdf(List<AnalysisModel> analyses) async {
    if (analyses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registre ao menos uma análise para exportar o PDF.')),
      );
      return;
    }

    setState(() {
      _isExportingPdf = true;
    });

    try {
      final dateFormat = DateFormat('dd/MM/yyyy');
      final timestampFormat = DateFormat('yyyyMMdd_HHmmss');
      final sorted = analyses.toList()
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

      final doc = pw.Document();

      final points = List<pw.PointChartValue>.generate(sorted.length, (index) {
        final analysis = sorted[index];
        return pw.PointChartValue(index.toDouble(), analysis.score);
      });

      final bottomLabels = sorted
          .map((analysis) => dateFormat.format(analysis.recordedAt))
          .toList();

      final lastAnalyses = sorted.reversed.take(4).toList();
      final pdfAnalyses = <_PdfAnalysisAssets>[];

      for (final analysis in lastAnalyses) {
        pw.MemoryImage? original;
        pw.MemoryImage? segmented;

        final originalFile = File(analysis.originalImagePath);
        if (await originalFile.exists()) {
          original = pw.MemoryImage(await originalFile.readAsBytes());
        }

        final segmentedFile = File(analysis.segmentedImagePath);
        if (await segmentedFile.exists()) {
          segmented = pw.MemoryImage(await segmentedFile.readAsBytes());
        }

        pdfAnalyses.add(
          _PdfAnalysisAssets(
            analysis: analysis,
            original: original,
            segmented: segmented,
          ),
        );
      }

      doc.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Text(
              'Ficha Individual - ${_animal.tagId}',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Nome/Apelido: ${_animal.name ?? _animal.nickname ?? '-'}'),
            pw.Text('Raça: ${_animal.breed ?? '-'}'),
            pw.Text(
              'Nascimento: ${_animal.birthDate != null ? dateFormat.format(_animal.birthDate!) : '-'}',
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Evolução do Score de Anemia',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Container(
              height: 220,
              padding: const pw.EdgeInsets.symmetric(vertical: 12),
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis.fromStrings(bottomLabels, margin: 12),
                  yAxis: pw.FixedAxis(
                    [0, 20, 40, 60, 80, 100],
                    margin: 12,
                  ),
                ),
                datasets: [
                  pw.LineDataSet(
                    color: PdfColors.blue,
                    data: points,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Últimas análises',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            ...pdfAnalyses.map((item) {
              final analysis = item.analysis;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Data: ${dateFormat.format(analysis.recordedAt)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text('Score: ${analysis.score.toStringAsFixed(2)}%'),
                    if (analysis.actionTaken != null)
                      pw.Text('Ação: ${analysis.actionTaken}'),
                    if (analysis.notes != null)
                      pw.Text('Notas: ${analysis.notes}'),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (item.original != null)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Original'),
                                pw.SizedBox(height: 6),
                                pw.Container(
                                  height: 120,
                                  decoration: pw.BoxDecoration(
                                    borderRadius: pw.BorderRadius.circular(6),
                                    border: pw.Border.all(
                                      color: PdfColors.grey400,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: pw.ClipRRect(
                                    horizontalRadius: 6,
                                    verticalRadius: 6,
                                    child: pw.Image(
                                      item.original!,
                                      fit: pw.BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.original != null && item.segmented != null)
                          pw.SizedBox(width: 12),
                        if (item.segmented != null)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('Segmentada'),
                                pw.SizedBox(height: 6),
                                pw.Container(
                                  height: 120,
                                  decoration: pw.BoxDecoration(
                                    borderRadius: pw.BorderRadius.circular(6),
                                    border: pw.Border.all(
                                      color: PdfColors.grey400,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: pw.ClipRRect(
                                    horizontalRadius: 6,
                                    verticalRadius: 6,
                                    child: pw.Image(
                                      item.segmented!,
                                      fit: pw.BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );

      final bytes = await doc.save();
      final tempDir = await getTemporaryDirectory();
      final filename =
          'ficha_${_animal.tagId}_${timestampFormat.format(DateTime.now())}.pdf';
      final file = File(p.join(tempDir.path, filename));
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Ficha de ${_animal.tagId}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao gerar PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
        });
      }
    }
  }

  Color _statusColor(AnemiaStatus status) {
    switch (status) {
      case AnemiaStatus.healthy:
        return const Color(0xFF2E7D32);
      case AnemiaStatus.borderline:
        return const Color(0xFFF9A825);
      case AnemiaStatus.anemic:
        return const Color(0xFFC62828);
      case AnemiaStatus.unknown:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysisRepository = context.read<AnalysisRepository>();
    final herdNotifier = context.read<HerdNotifier>();
    final stream = analysisRepository.watchByAnimal(_animal.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ficha - ${_animal.tagId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: _editAnimal,
          ),
          IconButton(
            icon: _isExportingPdf
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Exportar PDF',
            onPressed: _isExportingPdf
                ? null
                : () async {
                    final analyses =
                        await analysisRepository.getByAnimal(_animal.id);
                    if (!mounted) return;
                    await _exportPdf(analyses);
                  },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewAnalysis,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Nova análise'),
      ),
      body: StreamBuilder<List<AnalysisModel>>(
        stream: stream,
        builder: (context, snapshot) {
          final analyses = snapshot.data ?? [];
          final lastAnalysis = analyses.isNotEmpty ? analyses.first : null;

          final AnemiaStatus status;
          if (lastAnalysis?.score != null) {
            final score = lastAnalysis!.score;
            if (score >= herdNotifier.healthyThreshold) {
              status = AnemiaStatus.healthy;
            } else if (score >= herdNotifier.borderlineThreshold) {
              status = AnemiaStatus.borderline;
            } else {
              status = AnemiaStatus.anemic;
            }
          } else {
            status = AnemiaStatus.unknown;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeader(status, lastAnalysis),
              const SizedBox(height: 20),
              _buildChart(analyses),
              const SizedBox(height: 20),
              _buildHistoryList(analyses),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(AnemiaStatus status, AnalysisModel? lastAnalysis) {
    final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _animal.tagId,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if ((_animal.name ?? _animal.nickname) != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _animal.name ?? _animal.nickname!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: _statusColor(status).withOpacity(0.2),
                    foregroundColor: _statusColor(status),
                    child: const Icon(Icons.bloodtype_outlined, size: 18),
                  ),
                  label: Text(status.label),
                ),
                Chip(
                  avatar: const Icon(Icons.hive_outlined, size: 18),
                  label: Text('Raça: ${_animal.breed ?? '-'}'),
                ),
                if (_animal.birthDate != null)
                  Chip(
                    avatar: const Icon(Icons.cake_outlined, size: 18),
                    label: Text(DateFormat('dd/MM/yyyy').format(_animal.birthDate!)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (lastAnalysis != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Última análise: ${dateTimeFormat.format(lastAnalysis.recordedAt)}',
                  ),
                  Text(
                    'Score: ${lastAnalysis.score.toStringAsFixed(2)}%',
                    style: TextStyle(color: _statusColor(status)),
                  ),
                  if (lastAnalysis.actionTaken != null)
                    Text('Ação: ${lastAnalysis.actionTaken}'),
                ],
              )
            else
              const Text('Ainda não há análises registradas para este animal.'),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<AnalysisModel> analyses) {
    if (analyses.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(
          height: 220,
          child: Center(
            child: Text('Sem dados suficientes para gerar o gráfico.'),
          ),
        ),
      );
    }

    final sorted = analyses.toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final baseDate = sorted.first.recordedAt;
    final spots = sorted.map((analysis) {
      final days = analysis.recordedAt.difference(baseDate).inHours / 24.0;
      return FlSpot(days, analysis.score);
    }).toList();

    final labels = <double, String>{};
    final formatter = DateFormat('dd/MM');
    final indexes = <int>{0, sorted.length - 1};
    if (sorted.length > 2) {
      indexes.add(sorted.length ~/ 2);
    }
    for (final index in indexes) {
      final spot = spots[index];
      labels[spot.x] = formatter.format(sorted[index].recordedAt);
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              gridData: FlGridData(show: true, horizontalInterval: 10),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final label = labels.entries.firstWhere(
                        (entry) => (entry.key - value).abs() < 0.5,
                        orElse: () => const MapEntry<double, String>(double.nan, ''),
                      );
                      if (label.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(label.value, style: const TextStyle(fontSize: 12)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 20,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  ),
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<AnalysisModel> analyses) {
    if (analyses.isEmpty) {
      return const Text('Nenhuma análise registrada até o momento.');
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: analyses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        return _AnalysisHistoryCard(analysis: analysis);
      },
    );
  }
}

class _AnalysisHistoryCard extends StatelessWidget {
  const _AnalysisHistoryCard({required this.analysis});

  final AnalysisModel analysis;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    Widget buildImage(String label, String path) {
      final file = File(path);
      if (!file.existsSync()) {
        return const SizedBox.shrink();
      }
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(analysis.recordedAt),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('${analysis.score.toStringAsFixed(2)}%'),
              ],
            ),
            const SizedBox(height: 8),
            if (analysis.actionTaken != null)
              Text('Ação tomada: ${analysis.actionTaken}'),
            if (analysis.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Notas: ${analysis.notes}'),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                buildImage('Original', analysis.originalImagePath),
                const SizedBox(width: 12),
                buildImage('Segmentada', analysis.segmentedImagePath),
              ].where((widget) => widget is! SizedBox).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfAnalysisAssets {
  const _PdfAnalysisAssets({
    required this.analysis,
    this.original,
    this.segmented,
  });

  final AnalysisModel analysis;
  final pw.MemoryImage? original;
  final pw.MemoryImage? segmented;
}

