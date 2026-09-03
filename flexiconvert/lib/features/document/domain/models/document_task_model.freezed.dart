// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DocumentTaskState {
  String get id => throw _privateConstructorUsedError;
  DocumentToolType get toolType => throw _privateConstructorUsedError;
  List<String> get inputPaths => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DocumentTaskStateCopyWith<DocumentTaskState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentTaskStateCopyWith<$Res> {
  factory $DocumentTaskStateCopyWith(
          DocumentTaskState value, $Res Function(DocumentTaskState) then) =
      _$DocumentTaskStateCopyWithImpl<$Res, DocumentTaskState>;
  @useResult
  $Res call(
      {String id,
      DocumentToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class _$DocumentTaskStateCopyWithImpl<$Res, $Val extends DocumentTaskState>
    implements $DocumentTaskStateCopyWith<$Res> {
  _$DocumentTaskStateCopyWithImpl(this._value, this._then);

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
              as DocumentToolType,
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
abstract class _$$DocumentTaskStateImplCopyWith<$Res>
    implements $DocumentTaskStateCopyWith<$Res> {
  factory _$$DocumentTaskStateImplCopyWith(_$DocumentTaskStateImpl value,
          $Res Function(_$DocumentTaskStateImpl) then) =
      __$$DocumentTaskStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DocumentToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class __$$DocumentTaskStateImplCopyWithImpl<$Res>
    extends _$DocumentTaskStateCopyWithImpl<$Res, _$DocumentTaskStateImpl>
    implements _$$DocumentTaskStateImplCopyWith<$Res> {
  __$$DocumentTaskStateImplCopyWithImpl(_$DocumentTaskStateImpl _value,
      $Res Function(_$DocumentTaskStateImpl) _then)
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
    return _then(_$DocumentTaskStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as DocumentToolType,
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

class _$DocumentTaskStateImpl implements _DocumentTaskState {
  const _$DocumentTaskStateImpl(
      {this.id = '',
      this.toolType = DocumentToolType.wordToPdf,
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
  final DocumentToolType toolType;
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
    return 'DocumentTaskState(id: $id, toolType: $toolType, inputPaths: $inputPaths, outputPath: $outputPath, progress: $progress, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentTaskStateImpl &&
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
  _$$DocumentTaskStateImplCopyWith<_$DocumentTaskStateImpl> get copyWith =>
      __$$DocumentTaskStateImplCopyWithImpl<_$DocumentTaskStateImpl>(
          this, _$identity);
}

abstract class _DocumentTaskState implements DocumentTaskState {
  const factory _DocumentTaskState(
      {final String id,
      final DocumentToolType toolType,
      final List<String> inputPaths,
      final String? outputPath,
      final double progress,
      final TaskStatus status,
      final String? errorMessage}) = _$DocumentTaskStateImpl;

  @override
  String get id;
  @override
  DocumentToolType get toolType;
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
  _$$DocumentTaskStateImplCopyWith<_$DocumentTaskStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DocumentResult {
  String get outputPath => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  int get durationMs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DocumentResultCopyWith<DocumentResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentResultCopyWith<$Res> {
  factory $DocumentResultCopyWith(
          DocumentResult value, $Res Function(DocumentResult) then) =
      _$DocumentResultCopyWithImpl<$Res, DocumentResult>;
  @useResult
  $Res call({String outputPath, int fileSizeBytes, int durationMs});
}

/// @nodoc
class _$DocumentResultCopyWithImpl<$Res, $Val extends DocumentResult>
    implements $DocumentResultCopyWith<$Res> {
  _$DocumentResultCopyWithImpl(this._value, this._then);

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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentResultImplCopyWith<$Res>
    implements $DocumentResultCopyWith<$Res> {
  factory _$$DocumentResultImplCopyWith(_$DocumentResultImpl value,
          $Res Function(_$DocumentResultImpl) then) =
      __$$DocumentResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String outputPath, int fileSizeBytes, int durationMs});
}

/// @nodoc
class __$$DocumentResultImplCopyWithImpl<$Res>
    extends _$DocumentResultCopyWithImpl<$Res, _$DocumentResultImpl>
    implements _$$DocumentResultImplCopyWith<$Res> {
  __$$DocumentResultImplCopyWithImpl(
      _$DocumentResultImpl _value, $Res Function(_$DocumentResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? fileSizeBytes = null,
    Object? durationMs = null,
  }) {
    return _then(_$DocumentResultImpl(
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
    ));
  }
}

/// @nodoc

class _$DocumentResultImpl implements _DocumentResult {
  const _$DocumentResultImpl(
      {required this.outputPath,
      required this.fileSizeBytes,
      required this.durationMs});

  @override
  final String outputPath;
  @override
  final int fileSizeBytes;
  @override
  final int durationMs;

  @override
  String toString() {
    return 'DocumentResult(outputPath: $outputPath, fileSizeBytes: $fileSizeBytes, durationMs: $durationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, outputPath, fileSizeBytes, durationMs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentResultImplCopyWith<_$DocumentResultImpl> get copyWith =>
      __$$DocumentResultImplCopyWithImpl<_$DocumentResultImpl>(
          this, _$identity);
}

abstract class _DocumentResult implements DocumentResult {
  const factory _DocumentResult(
      {required final String outputPath,
      required final int fileSizeBytes,
      required final int durationMs}) = _$DocumentResultImpl;

  @override
  String get outputPath;
  @override
  int get fileSizeBytes;
  @override
  int get durationMs;
  @override
  @JsonKey(ignore: true)
  _$$DocumentResultImplCopyWith<_$DocumentResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
