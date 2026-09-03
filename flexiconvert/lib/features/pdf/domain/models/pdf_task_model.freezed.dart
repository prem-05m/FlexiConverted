// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PdfTaskState {
  String get id => throw _privateConstructorUsedError;
  PdfToolType get toolType => throw _privateConstructorUsedError;
  List<String> get inputPaths => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;
  List<String>? get outputPaths => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PdfTaskStateCopyWith<PdfTaskState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfTaskStateCopyWith<$Res> {
  factory $PdfTaskStateCopyWith(
          PdfTaskState value, $Res Function(PdfTaskState) then) =
      _$PdfTaskStateCopyWithImpl<$Res, PdfTaskState>;
  @useResult
  $Res call(
      {String id,
      PdfToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      List<String>? outputPaths,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class _$PdfTaskStateCopyWithImpl<$Res, $Val extends PdfTaskState>
    implements $PdfTaskStateCopyWith<$Res> {
  _$PdfTaskStateCopyWithImpl(this._value, this._then);

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
    Object? outputPaths = freezed,
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
              as PdfToolType,
      inputPaths: null == inputPaths
          ? _value.inputPaths
          : inputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      outputPaths: freezed == outputPaths
          ? _value.outputPaths
          : outputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
abstract class _$$PdfTaskStateImplCopyWith<$Res>
    implements $PdfTaskStateCopyWith<$Res> {
  factory _$$PdfTaskStateImplCopyWith(
          _$PdfTaskStateImpl value, $Res Function(_$PdfTaskStateImpl) then) =
      __$$PdfTaskStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      PdfToolType toolType,
      List<String> inputPaths,
      String? outputPath,
      List<String>? outputPaths,
      double progress,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class __$$PdfTaskStateImplCopyWithImpl<$Res>
    extends _$PdfTaskStateCopyWithImpl<$Res, _$PdfTaskStateImpl>
    implements _$$PdfTaskStateImplCopyWith<$Res> {
  __$$PdfTaskStateImplCopyWithImpl(
      _$PdfTaskStateImpl _value, $Res Function(_$PdfTaskStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toolType = null,
    Object? inputPaths = null,
    Object? outputPath = freezed,
    Object? outputPaths = freezed,
    Object? progress = null,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PdfTaskStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as PdfToolType,
      inputPaths: null == inputPaths
          ? _value._inputPaths
          : inputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      outputPaths: freezed == outputPaths
          ? _value._outputPaths
          : outputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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

class _$PdfTaskStateImpl implements _PdfTaskState {
  const _$PdfTaskStateImpl(
      {this.id = '',
      this.toolType = PdfToolType.imageToPdf,
      final List<String> inputPaths = const [],
      this.outputPath,
      final List<String>? outputPaths,
      this.progress = 0.0,
      this.status = TaskStatus.idle,
      this.errorMessage})
      : _inputPaths = inputPaths,
        _outputPaths = outputPaths;

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final PdfToolType toolType;
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
  final List<String>? _outputPaths;
  @override
  List<String>? get outputPaths {
    final value = _outputPaths;
    if (value == null) return null;
    if (_outputPaths is EqualUnmodifiableListView) return _outputPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
    return 'PdfTaskState(id: $id, toolType: $toolType, inputPaths: $inputPaths, outputPath: $outputPath, outputPaths: $outputPaths, progress: $progress, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfTaskStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.toolType, toolType) ||
                other.toolType == toolType) &&
            const DeepCollectionEquality()
                .equals(other._inputPaths, _inputPaths) &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            const DeepCollectionEquality()
                .equals(other._outputPaths, _outputPaths) &&
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
      const DeepCollectionEquality().hash(_outputPaths),
      progress,
      status,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfTaskStateImplCopyWith<_$PdfTaskStateImpl> get copyWith =>
      __$$PdfTaskStateImplCopyWithImpl<_$PdfTaskStateImpl>(this, _$identity);
}

abstract class _PdfTaskState implements PdfTaskState {
  const factory _PdfTaskState(
      {final String id,
      final PdfToolType toolType,
      final List<String> inputPaths,
      final String? outputPath,
      final List<String>? outputPaths,
      final double progress,
      final TaskStatus status,
      final String? errorMessage}) = _$PdfTaskStateImpl;

  @override
  String get id;
  @override
  PdfToolType get toolType;
  @override
  List<String> get inputPaths;
  @override
  String? get outputPath;
  @override
  List<String>? get outputPaths;
  @override
  double get progress;
  @override
  TaskStatus get status;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PdfTaskStateImplCopyWith<_$PdfTaskStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PdfResult {
  String get outputPath => throw _privateConstructorUsedError;
  List<String>? get outputPaths => throw _privateConstructorUsedError;
  int get pageCount => throw _privateConstructorUsedError;
  int get fileSizeBytes => throw _privateConstructorUsedError;
  int get durationMs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PdfResultCopyWith<PdfResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfResultCopyWith<$Res> {
  factory $PdfResultCopyWith(PdfResult value, $Res Function(PdfResult) then) =
      _$PdfResultCopyWithImpl<$Res, PdfResult>;
  @useResult
  $Res call(
      {String outputPath,
      List<String>? outputPaths,
      int pageCount,
      int fileSizeBytes,
      int durationMs});
}

/// @nodoc
class _$PdfResultCopyWithImpl<$Res, $Val extends PdfResult>
    implements $PdfResultCopyWith<$Res> {
  _$PdfResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? outputPaths = freezed,
    Object? pageCount = null,
    Object? fileSizeBytes = null,
    Object? durationMs = null,
  }) {
    return _then(_value.copyWith(
      outputPath: null == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String,
      outputPaths: freezed == outputPaths
          ? _value.outputPaths
          : outputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$PdfResultImplCopyWith<$Res>
    implements $PdfResultCopyWith<$Res> {
  factory _$$PdfResultImplCopyWith(
          _$PdfResultImpl value, $Res Function(_$PdfResultImpl) then) =
      __$$PdfResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String outputPath,
      List<String>? outputPaths,
      int pageCount,
      int fileSizeBytes,
      int durationMs});
}

/// @nodoc
class __$$PdfResultImplCopyWithImpl<$Res>
    extends _$PdfResultCopyWithImpl<$Res, _$PdfResultImpl>
    implements _$$PdfResultImplCopyWith<$Res> {
  __$$PdfResultImplCopyWithImpl(
      _$PdfResultImpl _value, $Res Function(_$PdfResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = null,
    Object? outputPaths = freezed,
    Object? pageCount = null,
    Object? fileSizeBytes = null,
    Object? durationMs = null,
  }) {
    return _then(_$PdfResultImpl(
      outputPath: null == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String,
      outputPaths: freezed == outputPaths
          ? _value._outputPaths
          : outputPaths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      pageCount: null == pageCount
          ? _value.pageCount
          : pageCount // ignore: cast_nullable_to_non_nullable
              as int,
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

class _$PdfResultImpl implements _PdfResult {
  const _$PdfResultImpl(
      {required this.outputPath,
      final List<String>? outputPaths,
      required this.pageCount,
      required this.fileSizeBytes,
      required this.durationMs})
      : _outputPaths = outputPaths;

  @override
  final String outputPath;
  final List<String>? _outputPaths;
  @override
  List<String>? get outputPaths {
    final value = _outputPaths;
    if (value == null) return null;
    if (_outputPaths is EqualUnmodifiableListView) return _outputPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int pageCount;
  @override
  final int fileSizeBytes;
  @override
  final int durationMs;

  @override
  String toString() {
    return 'PdfResult(outputPath: $outputPath, outputPaths: $outputPaths, pageCount: $pageCount, fileSizeBytes: $fileSizeBytes, durationMs: $durationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            const DeepCollectionEquality()
                .equals(other._outputPaths, _outputPaths) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.durationMs, durationMs) ||
                other.durationMs == durationMs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      outputPath,
      const DeepCollectionEquality().hash(_outputPaths),
      pageCount,
      fileSizeBytes,
      durationMs);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfResultImplCopyWith<_$PdfResultImpl> get copyWith =>
      __$$PdfResultImplCopyWithImpl<_$PdfResultImpl>(this, _$identity);
}

abstract class _PdfResult implements PdfResult {
  const factory _PdfResult(
      {required final String outputPath,
      final List<String>? outputPaths,
      required final int pageCount,
      required final int fileSizeBytes,
      required final int durationMs}) = _$PdfResultImpl;

  @override
  String get outputPath;
  @override
  List<String>? get outputPaths;
  @override
  int get pageCount;
  @override
  int get fileSizeBytes;
  @override
  int get durationMs;
  @override
  @JsonKey(ignore: true)
  _$$PdfResultImplCopyWith<_$PdfResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
