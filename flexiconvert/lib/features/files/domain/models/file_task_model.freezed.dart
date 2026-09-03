// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FileTaskState {
  String get id => throw _privateConstructorUsedError;
  FileToolType get toolType => throw _privateConstructorUsedError;
  List<String> get inputPaths => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FileTaskStateCopyWith<FileTaskState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileTaskStateCopyWith<$Res> {
  factory $FileTaskStateCopyWith(
          FileTaskState value, $Res Function(FileTaskState) then) =
      _$FileTaskStateCopyWithImpl<$Res, FileTaskState>;
  @useResult
  $Res call(
      {String id,
      FileToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class _$FileTaskStateCopyWithImpl<$Res, $Val extends FileTaskState>
    implements $FileTaskStateCopyWith<$Res> {
  _$FileTaskStateCopyWithImpl(this._value, this._then);

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
              as FileToolType,
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
abstract class _$$FileTaskStateImplCopyWith<$Res>
    implements $FileTaskStateCopyWith<$Res> {
  factory _$$FileTaskStateImplCopyWith(
          _$FileTaskStateImpl value, $Res Function(_$FileTaskStateImpl) then) =
      __$$FileTaskStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      FileToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class __$$FileTaskStateImplCopyWithImpl<$Res>
    extends _$FileTaskStateCopyWithImpl<$Res, _$FileTaskStateImpl>
    implements _$$FileTaskStateImplCopyWith<$Res> {
  __$$FileTaskStateImplCopyWithImpl(
      _$FileTaskStateImpl _value, $Res Function(_$FileTaskStateImpl) _then)
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
    return _then(_$FileTaskStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as FileToolType,
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

class _$FileTaskStateImpl implements _FileTaskState {
  const _$FileTaskStateImpl(
      {this.id = '',
      this.toolType = FileToolType.rename,
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
  final FileToolType toolType;
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
    return 'FileTaskState(id: $id, toolType: $toolType, inputPaths: $inputPaths, outputPath: $outputPath, progress: $progress, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileTaskStateImpl &&
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
  _$$FileTaskStateImplCopyWith<_$FileTaskStateImpl> get copyWith =>
      __$$FileTaskStateImplCopyWithImpl<_$FileTaskStateImpl>(this, _$identity);
}

abstract class _FileTaskState implements FileTaskState {
  const factory _FileTaskState(
      {final String id,
      final FileToolType toolType,
      final List<String> inputPaths,
      final String? outputPath,
      final double progress,
      final TaskStatus status,
      final String? errorMessage}) = _$FileTaskStateImpl;

  @override
  String get id;
  @override
  FileToolType get toolType;
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
  _$$FileTaskStateImplCopyWith<_$FileTaskStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FileResult {
  String? get outputPath => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<String> get deletedPaths => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FileResultCopyWith<FileResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FileResultCopyWith<$Res> {
  factory $FileResultCopyWith(
          FileResult value, $Res Function(FileResult) then) =
      _$FileResultCopyWithImpl<$Res, FileResult>;
  @useResult
  $Res call(
      {String? outputPath,
      Map<String, dynamic>? metadata,
      List<String> deletedPaths});
}

/// @nodoc
class _$FileResultCopyWithImpl<$Res, $Val extends FileResult>
    implements $FileResultCopyWith<$Res> {
  _$FileResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = freezed,
    Object? metadata = freezed,
    Object? deletedPaths = null,
  }) {
    return _then(_value.copyWith(
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      deletedPaths: null == deletedPaths
          ? _value.deletedPaths
          : deletedPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FileResultImplCopyWith<$Res>
    implements $FileResultCopyWith<$Res> {
  factory _$$FileResultImplCopyWith(
          _$FileResultImpl value, $Res Function(_$FileResultImpl) then) =
      __$$FileResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? outputPath,
      Map<String, dynamic>? metadata,
      List<String> deletedPaths});
}

/// @nodoc
class __$$FileResultImplCopyWithImpl<$Res>
    extends _$FileResultCopyWithImpl<$Res, _$FileResultImpl>
    implements _$$FileResultImplCopyWith<$Res> {
  __$$FileResultImplCopyWithImpl(
      _$FileResultImpl _value, $Res Function(_$FileResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = freezed,
    Object? metadata = freezed,
    Object? deletedPaths = null,
  }) {
    return _then(_$FileResultImpl(
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      deletedPaths: null == deletedPaths
          ? _value._deletedPaths
          : deletedPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$FileResultImpl implements _FileResult {
  const _$FileResultImpl(
      {this.outputPath,
      final Map<String, dynamic>? metadata,
      final List<String> deletedPaths = const []})
      : _metadata = metadata,
        _deletedPaths = deletedPaths;

  @override
  final String? outputPath;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String> _deletedPaths;
  @override
  @JsonKey()
  List<String> get deletedPaths {
    if (_deletedPaths is EqualUnmodifiableListView) return _deletedPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deletedPaths);
  }

  @override
  String toString() {
    return 'FileResult(outputPath: $outputPath, metadata: $metadata, deletedPaths: $deletedPaths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FileResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality()
                .equals(other._deletedPaths, _deletedPaths));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      outputPath,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_deletedPaths));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FileResultImplCopyWith<_$FileResultImpl> get copyWith =>
      __$$FileResultImplCopyWithImpl<_$FileResultImpl>(this, _$identity);
}

abstract class _FileResult implements FileResult {
  const factory _FileResult(
      {final String? outputPath,
      final Map<String, dynamic>? metadata,
      final List<String> deletedPaths}) = _$FileResultImpl;

  @override
  String? get outputPath;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<String> get deletedPaths;
  @override
  @JsonKey(ignore: true)
  _$$FileResultImplCopyWith<_$FileResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
