// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ArchiveTaskState {
  String get id => throw _privateConstructorUsedError;
  ArchiveToolType get toolType => throw _privateConstructorUsedError;
  List<String> get inputPaths => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ArchiveTaskStateCopyWith<ArchiveTaskState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArchiveTaskStateCopyWith<$Res> {
  factory $ArchiveTaskStateCopyWith(
          ArchiveTaskState value, $Res Function(ArchiveTaskState) then) =
      _$ArchiveTaskStateCopyWithImpl<$Res, ArchiveTaskState>;
  @useResult
  $Res call(
      {String id,
      ArchiveToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class _$ArchiveTaskStateCopyWithImpl<$Res, $Val extends ArchiveTaskState>
    implements $ArchiveTaskStateCopyWith<$Res> {
  _$ArchiveTaskStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toolType = null,
    Object? inputPaths = null,
    Object? outputPath = freezed,
    Object? progress = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as ArchiveToolType,
      inputPaths: null == inputPaths
          ? _value.inputPaths
          : inputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArchiveTaskStateImplCopyWith<$Res>
    implements $ArchiveTaskStateCopyWith<$Res> {
  factory _$$ArchiveTaskStateImplCopyWith(_$ArchiveTaskStateImpl value,
          $Res Function(_$ArchiveTaskStateImpl) then) =
      __$$ArchiveTaskStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      ArchiveToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class __$$ArchiveTaskStateImplCopyWithImpl<$Res>
    extends _$ArchiveTaskStateCopyWithImpl<$Res, _$ArchiveTaskStateImpl>
    implements _$$ArchiveTaskStateImplCopyWith<$Res> {
  __$$ArchiveTaskStateImplCopyWithImpl(_$ArchiveTaskStateImpl _value,
      $Res Function(_$ArchiveTaskStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toolType = null,
    Object? inputPaths = null,
    Object? outputPath = freezed,
    Object? progress = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$ArchiveTaskStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as ArchiveToolType,
      inputPaths: null == inputPaths
          ? _value._inputPaths
          : inputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TaskStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ArchiveTaskStateImpl implements _ArchiveTaskState {
  const _$ArchiveTaskStateImpl(
      {this.id = '',
      this.toolType = ArchiveToolType.zip,
      final List<String> inputPaths = const [],
      this.outputPath,
      this.progress = 0.0,
      this.status = TaskStatus.idle,
      this.errorMessage})
      : _inputPaths = inputPaths;

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final ArchiveToolType toolType;
  final List<String> _inputPaths;
  @override
  @JsonKey()
  List<String> get inputPaths {
    if (_inputPaths is EqualUnmodifiableListView) return _inputPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inputPaths);
  }

  @override
  final String? outputPath;
  @override
  @JsonKey()
  final double progress;
  @override
  @JsonKey()
  final TaskStatus status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ArchiveTaskState(id: $id, toolType: $toolType, inputPaths: $inputPaths, outputPath: $outputPath, progress: $progress, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArchiveTaskStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.toolType, toolType) ||
                other.toolType == toolType) &&
            const DeepCollectionEquality()
                .equals(other._inputPaths, _inputPaths) &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      toolType,
      const DeepCollectionEquality().hash(_inputPaths),
      outputPath,
      progress,
      status,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArchiveTaskStateImplCopyWith<_$ArchiveTaskStateImpl> get copyWith =>
      __$$ArchiveTaskStateImplCopyWithImpl<_$ArchiveTaskStateImpl>(
          this, _$identity);
}

abstract class _ArchiveTaskState implements ArchiveTaskState {
  const factory _ArchiveTaskState(
      {final String id,
      final ArchiveToolType toolType,
      final List<String> inputPaths,
      final String? outputPath,
      final double progress,
      final TaskStatus status,
      final String? errorMessage}) = _$ArchiveTaskStateImpl;

  @override
  String get id;
  @override
  ArchiveToolType get toolType;
  @override
  List<String> get inputPaths;
  @override
  String? get outputPath;
  @override
  double get progress;
  @override
  TaskStatus get status;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$ArchiveTaskStateImplCopyWith<_$ArchiveTaskStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ArchiveResult {
  String get outputPath => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ArchiveResultCopyWith<ArchiveResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArchiveResultCopyWith<$Res> {
  factory $ArchiveResultCopyWith(
          ArchiveResult value, $Res Function(ArchiveResult) then) =
      _$ArchiveResultCopyWithImpl<$Res, ArchiveResult>;
  @useResult
  $Res call(
      {String outputPath, int fileSizeBytes, Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ArchiveResultCopyWithImpl<$Res, $Val extends ArchiveResult>
    implements $ArchiveResultCopyWith<$Res> {
  _$ArchiveResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? fileSizeBytes = null,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      outputPath: null == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ArchiveResultImplCopyWith<$Res>
    implements $ArchiveResultCopyWith<$Res> {
  factory _$$ArchiveResultImplCopyWith(
          _$ArchiveResultImpl value, $Res Function(_$ArchiveResultImpl) then) =
      __$$ArchiveResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String outputPath, int fileSizeBytes, Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$ArchiveResultImplCopyWithImpl<$Res>
    extends _$ArchiveResultCopyWithImpl<$Res, _$ArchiveResultImpl>
    implements _$$ArchiveResultImplCopyWith<$Res> {
  __$$ArchiveResultImplCopyWithImpl(
      _$ArchiveResultImpl _value, $Res Function(_$ArchiveResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? fileSizeBytes = null,
    Object? metadata = freezed,
  }) {
    return _then(_$ArchiveResultImpl(
      outputPath: null == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$ArchiveResultImpl implements _ArchiveResult {
  const _$ArchiveResultImpl(
      {required this.outputPath,
      required this.fileSizeBytes,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  @override
  final String outputPath;
  @override
  final int fileSizeBytes;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ArchiveResult(outputPath: $outputPath, fileSizeBytes: $fileSizeBytes, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArchiveResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, outputPath, fileSizeBytes,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ArchiveResultImplCopyWith<_$ArchiveResultImpl> get copyWith =>
      __$$ArchiveResultImplCopyWithImpl<_$ArchiveResultImpl>(this, _$identity);
}

abstract class _ArchiveResult implements ArchiveResult {
  const factory _ArchiveResult(
      {required final String outputPath,
      required final int fileSizeBytes,
      final Map<String, dynamic>? metadata}) = _$ArchiveResultImpl;

  @override
  String get outputPath;
  @override
  int get fileSizeBytes;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$ArchiveResultImplCopyWith<_$ArchiveResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
