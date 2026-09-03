// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinned_tool_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPinnedToolCollection on Isar {
  IsarCollection<PinnedTool> get pinnedTools => this.collection();
}

const PinnedToolSchema = CollectionSchema(
  name: r'PinnedTool',
  id: 1562904810927054000,
  properties: {
    r'category': PropertySchema(
      id: 0,
      name: r'category',
      type: IsarType.string,
    ),
    r'displayOrder': PropertySchema(
      id: 1,
      name: r'displayOrder',
      type: IsarType.long,
    ),
    r'toolId': PropertySchema(
      id: 2,
      name: r'toolId',
      type: IsarType.string,
    ),
    r'toolName': PropertySchema(
      id: 3,
      name: r'toolName',
      type: IsarType.string,
    )
  },
  estimateSize: _pinnedToolEstimateSize,
  serialize: _pinnedToolSerialize,
  deserialize: _pinnedToolDeserialize,
  deserializeProp: _pinnedToolDeserializeProp,
  idName: r'id',
  indexes: {
    r'toolId': IndexSchema(
      id: -1537962893477976600,
      name: r'toolId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'toolId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pinnedToolGetId,
  getLinks: _pinnedToolGetLinks,
  attach: _pinnedToolAttach,
  version: '3.1.0+1',
);

int _pinnedToolEstimateSize(
  PinnedTool object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.category.length * 3;
  bytesCount += 3 + object.toolId.length * 3;
  bytesCount += 3 + object.toolName.length * 3;
  return bytesCount;
}

void _pinnedToolSerialize(
  PinnedTool object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.category);
  writer.writeLong(offsets[1], object.displayOrder);
  writer.writeString(offsets[2], object.toolId);
  writer.writeString(offsets[3], object.toolName);
}

PinnedTool _pinnedToolDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PinnedTool();
  object.category = reader.readString(offsets[0]);
  object.displayOrder = reader.readLong(offsets[1]);
  object.id = id;
  object.toolId = reader.readString(offsets[2]);
  object.toolName = reader.readString(offsets[3]);
  return object;
}

P _pinnedToolDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pinnedToolGetId(PinnedTool object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pinnedToolGetLinks(PinnedTool object) {
  return [];
}

void _pinnedToolAttach(IsarCollection<dynamic> col, Id id, PinnedTool object) {
  object.id = id;
}

extension PinnedToolByIndex on IsarCollection<PinnedTool> {
  Future<PinnedTool?> getByToolId(String toolId) {
    return getByIndex(r'toolId', [toolId]);
  }

  PinnedTool? getByToolIdSync(String toolId) {
    return getByIndexSync(r'toolId', [toolId]);
  }

  Future<bool> deleteByToolId(String toolId) {
    return deleteByIndex(r'toolId', [toolId]);
  }

  bool deleteByToolIdSync(String toolId) {
    return deleteByIndexSync(r'toolId', [toolId]);
  }

  Future<List<PinnedTool?>> getAllByToolId(List<String> toolIdValues) {
    final values = toolIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'toolId', values);
  }

  List<PinnedTool?> getAllByToolIdSync(List<String> toolIdValues) {
    final values = toolIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'toolId', values);
  }

  Future<int> deleteAllByToolId(List<String> toolIdValues) {
    final values = toolIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'toolId', values);
  }

  int deleteAllByToolIdSync(List<String> toolIdValues) {
    final values = toolIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'toolId', values);
  }

  Future<Id> putByToolId(PinnedTool object) {
    return putByIndex(r'toolId', object);
  }

  Id putByToolIdSync(PinnedTool object, {bool saveLinks = true}) {
    return putByIndexSync(r'toolId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByToolId(List<PinnedTool> objects) {
    return putAllByIndex(r'toolId', objects);
  }

  List<Id> putAllByToolIdSync(List<PinnedTool> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'toolId', objects, saveLinks: saveLinks);
  }
}

extension PinnedToolQueryWhereSort
    on QueryBuilder<PinnedTool, PinnedTool, QWhere> {
  QueryBuilder<PinnedTool, PinnedTool, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PinnedToolQueryWhere
    on QueryBuilder<PinnedTool, PinnedTool, QWhereClause> {
  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> idBetween(
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

  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> toolIdEqualTo(
      String toolId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'toolId',
        value: [toolId],
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterWhereClause> toolIdNotEqualTo(
      String toolId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolId',
              lower: [],
              upper: [toolId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolId',
              lower: [toolId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolId',
              lower: [toolId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'toolId',
              lower: [],
              upper: [toolId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PinnedToolQueryFilter
    on QueryBuilder<PinnedTool, PinnedTool, QFilterCondition> {
  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      categoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> categoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      displayOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      displayOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      displayOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      displayOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toolId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toolId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      toolIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toolId',
        value: '',
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      toolNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'toolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'toolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'toolName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      toolNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'toolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'toolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'toolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition> toolNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'toolName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      toolNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'toolName',
        value: '',
      ));
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterFilterCondition>
      toolNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'toolName',
        value: '',
      ));
    });
  }
}

extension PinnedToolQueryObject
    on QueryBuilder<PinnedTool, PinnedTool, QFilterCondition> {}

extension PinnedToolQueryLinks
    on QueryBuilder<PinnedTool, PinnedTool, QFilterCondition> {}

extension PinnedToolQuerySortBy
    on QueryBuilder<PinnedTool, PinnedTool, QSortBy> {
  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByDisplayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByDisplayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByToolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByToolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByToolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolName', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> sortByToolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolName', Sort.desc);
    });
  }
}

extension PinnedToolQuerySortThenBy
    on QueryBuilder<PinnedTool, PinnedTool, QSortThenBy> {
  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByDisplayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByDisplayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByToolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByToolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolId', Sort.desc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByToolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolName', Sort.asc);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QAfterSortBy> thenByToolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'toolName', Sort.desc);
    });
  }
}

extension PinnedToolQueryWhereDistinct
    on QueryBuilder<PinnedTool, PinnedTool, QDistinct> {
  QueryBuilder<PinnedTool, PinnedTool, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QDistinct> distinctByDisplayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayOrder');
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QDistinct> distinctByToolId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toolId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PinnedTool, PinnedTool, QDistinct> distinctByToolName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'toolName', caseSensitive: caseSensitive);
    });
  }
}

extension PinnedToolQueryProperty
    on QueryBuilder<PinnedTool, PinnedTool, QQueryProperty> {
  QueryBuilder<PinnedTool, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PinnedTool, String, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<PinnedTool, int, QQueryOperations> displayOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayOrder');
    });
  }

  QueryBuilder<PinnedTool, String, QQueryOperations> toolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toolId');
    });
  }

  QueryBuilder<PinnedTool, String, QQueryOperations> toolNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'toolName');
    });
  }
}
