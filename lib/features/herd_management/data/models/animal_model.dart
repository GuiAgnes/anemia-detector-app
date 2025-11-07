import 'package:isar/isar.dart';

part 'animal_model.g.dart';

@collection
class AnimalModel {
  AnimalModel({
    required this.tagId,
    this.name,
    this.nickname,
    this.birthDate,
    this.breed,
  }) {
    createdAt = DateTime.now().toUtc();
    updatedAt = DateTime.now().toUtc();
  }

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String tagId;

  String? name;
  String? nickname;
  DateTime? birthDate;
  String? breed;

  late DateTime createdAt;
  late DateTime updatedAt;
}

