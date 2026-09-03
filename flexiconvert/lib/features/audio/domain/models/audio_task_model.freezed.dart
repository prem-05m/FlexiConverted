// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioTaskState {
  String get id => throw _privateConstructorUsedError;
  AudioToolType get toolType => throw _privateConstructorUsedError;
  List<String> get inputPaths => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioTaskStateCopyWith<AudioTaskState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioTaskStateCopyWith<$Res> {
  factory $AudioTaskStateCopyWith(
          AudioTaskState value, $Res Function(AudioTaskState) then) =
      _$AudioTaskStateCopyWithImpl<$Res, AudioTaskState>;
  @useResult
  $Res call(
      {String id,
      AudioToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class _$AudioTaskStateCopyWithImpl<$Res, $Val extends AudioTaskState>
    implements $AudioTaskStateCopyWith<$Res> {
  _$AudioTaskStateCopyWithImpl(this._value, this._then);

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
              as AudioToolType,
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
abstract class _$$AudioTaskStateImplCopyWith<$Res>
    implements $AudioTaskStateCopyWith<$Res> {
  factory _$$AudioTaskStateImplCopyWith(_$AudioTaskStateImpl value,
          $Res Function(_$AudioTaskStateImpl) then) =
      __$$AudioTaskStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      AudioToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class __$$AudioTaskStateImplCopyWithImpl<$Res>
    extends _$AudioTaskStateCopyWithImpl<$Res, _$AudioTaskStateImpl>
    implements _$$AudioTaskStateImplCopyWith<$Res> {
  __$$AudioTaskStateImplCopyWithImpl(
      _$AudioTaskStateImpl _value, $Res Function(_$AudioTaskStateImpl) _then)
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
    return _then(_$AudioTaskStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as AudioToolType,
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

class _$AudioTaskStateImpl implements _AudioTaskState {
  const _$AudioTaskStateImpl(
      {this.id = '',
      this.toolType = AudioToolType.convertFormat,
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
  final AudioToolType toolType;
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
    return 'AudioTaskState(id: $id, toolType: $toolType, inputPaths: $inputPaths, outputPath: $outputPath, progress: $progress, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioTaskStateImpl &&
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
  _$$AudioTaskStateImplCopyWith<_$AudioTaskStateImpl> get copyWith =>
      __$$AudioTaskStateImplCopyWithImpl<_$AudioTaskStateImpl>(
          this, _$identity);
}

abstract class _AudioTaskState implements AudioTaskState {
  const factory _AudioTaskState(
      {final String id,
      final AudioToolType toolType,
      final List<String> inputPaths,
      final String? outputPath,
      final double progress,
      final TaskStatus status,
      final String? errorMessage}) = _$AudioTaskStateImpl;

  @override
  String get id;
  @override
  AudioToolType get toolType;
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
  _$$AudioTaskStateImplCopyWith<_$AudioTaskStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AudioResult {
  String get outputPath => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  int get durationMs => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AudioResultCopyWith<AudioResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioResultCopyWith<$Res> {
  factory $AudioResultCopyWith(
          AudioResult value, $Res Function(AudioResult) then) =
      _$AudioResultCopyWithImpl<$Res, AudioResult>;
  @useResult
  $Res call(
      {String outputPath,
      int fileSizeBytes,
      int durationMs,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AudioResultCopyWithImpl<$Res, $Val extends AudioResult>
    implements $AudioResultCopyWith<$Res> {
  _$AudioResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? fileSizeBytes = null,
    Object? durationMs = null,
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
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioResultImplCopyWith<$Res>
    implements $AudioResultCopyWith<$Res> {
  factory _$$AudioResultImplCopyWith(
          _$AudioResultImpl value, $Res Function(_$AudioResultImpl) then) =
      __$$AudioResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String outputPath,
      int fileSizeBytes,
      int durationMs,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AudioResultImplCopyWithImpl<$Res>
    extends _$AudioResultCopyWithImpl<$Res, _$AudioResultImpl>
    implements _$$AudioResultImplCopyWith<$Res> {
  __$$AudioResultImplCopyWithImpl(
      _$AudioResultImpl _value, $Res Function(_$AudioResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? fileSizeBytes = null,
    Object? durationMs = null,
    Object? metadata = freezed,
  }) {
    return _then(_$AudioResultImpl(
      outputPath: null == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSizeBytes: null == fileSizeBytes
          ? _value.fileSizeBytes
          : fileSizeBytes // ignore: cast_nullable_to_non_nullable
              as int,
      durationMs: null == durationMs
          ? _value.durationMs
          : durationMs // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$AudioResultImpl implements _AudioResult {
  const _$AudioResultImpl(
      {required this.outputPath,
      required this.fileSizeBytes,
      required this.durationMs,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  @override
  final String outputPath;
  @override
  final int fileSizeBytes;
  @override
  final int durationMs;
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
    return 'AudioResult(outputPath: $outputPath, fileSizeBytes: $fileSizeBytes, durationMs: $durationMs, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, outputPath, fileSizeBytes,
      durationMs, const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioResultImplCopyWith<_$AudioResultImpl> get copyWith =>
      __$$AudioResultImplCopyWithImpl<_$AudioResultImpl>(this, _$identity);
}

abstract class _AudioResult implements AudioResult {
  const factory _AudioResult(
      {required final String outputPath,
      required final int fileSizeBytes,
      required final int durationMs,
      final Map<String, dynamic>? metadata}) = _$AudioResultImpl;

  @override
  String get outputPath;
  @override
  int get fileSizeBytes;
  @override
  int get durationMs;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$AudioResultImplCopyWith<_$AudioResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
