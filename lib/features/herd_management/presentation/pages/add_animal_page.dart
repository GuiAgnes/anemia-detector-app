import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/animal_model.dart';
import '../../data/repositories/animal_repository.dart';

class AddAnimalPage extends StatefulWidget {
  const AddAnimalPage({super.key, this.animal});

  final AnimalModel? animal;

  @override
  State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tagController;
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  DateTime? _birthDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController(text: widget.animal?.tagId ?? '');
    _nameController =
        TextEditingController(text: widget.animal?.name ?? widget.animal?.nickname ?? '');
    _breedController = TextEditingController(text: widget.animal?.breed ?? '');
    _birthDate = widget.animal?.birthDate;
  }

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 2, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 15),
      lastDate: now,
      helpText: 'Selecione a data de nascimento aproximada',
    );
    if (selected != null) {
      setState(() {
        _birthDate = DateTime(selected.year, selected.month, selected.day);
      });
    }
  }

  Future<void> _saveAnimal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository = context.read<AnimalRepository>();
      final tag = _tagController.text.trim();
      final name = _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim();
      final breed = _breedController.text.trim().isEmpty
          ? null
          : _breedController.text.trim();

      final animal = AnimalModel(
        tagId: tag,
        name: name,
        nickname: null,
        breed: breed,
        birthDate: _birthDate,
      );

      if (widget.animal != null) {
        animal
          ..id = widget.animal!.id
          ..createdAt = widget.animal!.createdAt;
      }

      final savedId = await repository.upsert(animal);
      animal.id = savedId;

      if (!mounted) return;
      Navigator.of(context).pop(animal);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar o animal: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isEditing = widget.animal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Animal' : 'Cadastrar Animal'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'ID / Brinco *',
                  hintText: 'Ex.: 1234',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o identificador do animal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome / Apelido',
                  hintText: 'Opcional',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Raça',
                  hintText: 'Opcional',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data de nascimento (aproximada)'),
                subtitle: Text(
                  _birthDate != null
                      ? dateFormat.format(_birthDate!)
                      : 'Não informada',
                ),
                trailing: TextButton(
                  onPressed: _isSaving ? null : _pickBirthDate,
                  child: const Text('Selecionar'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveAnimal,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? 'Salvando...' : 'Salvar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

