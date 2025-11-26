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
import '../../../branding/presentation/pages/about_page.dart';
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
          'classificacao_anemia',
          'confianca_classificacao',
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
          analysis.anemiaClassification ?? analysis.score.toStringAsFixed(0),
          analysis.anemiaClassification ?? '',
          analysis.classificationConfidence != null
              ? (analysis.classificationConfidence! * 100).toStringAsFixed(2)
              : '',
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
      final file =
          File(p.join(directory.path, 'rebanho_analises_$timestamp.csv'));
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel do Rebanho',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Monitoramento inteligente da saúde',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
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
          IconButton(
            tooltip: 'Sobre o Aplicativo',
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
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
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFF4F6FB)],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: notifier.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildHeroHeader(summary),
                  const SizedBox(height: 20),
                  _buildActionRow(context),
                  const SizedBox(height: 24),
                  _buildSummaryCard(summary),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    icon: Icons.report_problem_outlined,
                    title: 'Top 5 animais em risco',
                  ),
                  _buildAnimalsList(
                    notifier.animalsInRisk,
                    emptyMessage: 'Nenhum animal em estado crítico.',
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    icon: Icons.alarm_outlined,
                    title: 'Lembretes (sem análise recente)',
                  ),
                  _buildAnimalsList(
                    notifier.animalsNeedingAttention,
                    emptyMessage:
                        'Todos os animais foram analisados nos últimos ${notifier.reminderThresholdDays} dias.',
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    icon: Icons.hive_outlined,
                    title: 'Todos os animais',
                  ),
                  _buildAnimalsList(
                    notifier.animals,
                    compact: true,
                    emptyMessage:
                        'Cadastre o primeiro animal do rebanho para começar o monitoramento.',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(DashboardSummary summary) {
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  color: Color(0xFF4E5DFF),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visão geral do rebanho',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.withAnalyses}/${summary.totalAnimals} animais com análises recentes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (summary.withAnalyses == 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF4E5DFF)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nenhuma análise registrada ainda. Realize a primeira avaliação para liberar os gráficos.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 180,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutBack,
                      child: PieChart(
                        key: ValueKey(summary.hashCode),
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 26,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
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
    );
  }

  Widget _buildHeroHeader(DashboardSummary summary) {
    final total = summary.totalAnimals;
    final active = summary.withAnalyses;
    final coverage =
        total == 0 ? 0 : ((summary.withAnalyses / total) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF5270F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumo do rebanho',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.withAnalyses == 0
                          ? 'Ainda sem análises registradas'
                          : 'Cobertura de análises em tempo real',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.monitor_heart_outlined,
                color: Colors.white,
                size: 36,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _DashboardMetricChip(
                  label: 'Animais cadastrados',
                  value: '$total',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashboardMetricChip(
                  label: 'Com análises',
                  value: '$active',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DashboardMetricChip(
                  label: 'Cobertura',
                  value: '$coverage%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DashboardActionCard(
                icon: Icons.badge_outlined,
                label: 'Cadastrar animal',
                subtitle: 'Organize o rebanho',
                accentColor: const Color(0xFF1EB980),
                minWidth: double.infinity,
                onTap: () => _createAnimal(context),
              ),
              const SizedBox(height: 14),
              _DashboardActionCard(
                icon: Icons.file_download_outlined,
                label: _isExporting ? 'Exportando...' : 'Exportar CSV',
                subtitle: 'Dados completos',
                accentColor: const Color(0xFF7850F0),
                isBusy: _isExporting,
                minWidth: double.infinity,
                onTap: _isExporting ? null : () => _exportCsv(context),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _DashboardActionCard(
                icon: Icons.badge_outlined,
                label: 'Cadastrar animal',
                subtitle: 'Organize o rebanho',
                accentColor: const Color(0xFF1EB980),
                minWidth: 200,
                onTap: () => _createAnimal(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _DashboardActionCard(
                icon: Icons.file_download_outlined,
                label: _isExporting ? 'Exportando...' : 'Exportar CSV',
                subtitle: 'Dados completos',
                accentColor: const Color(0xFF7850F0),
                isBusy: _isExporting,
                minWidth: 200,
                onTap: _isExporting ? null : () => _exportCsv(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE7ECFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF4E5DFF), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        final scoreText = overview.latestAnalysis?.anemiaClassification != null
            ? overview.latestAnalysis!.anemiaClassification!
            : overview.score != null
                ? '${overview.score!.toStringAsFixed(0)}'
                : '--';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openAnimalDetail(animal),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        animal.tagId.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                animal.tagId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                compact ? scoreText : overview.status.label,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if ((animal.name ?? animal.nickname) != null)
                          Text(
                            animal.name ?? animal.nickname!,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        Text(
                          'Última análise: $formattedDate',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!compact)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scoreText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          overview.latestAnalysis?.anemiaClassification ?? 'Score',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9AA0B5)),
                        ),
                      ],
                    ),
                ],
              ),
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

class _DashboardMetricChip extends StatelessWidget {
  const _DashboardMetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    this.onTap,
    this.isBusy = false,
    this.minWidth,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isBusy;
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.16),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth ?? 0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isBusy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: accentColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
