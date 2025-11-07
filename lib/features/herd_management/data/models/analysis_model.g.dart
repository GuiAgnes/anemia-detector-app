// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnalysisModelCollection on Isar {
  IsarCollection<AnalysisModel> get analysisModels => this.collection();
}

const AnalysisModelSchema = CollectionSchema(
  name: r'AnalysisModel',
  id: -6434512942883083869,
  properties: {
    r'actionTaken': PropertySchema(
      id: 0,
      name: r'actionTaken',
      type: IsarType.string,
    ),
    r'animalId': PropertySchema(
      id: 1,
      name: r'animalId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'notes': PropertySchema(
      id: 3,
      name: r'notes',
      type: IsarType.string,
    ),
    r'originalImagePath': PropertySchema(
      id: 4,
      name: r'originalImagePath',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 5,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'score': PropertySchema(
      id: 6,
      name: r'score',
      type: IsarType.double,
    ),
    r'segmentedImagePath': PropertySchema(
      id: 7,
      name: r'segmentedImagePath',
      type: IsarType.string,
    )
  },
  estimateSize: _analysisModelEstimateSize,
  serialize: _analysisModelSerialize,
  deserialize: _analysisModelDeserialize,
  deserializeProp: _analysisModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'animalId': IndexSchema(
      id: -8446297297210463032,
      name: r'animalId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'animalId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'recordedAt': IndexSchema(
      id: -5046025352082009396,
      name: r'recordedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recordedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _analysisModelGetId,
  getLinks: _analysisModelGetLinks,
  attach: _analysisModelAttach,
  version: '3.1.0+1',
);

int _analysisModelEstimateSize(
  AnalysisModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.actionTaken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.originalImagePath.length * 3;
  bytesCount += 3 + object.segmentedImagePath.length * 3;
  return bytesCount;
}

void _analysisModelSerialize(
  AnalysisModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.actionTaken);
  writer.writeLong(offsets[1], object.animalId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.notes);
  writer.writeString(offsets[4], object.originalImagePath);
  writer.writeDateTime(offsets[5], object.recordedAt);
  writer.writeDouble(offsets[6], object.score);
  writer.writeString(offsets[7], object.segmentedImagePath);
}

AnalysisModel _analysisModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnalysisModel(
    actionTaken: reader.readStringOrNull(offsets[0]),
    animalId: reader.readLong(offsets[1]),
    notes: reader.readStringOrNull(offsets[3]),
    originalImagePath: reader.readString(offsets[4]),
    recordedAt: reader.readDateTime(offsets[5]),
    score: reader.readDouble(offsets[6]),
    segmentedImagePath: reader.readString(offsets[7]),
  );
  object.createdAt = reader.readDateTime(offsets[2]);
  object.id = id;
  return object;
}

P _analysisModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _analysisModelGetId(AnalysisModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _analysisModelGetLinks(AnalysisModel object) {
  return [];
}

void _analysisModelAttach(
    IsarCollection<dynamic> col, Id id, AnalysisModel object) {
  object.id = id;
}

extension AnalysisModelQueryWhereSort
    on QueryBuilder<AnalysisModel, AnalysisModel, QWhere> {
  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhere> anyAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'animalId'),
      );
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhere> anyRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'recordedAt'),
      );
    });
  }
}

extension AnalysisModelQueryWhere
    on QueryBuilder<AnalysisModel, AnalysisModel, QWhereClause> {
  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> animalIdEqualTo(
      int animalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalId',
        value: [animalId],
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      animalIdNotEqualTo(int animalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalId',
              lower: [],
              upper: [animalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalId',
              lower: [animalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalId',
              lower: [animalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalId',
              lower: [],
              upper: [animalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      animalIdGreaterThan(
    int animalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'animalId',
        lower: [animalId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      animalIdLessThan(
    int animalId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'animalId',
        lower: [],
        upper: [animalId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause> animalIdBetween(
    int lowerAnimalId,
    int upperAnimalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'animalId',
        lower: [lowerAnimalId],
        includeLower: includeLower,
        upper: [upperAnimalId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      recordedAtEqualTo(DateTime recordedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordedAt',
        value: [recordedAt],
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      recordedAtNotEqualTo(DateTime recordedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [],
              upper: [recordedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [recordedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [recordedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [],
              upper: [recordedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      recordedAtGreaterThan(
    DateTime recordedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [recordedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      recordedAtLessThan(
    DateTime recordedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [],
        upper: [recordedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterWhereClause>
      recordedAtBetween(
    DateTime lowerRecordedAt,
    DateTime upperRecordedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [lowerRecordedAt],
        includeLower: includeLower,
        upper: [upperRecordedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AnalysisModelQueryFilter
    on QueryBuilder<AnalysisModel, AnalysisModel, QFilterCondition> {
  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actionTaken',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actionTaken',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionTaken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'actionTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'actionTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'actionTaken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'actionTaken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionTaken',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      actionTakenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'actionTaken',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      animalIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      animalIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animalId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      animalIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animalId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      animalIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      originalImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      recordedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      recordedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      recordedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      scoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      scoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      scoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      scoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'segmentedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'segmentedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'segmentedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'segmentedImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'segmentedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'segmentedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'segmentedImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'segmentedImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'segmentedImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterFilterCondition>
      segmentedImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'segmentedImagePath',
        value: '',
      ));
    });
  }
}

extension AnalysisModelQueryObject
    on QueryBuilder<AnalysisModel, AnalysisModel, QFilterCondition> {}

extension AnalysisModelQueryLinks
    on QueryBuilder<AnalysisModel, AnalysisModel, QFilterCondition> {}

extension AnalysisModelQuerySortBy
    on QueryBuilder<AnalysisModel, AnalysisModel, QSortBy> {
  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByActionTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionTaken', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortByActionTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionTaken', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortByAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortByOriginalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortByOriginalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortBySegmentedImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segmentedImagePath', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      sortBySegmentedImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segmentedImagePath', Sort.desc);
    });
  }
}

extension AnalysisModelQuerySortThenBy
    on QueryBuilder<AnalysisModel, AnalysisModel, QSortThenBy> {
  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByActionTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionTaken', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenByActionTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionTaken', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenByAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalId', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenByOriginalImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenByOriginalImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalImagePath', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenBySegmentedImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segmentedImagePath', Sort.asc);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QAfterSortBy>
      thenBySegmentedImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segmentedImagePath', Sort.desc);
    });
  }
}

extension AnalysisModelQueryWhereDistinct
    on QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> {
  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> distinctByActionTaken(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionTaken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> distinctByAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalId');
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct>
      distinctByOriginalImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<AnalysisModel, AnalysisModel, QDistinct>
      distinctBySegmentedImagePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'segmentedImagePath',
          caseSensitive: caseSensitive);
    });
  }
}

extension AnalysisModelQueryProperty
    on QueryBuilder<AnalysisModel, AnalysisModel, QQueryProperty> {
  QueryBuilder<AnalysisModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnalysisModel, String?, QQueryOperations> actionTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionTaken');
    });
  }

  QueryBuilder<AnalysisModel, int, QQueryOperations> animalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalId');
    });
  }

  QueryBuilder<AnalysisModel, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AnalysisModel, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<AnalysisModel, String, QQueryOperations>
      originalImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalImagePath');
    });
  }

  QueryBuilder<AnalysisModel, DateTime, QQueryOperations> recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<AnalysisModel, double, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<AnalysisModel, String, QQueryOperations>
      segmentedImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'segmentedImagePath');
    });
  }
}
