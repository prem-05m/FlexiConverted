// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_task_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QrTaskState {
  String get id => throw _privateConstructorUsedError;
  QrToolType get toolType => throw _privateConstructorUsedError;
  String? get inputData => throw _privateConstructorUsedError;
  String? get scannedData => throw _privateConstructorUsedError;
  String? get outputPath => throw _privateConstructorUsedError;
  TaskStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QrTaskStateCopyWith<QrTaskState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrTaskStateCopyWith<$Res> {
  factory $QrTaskStateCopyWith(
          QrTaskState value, $Res Function(QrTaskState) then) =
      _$QrTaskStateCopyWithImpl<$Res, QrTaskState>;
  @useResult
  $Res call(
      {String id,
      QrToolType toolType,
      String? inputData,
      String? scannedData,
      String? outputPath,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class _$QrTaskStateCopyWithImpl<$Res, $Val extends QrTaskState>
    implements $QrTaskStateCopyWith<$Res> {
  _$QrTaskStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toolType = null,
    Object? inputData = freezed,
    Object? scannedData = freezed,
    Object? outputPath = freezed,
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
              as QrToolType,
      inputData: freezed == inputData
          ? _value.inputData
          : inputData // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedData: freezed == scannedData
          ? _value.scannedData
          : scannedData // ignore: cast_nullable_to_non_nullable
              as String?,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$QrTaskStateImplCopyWith<$Res>
    implements $QrTaskStateCopyWith<$Res> {
  factory _$$QrTaskStateImplCopyWith(
          _$QrTaskStateImpl value, $Res Function(_$QrTaskStateImpl) then) =
      __$$QrTaskStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      QrToolType toolType,
      String? inputData,
      String? scannedData,
      String? outputPath,
      TaskStatus status,
      String? errorMessage});
}

/// @nodoc
class __$$QrTaskStateImplCopyWithImpl<$Res>
    extends _$QrTaskStateCopyWithImpl<$Res, _$QrTaskStateImpl>
    implements _$$QrTaskStateImplCopyWith<$Res> {
  __$$QrTaskStateImplCopyWithImpl(
      _$QrTaskStateImpl _value, $Res Function(_$QrTaskStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? toolType = null,
    Object? inputData = freezed,
    Object? scannedData = freezed,
    Object? outputPath = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$QrTaskStateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      toolType: null == toolType
          ? _value.toolType
          : toolType // ignore: cast_nullable_to_non_nullable
              as QrToolType,
      inputData: freezed == inputData
          ? _value.inputData
          : inputData // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedData: freezed == scannedData
          ? _value.scannedData
          : scannedData // ignore: cast_nullable_to_non_nullable
              as String?,
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
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

class _$QrTaskStateImpl implements _QrTaskState {
  const _$QrTaskStateImpl(
      {this.id = '',
      this.toolType = QrToolType.generate,
      this.inputData,
      this.scannedData,
      this.outputPath,
      this.status = TaskStatus.idle,
      this.errorMessage});

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final QrToolType toolType;
  @override
  final String? inputData;
  @override
  final String? scannedData;
  @override
  final String? outputPath;
  @override
  @JsonKey()
  final TaskStatus status;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'QrTaskState(id: $id, toolType: $toolType, inputData: $inputData, scannedData: $scannedData, outputPath: $outputPath, status: $status, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrTaskStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.toolType, toolType) ||
                other.toolType == toolType) &&
            (identical(other.inputData, inputData) ||
                other.inputData == inputData) &&
            (identical(other.scannedData, scannedData) ||
                other.scannedData == scannedData) &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, toolType, inputData,
      scannedData, outputPath, status, errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrTaskStateImplCopyWith<_$QrTaskStateImpl> get copyWith =>
      __$$QrTaskStateImplCopyWithImpl<_$QrTaskStateImpl>(this, _$identity);
}

abstract class _QrTaskState implements QrTaskState {
  const factory _QrTaskState(
      {final String id,
      final QrToolType toolType,
      final String? inputData,
      final String? scannedData,
      final String? outputPath,
      final TaskStatus status,
      final String? errorMessage}) = _$QrTaskStateImpl;

  @override
  String get id;
  @override
  QrToolType get toolType;
  @override
  String? get inputData;
  @override
  String? get scannedData;
  @override
  String? get outputPath;
  @override
  TaskStatus get status;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$QrTaskStateImplCopyWith<_$QrTaskStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QrResult {
  String? get outputPath => throw _privateConstructorUsedError;
  String? get scannedData => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QrResultCopyWith<QrResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrResultCopyWith<$Res> {
  factory $QrResultCopyWith(QrResult value, $Res Function(QrResult) then) =
      _$QrResultCopyWithImpl<$Res, QrResult>;
  @useResult
  $Res call(
      {String? outputPath,
      String? scannedData,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$QrResultCopyWithImpl<$Res, $Val extends QrResult>
    implements $QrResultCopyWith<$Res> {
  _$QrResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = freezed,
    Object? scannedData = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedData: freezed == scannedData
          ? _value.scannedData
          : scannedData // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QrResultImplCopyWith<$Res>
    implements $QrResultCopyWith<$Res> {
  factory _$$QrResultImplCopyWith(
          _$QrResultImpl value, $Res Function(_$QrResultImpl) then) =
      __$$QrResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? outputPath,
      String? scannedData,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$QrResultImplCopyWithImpl<$Res>
    extends _$QrResultCopyWithImpl<$Res, _$QrResultImpl>
    implements _$$QrResultImplCopyWith<$Res> {
  __$$QrResultImplCopyWithImpl(
      _$QrResultImpl _value, $Res Function(_$QrResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? outputPath = freezed,
    Object? scannedData = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$QrResultImpl(
      outputPath: freezed == outputPath
          ? _value.outputPath
          : outputPath // ignore: cast_nullable_to_non_nullable
              as String?,
      scannedData: freezed == scannedData
          ? _value.scannedData
          : scannedData // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$QrResultImpl implements _QrResult {
  const _$QrResultImpl(
      {this.outputPath, this.scannedData, final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  @override
  final String? outputPath;
  @override
  final String? scannedData;
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
    return 'QrResult(outputPath: $outputPath, scannedData: $scannedData, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrResultImpl &&
            (identical(other.outputPath, outputPath) ||
                other.outputPath == outputPath) &&
            (identical(other.scannedData, scannedData) ||
                other.scannedData == scannedData) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(runtimeType, outputPath, scannedData,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrResultImplCopyWith<_$QrResultImpl> get copyWith =>
      __$$QrResultImplCopyWithImpl<_$QrResultImpl>(this, _$identity);
}

abstract class _QrResult implements QrResult {
  const factory _QrResult(
      {final String? outputPath,
      final String? scannedData,
      final Map<String, dynamic>? metadata}) = _$QrResultImpl;

  @override
  String? get outputPath;
  @override
  String? get scannedData;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$QrResultImplCopyWith<_$QrResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
