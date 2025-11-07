import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../anemia_detection/presentation/pages/analysis_capture_page.dart';
import '../../data/models/animal_model.dart';
import '../../data/repositories/analysis_repository.dart';
import '../../data/repositories/animal_repository.dart';
import '../../domain/entities/animal_overview.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/enums/anemia_status.dart';
import '../controllers/herd_notifier.dart';
import 'add_animal_page.dart';
import 'animal_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isExporting = false;

  Future<void> _exportCsv(BuildContext context) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final analysisRepository = context.read<AnalysisRepository>();
      final animalRepository = context.read<AnimalRepository>();

      final analyses = await analysisRepository.getAll();
      final animals = await animalRepository.getAll(sortByName: true);
      final animalMap = {
        for (final animal in animals) animal.id: animal,
      };

      final List<List<dynamic>> rows = [
        [
          'animal_id',
          'tag',
          'nome',
          'raca',
          'data_hora',
          'score',
          'acao',
          'notas',
          'foto_original',
          'foto_segmentada',
        ],
      ];

      for (final analysis in analyses) {
        final animal = animalMap[analysis.animalId];
        rows.add([
          analysis.animalId,
          animal?.tagId ?? '',
          animal?.name ?? animal?.nickname ?? '',
          animal?.breed ?? '',
          analysis.recordedAt.toIso8601String(),
          analysis.score.toStringAsFixed(2),
          analysis.actionTaken ?? '',
          analysis.notes ?? '',
          analysis.originalImagePath,
          analysis.segmentedImagePath,
        ]);
      }

      final csvConverter = const ListToCsvConverter();
      final csvData = csvConverter.convert(rows);

      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File(p.join(directory.path, 'rebanho_analises_$timestamp.csv'));
      await file.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Histórico completo de análises do rebanho',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao exportar CSV: $e')),
      );
    } finally {
      if (context.mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _createAnimal(BuildContext context) async {
    await Navigator.of(context).push<AnimalModel>(
      MaterialPageRoute(builder: (_) => const AddAnimalPage()),
    );
  }

  Future<void> _startNewAnalysis(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AnalysisCapturePage()),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Saúde do Rebanho'),
        actions: [
          IconButton(
            tooltip: 'Cadastrar Animal',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _createAnimal(context),
          ),
          IconButton(
            tooltip: 'Exportar CSV',
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download_outlined),
            onPressed: _isExporting ? null : () => _exportCsv(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewAnalysis(context),
        icon: const Icon(Icons.camera_alt),
        label: const Text('Nova análise'),
      ),
      body: Consumer<HerdNotifier>(
        builder: (context, notifier, _) {
          if (notifier.isLoading && !notifier.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = notifier.summary ??
              DashboardSummary(
                totalAnimals: 0,
                withAnalyses: 0,
                percentageHealthy: 0,
                percentageBorderline: 0,
                percentageAnemic: 0,
              );

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildSummaryCard(summary, notifier.animals),
                const SizedBox(height: 20),
                _buildSectionTitle('Top 5 animais em risco'),
                _buildAnimalsList(
                  notifier.animalsInRisk,
                  emptyMessage: 'Nenhum animal em estado crítico.',
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Lembretes (sem análise recente)'),
                _buildAnimalsList(
                  notifier.animalsNeedingAttention,
                  emptyMessage:
                      'Todos os animais foram analisados nos últimos ${notifier.reminderThresholdDays} dias.',
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Todos os animais'),
                _buildAnimalsList(
                  notifier.animals,
                  compact: true,
                  emptyMessage:
                      'Cadastre o primeiro animal do rebanho para começar o monitoramento.',
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    DashboardSummary summary,
    List<AnimalOverview> animals,
  ) {
    final sections = <PieChartSectionData>[];

    void addSection(AnemiaStatus status, double percentage, Color color) {
      if (percentage <= 0) return;
      sections.add(
        PieChartSectionData(
          value: percentage,
          color: color,
          radius: 60,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    addSection(AnemiaStatus.healthy, summary.percentageHealthy,
        _statusColor(AnemiaStatus.healthy));
    addSection(AnemiaStatus.borderline, summary.percentageBorderline,
        _statusColor(AnemiaStatus.borderline));
    addSection(AnemiaStatus.anemic, summary.percentageAnemic,
        _statusColor(AnemiaStatus.anemic));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Visão geral do rebanho',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${summary.withAnalyses}/${summary.totalAnimals} com análises',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (summary.withAnalyses == 0)
              const Text(
                'Nenhuma análise registrada ainda. Realize a primeira avaliação para liberar os gráficos.',
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 24,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(
                        label: 'Saudáveis',
                        color: _statusColor(AnemiaStatus.healthy),
                        percentage: summary.percentageHealthy,
                      ),
                      _LegendItem(
                        label: 'Limítrofes',
                        color: _statusColor(AnemiaStatus.borderline),
                        percentage: summary.percentageBorderline,
                      ),
                      _LegendItem(
                        label: 'Anêmicos',
                        color: _statusColor(AnemiaStatus.anemic),
                        percentage: summary.percentageAnemic,
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAnimalsList(
    List<AnimalOverview> animals, {
    String emptyMessage = 'Nenhum item encontrado.',
    bool compact = false,
  }) {
    if (animals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          emptyMessage,
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return Column(
      children: animals.map((overview) {
        final animal = overview.animal;
        final statusColor = _statusColor(overview.status);
        final formattedDate = overview.lastAnalysisDate != null
            ? DateFormat('dd/MM/yyyy').format(overview.lastAnalysisDate!)
            : 'Sem análise';
        final scoreText = overview.score != null
            ? '${overview.score!.toStringAsFixed(1)}%'
            : '--';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _openAnimalDetail(animal),
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.15),
              foregroundColor: statusColor,
              child: Text(animal.tagId.characters.first.toUpperCase()),
            ),
            title: Text(animal.tagId),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((animal.name ?? animal.nickname) != null)
                  Text(animal.name ?? animal.nickname!),
                Text('Última análise: $formattedDate'),
              ],
            ),
            trailing: compact
                ? Text(
                    scoreText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        overview.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score: $scoreText',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }

  void _openAnimalDetail(AnimalModel animal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnimalDetailPage(animal: animal),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
    required this.percentage,
  });

  final String label;
  final Color color;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

