import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/animal_model.dart';
import '../../presentation/controllers/herd_notifier.dart';
import '../../domain/entities/save_analysis_request.dart';
import '../pages/add_animal_page.dart';

class SaveAnalysisBottomSheet extends StatefulWidget {
  const SaveAnalysisBottomSheet({
    super.key,
    this.preselectedAnimalId,
    required this.defaultRecordedAt,
  });

  final int? preselectedAnimalId;
  final DateTime defaultRecordedAt;

  static Future<SaveAnalysisRequest?> show(
    BuildContext context, {
    int? preselectedAnimalId,
    required DateTime defaultRecordedAt,
  }) {
    return showModalBottomSheet<SaveAnalysisRequest>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SaveAnalysisBottomSheet(
          preselectedAnimalId: preselectedAnimalId,
          defaultRecordedAt: defaultRecordedAt,
        ),
      ),
    );
  }

  @override
  State<SaveAnalysisBottomSheet> createState() =>
      _SaveAnalysisBottomSheetState();
}

class _SaveAnalysisBottomSheetState extends State<SaveAnalysisBottomSheet> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _notesFocusNode = FocusNode();

  static const _actions = <String>[
    'Monitorar',
    'Vermifugado',
    'Suplementação Nutricional',
    'Outro',
  ];

  int? _selectedAnimalId;
  String? _selectedAction;
  String _searchTerm = '';
  late DateTime _recordedAt;

  @override
  void initState() {
    super.initState();
    _selectedAnimalId = widget.preselectedAnimalId;
    _recordedAt = widget.defaultRecordedAt;
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim();
      });
    });
    _notesFocusNode.addListener(_handleNotesFocusChange);
  }

  @override
  void dispose() {
    _notesFocusNode.removeListener(_handleNotesFocusChange);
    _notesFocusNode.dispose();
    _scrollController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleNotesFocusChange() {
    if (_notesFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _pickRecordedDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _recordedAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Data da análise',
    );

    if (selected != null) {
      setState(() {
        _recordedAt = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _recordedAt.hour,
          _recordedAt.minute,
        );
      });
    }
  }

  Future<void> _pickRecordedTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt),
      helpText: 'Horário da análise',
    );

    if (time != null) {
      setState(() {
        _recordedAt = DateTime(
          _recordedAt.year,
          _recordedAt.month,
          _recordedAt.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _createAnimal() async {
    final newAnimal = await Navigator.of(context).push<AnimalModel>(
      MaterialPageRoute(builder: (_) => const AddAnimalPage()),
    );
    if (newAnimal != null && mounted) {
      setState(() {
        _selectedAnimalId = newAnimal.id;
      });
    }
  }

  void _confirm() {
    if (_selectedAnimalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione um animal para salvar a análise.')),
      );
      return;
    }

    Navigator.of(context).pop(
      SaveAnalysisRequest(
        animalId: _selectedAnimalId!,
        recordedAt: _recordedAt,
        actionTaken: _selectedAction,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: viewInsets + 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Salvar Análise',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar animal por ID ou nome',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<HerdNotifier>(
                  builder: (context, notifier, _) {
                    if (notifier.isLoading && !notifier.isInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final animals = notifier.animals.where((overview) {
                      if (_searchTerm.isEmpty) return true;
                      final lower = _searchTerm.toLowerCase();
                      final matchesTag =
                          overview.animal.tagId.toLowerCase().contains(lower);
                      final name = overview.animal.name ??
                          overview.animal.nickname ??
                          '';
                      final matchesName = name.toLowerCase().contains(lower);
                      return matchesTag || matchesName;
                    }).toList();

                    if (animals.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nenhum animal encontrado.'),
                          TextButton.icon(
                            onPressed: _createAnimal,
                            icon: const Icon(Icons.add),
                            label: const Text('Cadastrar novo animal'),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            itemCount: animals.length,
                            itemBuilder: (context, index) {
                              final overview = animals[index];
                              final subtitle = [
                                if ((overview.animal.name ??
                                        overview.animal.nickname) !=
                                    null)
                                  overview.animal.name ??
                                      overview.animal.nickname,
                                if (overview.lastAnalysisDate != null)
                                  'Última análise: ${dateFormat.format(overview.lastAnalysisDate!)}',
                              ].whereType<String>().join(' • ');

                              return RadioListTile<int>(
                                value: overview.animal.id,
                                groupValue: _selectedAnimalId,
                                title: Text(overview.animal.tagId),
                                subtitle:
                                    subtitle.isEmpty ? null : Text(subtitle),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAnimalId = value;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _createAnimal,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Cadastrar novo animal'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedAction,
                  decoration: const InputDecoration(
                    labelText: 'Ação tomada (opcional)',
                  ),
                  items: _actions
                      .map(
                        (action) => DropdownMenuItem<String>(
                          value: action,
                          child: Text(action),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAction = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  focusNode: _notesFocusNode,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText:
                        'Observações sobre o atendimento ou condições do animal',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Data'),
                        subtitle: Text(dateFormat.format(_recordedAt)),
                        trailing: TextButton(
                          onPressed: _pickRecordedDate,
                          child: const Text('Alterar'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hora'),
                        subtitle: Text(timeFormat.format(_recordedAt)),
                        trailing: TextButton(
                          onPressed: _pickRecordedTime,
                          child: const Text('Alterar'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
