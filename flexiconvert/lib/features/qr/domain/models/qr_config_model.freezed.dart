// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QrColorConfig {
  Color get color => throw _privateConstructorUsedError;
  bool get useGradient => throw _privateConstructorUsedError;
  QrGradientType get gradientType => throw _privateConstructorUsedError;
  Color get gradientColor => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QrColorConfigCopyWith<QrColorConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrColorConfigCopyWith<$Res> {
  factory $QrColorConfigCopyWith(
          QrColorConfig value, $Res Function(QrColorConfig) then) =
      _$QrColorConfigCopyWithImpl<$Res, QrColorConfig>;
  @useResult
  $Res call(
      {Color color,
      bool useGradient,
      QrGradientType gradientType,
      Color gradientColor});
}

/// @nodoc
class _$QrColorConfigCopyWithImpl<$Res, $Val extends QrColorConfig>
    implements $QrColorConfigCopyWith<$Res> {
  _$QrColorConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? useGradient = null,
    Object? gradientType = null,
    Object? gradientColor = null,
  }) {
    return _then(_value.copyWith(
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      useGradient: null == useGradient
          ? _value.useGradient
          : useGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      gradientType: null == gradientType
          ? _value.gradientType
          : gradientType // ignore: cast_nullable_to_non_nullable
              as QrGradientType,
      gradientColor: null == gradientColor
          ? _value.gradientColor
          : gradientColor // ignore: cast_nullable_to_non_nullable
              as Color,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QrColorConfigImplCopyWith<$Res>
    implements $QrColorConfigCopyWith<$Res> {
  factory _$$QrColorConfigImplCopyWith(
          _$QrColorConfigImpl value, $Res Function(_$QrColorConfigImpl) then) =
      __$$QrColorConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Color color,
      bool useGradient,
      QrGradientType gradientType,
      Color gradientColor});
}

/// @nodoc
class __$$QrColorConfigImplCopyWithImpl<$Res>
    extends _$QrColorConfigCopyWithImpl<$Res, _$QrColorConfigImpl>
    implements _$$QrColorConfigImplCopyWith<$Res> {
  __$$QrColorConfigImplCopyWithImpl(
      _$QrColorConfigImpl _value, $Res Function(_$QrColorConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? color = null,
    Object? useGradient = null,
    Object? gradientType = null,
    Object? gradientColor = null,
  }) {
    return _then(_$QrColorConfigImpl(
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color,
      useGradient: null == useGradient
          ? _value.useGradient
          : useGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      gradientType: null == gradientType
          ? _value.gradientType
          : gradientType // ignore: cast_nullable_to_non_nullable
              as QrGradientType,
      gradientColor: null == gradientColor
          ? _value.gradientColor
          : gradientColor // ignore: cast_nullable_to_non_nullable
              as Color,
    ));
  }
}

/// @nodoc

class _$QrColorConfigImpl implements _QrColorConfig {
  const _$QrColorConfigImpl(
      {this.color = Colors.black,
      this.useGradient = false,
      this.gradientType = QrGradientType.linear,
      this.gradientColor = Colors.red});

  @override
  @JsonKey()
  final Color color;
  @override
  @JsonKey()
  final bool useGradient;
  @override
  @JsonKey()
  final QrGradientType gradientType;
  @override
  @JsonKey()
  final Color gradientColor;

  @override
  String toString() {
    return 'QrColorConfig(color: $color, useGradient: $useGradient, gradientType: $gradientType, gradientColor: $gradientColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrColorConfigImpl &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.useGradient, useGradient) ||
                other.useGradient == useGradient) &&
            (identical(other.gradientType, gradientType) ||
                other.gradientType == gradientType) &&
            (identical(other.gradientColor, gradientColor) ||
                other.gradientColor == gradientColor));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, color, useGradient, gradientType, gradientColor);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrColorConfigImplCopyWith<_$QrColorConfigImpl> get copyWith =>
      __$$QrColorConfigImplCopyWithImpl<_$QrColorConfigImpl>(this, _$identity);
}

abstract class _QrColorConfig implements QrColorConfig {
  const factory _QrColorConfig(
      {final Color color,
      final bool useGradient,
      final QrGradientType gradientType,
      final Color gradientColor}) = _$QrColorConfigImpl;

  @override
  Color get color;
  @override
  bool get useGradient;
  @override
  QrGradientType get gradientType;
  @override
  Color get gradientColor;
  @override
  @JsonKey(ignore: true)
  _$$QrColorConfigImplCopyWith<_$QrColorConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QrConfigModel {
  QrPayloadType get payloadType => throw _privateConstructorUsedError;
  String get data =>
      throw _privateConstructorUsedError; // Used for weblink and text
// Wi-Fi specific
  String get wifiSsid => throw _privateConstructorUsedError;
  String get wifiPassword => throw _privateConstructorUsedError;
  WifiSecurity get wifiSecurity =>
      throw _privateConstructorUsedError; // Contact / vCard specific
  String get vcardFirstName => throw _privateConstructorUsedError;
  String get vcardLastName => throw _privateConstructorUsedError;
  String get vcardPhone => throw _privateConstructorUsedError;
  String get vcardEmail => throw _privateConstructorUsedError;
  String get vcardCompany => throw _privateConstructorUsedError;
  String get vcardJobTitle =>
      throw _privateConstructorUsedError; // Maps specific
  String get mapLatitude => throw _privateConstructorUsedError;
  String get mapLongitude =>
      throw _privateConstructorUsedError; // Email specific
  String get emailAddress => throw _privateConstructorUsedError;
  String get emailSubject => throw _privateConstructorUsedError;
  String get emailBody =>
      throw _privateConstructorUsedError; // WhatsApp specific
  String get whatsappPhone => throw _privateConstructorUsedError;
  String get whatsappMessage =>
      throw _privateConstructorUsedError; // Customizations
  String? get logoPath => throw _privateConstructorUsedError;
  double get logoSize => throw _privateConstructorUsedError; // Styling
  QrOverallShape get overallShape => throw _privateConstructorUsedError;
  QrColorConfig get backgroundColor => throw _privateConstructorUsedError;
  QrDataModuleShape get dotShape => throw _privateConstructorUsedError;
  QrColorConfig get dotColor => throw _privateConstructorUsedError;
  QrEyeShape get cornerOutsideShape => throw _privateConstructorUsedError;
  QrColorConfig get cornerOutsideColor => throw _privateConstructorUsedError;
  QrInnerEyeShape get cornerInsideShape => throw _privateConstructorUsedError;
  QrColorConfig get cornerInsideColor => throw _privateConstructorUsedError;
  QrFrameStyle get frameStyle => throw _privateConstructorUsedError;
  String get frameText => throw _privateConstructorUsedError;
  QrColorConfig get frameColor => throw _privateConstructorUsedError;
  QrColorConfig get frameTextColor => throw _privateConstructorUsedError;
  bool get hasBorder => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $QrConfigModelCopyWith<QrConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrConfigModelCopyWith<$Res> {
  factory $QrConfigModelCopyWith(
          QrConfigModel value, $Res Function(QrConfigModel) then) =
      _$QrConfigModelCopyWithImpl<$Res, QrConfigModel>;
  @useResult
  $Res call(
      {QrPayloadType payloadType,
      String data,
      String wifiSsid,
      String wifiPassword,
      WifiSecurity wifiSecurity,
      String vcardFirstName,
      String vcardLastName,
      String vcardPhone,
      String vcardEmail,
      String vcardCompany,
      String vcardJobTitle,
      String mapLatitude,
      String mapLongitude,
      String emailAddress,
      String emailSubject,
      String emailBody,
      String whatsappPhone,
      String whatsappMessage,
      String? logoPath,
      double logoSize,
      QrOverallShape overallShape,
      QrColorConfig backgroundColor,
      QrDataModuleShape dotShape,
      QrColorConfig dotColor,
      QrEyeShape cornerOutsideShape,
      QrColorConfig cornerOutsideColor,
      QrInnerEyeShape cornerInsideShape,
      QrColorConfig cornerInsideColor,
      QrFrameStyle frameStyle,
      String frameText,
      QrColorConfig frameColor,
      QrColorConfig frameTextColor,
      bool hasBorder});

  $QrColorConfigCopyWith<$Res> get backgroundColor;
  $QrColorConfigCopyWith<$Res> get dotColor;
  $QrColorConfigCopyWith<$Res> get cornerOutsideColor;
  $QrColorConfigCopyWith<$Res> get cornerInsideColor;
  $QrColorConfigCopyWith<$Res> get frameColor;
  $QrColorConfigCopyWith<$Res> get frameTextColor;
}

/// @nodoc
class _$QrConfigModelCopyWithImpl<$Res, $Val extends QrConfigModel>
    implements $QrConfigModelCopyWith<$Res> {
  _$QrConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payloadType = null,
    Object? data = null,
    Object? wifiSsid = null,
    Object? wifiPassword = null,
    Object? wifiSecurity = null,
    Object? vcardFirstName = null,
    Object? vcardLastName = null,
    Object? vcardPhone = null,
    Object? vcardEmail = null,
    Object? vcardCompany = null,
    Object? vcardJobTitle = null,
    Object? mapLatitude = null,
    Object? mapLongitude = null,
    Object? emailAddress = null,
    Object? emailSubject = null,
    Object? emailBody = null,
    Object? whatsappPhone = null,
    Object? whatsappMessage = null,
    Object? logoPath = freezed,
    Object? logoSize = null,
    Object? overallShape = null,
    Object? backgroundColor = null,
    Object? dotShape = null,
    Object? dotColor = null,
    Object? cornerOutsideShape = null,
    Object? cornerOutsideColor = null,
    Object? cornerInsideShape = null,
    Object? cornerInsideColor = null,
    Object? frameStyle = null,
    Object? frameText = null,
    Object? frameColor = null,
    Object? frameTextColor = null,
    Object? hasBorder = null,
  }) {
    return _then(_value.copyWith(
      payloadType: null == payloadType
          ? _value.payloadType
          : payloadType // ignore: cast_nullable_to_non_nullable
              as QrPayloadType,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
      wifiSsid: null == wifiSsid
          ? _value.wifiSsid
          : wifiSsid // ignore: cast_nullable_to_non_nullable
              as String,
      wifiPassword: null == wifiPassword
          ? _value.wifiPassword
          : wifiPassword // ignore: cast_nullable_to_non_nullable
              as String,
      wifiSecurity: null == wifiSecurity
          ? _value.wifiSecurity
          : wifiSecurity // ignore: cast_nullable_to_non_nullable
              as WifiSecurity,
      vcardFirstName: null == vcardFirstName
          ? _value.vcardFirstName
          : vcardFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      vcardLastName: null == vcardLastName
          ? _value.vcardLastName
          : vcardLastName // ignore: cast_nullable_to_non_nullable
              as String,
      vcardPhone: null == vcardPhone
          ? _value.vcardPhone
          : vcardPhone // ignore: cast_nullable_to_non_nullable
              as String,
      vcardEmail: null == vcardEmail
          ? _value.vcardEmail
          : vcardEmail // ignore: cast_nullable_to_non_nullable
              as String,
      vcardCompany: null == vcardCompany
          ? _value.vcardCompany
          : vcardCompany // ignore: cast_nullable_to_non_nullable
              as String,
      vcardJobTitle: null == vcardJobTitle
          ? _value.vcardJobTitle
          : vcardJobTitle // ignore: cast_nullable_to_non_nullable
              as String,
      mapLatitude: null == mapLatitude
          ? _value.mapLatitude
          : mapLatitude // ignore: cast_nullable_to_non_nullable
              as String,
      mapLongitude: null == mapLongitude
          ? _value.mapLongitude
          : mapLongitude // ignore: cast_nullable_to_non_nullable
              as String,
      emailAddress: null == emailAddress
          ? _value.emailAddress
          : emailAddress // ignore: cast_nullable_to_non_nullable
              as String,
      emailSubject: null == emailSubject
          ? _value.emailSubject
          : emailSubject // ignore: cast_nullable_to_non_nullable
              as String,
      emailBody: null == emailBody
          ? _value.emailBody
          : emailBody // ignore: cast_nullable_to_non_nullable
              as String,
      whatsappPhone: null == whatsappPhone
          ? _value.whatsappPhone
          : whatsappPhone // ignore: cast_nullable_to_non_nullable
              as String,
      whatsappMessage: null == whatsappMessage
          ? _value.whatsappMessage
          : whatsappMessage // ignore: cast_nullable_to_non_nullable
              as String,
      logoPath: freezed == logoPath
          ? _value.logoPath
          : logoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      logoSize: null == logoSize
          ? _value.logoSize
          : logoSize // ignore: cast_nullable_to_non_nullable
              as double,
      overallShape: null == overallShape
          ? _value.overallShape
          : overallShape // ignore: cast_nullable_to_non_nullable
              as QrOverallShape,
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      dotShape: null == dotShape
          ? _value.dotShape
          : dotShape // ignore: cast_nullable_to_non_nullable
              as QrDataModuleShape,
      dotColor: null == dotColor
          ? _value.dotColor
          : dotColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      cornerOutsideShape: null == cornerOutsideShape
          ? _value.cornerOutsideShape
          : cornerOutsideShape // ignore: cast_nullable_to_non_nullable
              as QrEyeShape,
      cornerOutsideColor: null == cornerOutsideColor
          ? _value.cornerOutsideColor
          : cornerOutsideColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      cornerInsideShape: null == cornerInsideShape
          ? _value.cornerInsideShape
          : cornerInsideShape // ignore: cast_nullable_to_non_nullable
              as QrInnerEyeShape,
      cornerInsideColor: null == cornerInsideColor
          ? _value.cornerInsideColor
          : cornerInsideColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      frameStyle: null == frameStyle
          ? _value.frameStyle
          : frameStyle // ignore: cast_nullable_to_non_nullable
              as QrFrameStyle,
      frameText: null == frameText
          ? _value.frameText
          : frameText // ignore: cast_nullable_to_non_nullable
              as String,
      frameColor: null == frameColor
          ? _value.frameColor
          : frameColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      frameTextColor: null == frameTextColor
          ? _value.frameTextColor
          : frameTextColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      hasBorder: null == hasBorder
          ? _value.hasBorder
          : hasBorder // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $QrColorConfigCopyWith<$Res> get backgroundColor {
    return $QrColorConfigCopyWith<$Res>(_value.backgroundColor, (value) {
      return _then(_value.copyWith(backgroundColor: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QrColorConfigCopyWith<$Res> get dotColor {
    return $QrColorConfigCopyWith<$Res>(_value.dotColor, (value) {
      return _then(_value.copyWith(dotColor: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QrColorConfigCopyWith<$Res> get cornerOutsideColor {
    return $QrColorConfigCopyWith<$Res>(_value.cornerOutsideColor, (value) {
      return _then(_value.copyWith(cornerOutsideColor: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QrColorConfigCopyWith<$Res> get cornerInsideColor {
    return $QrColorConfigCopyWith<$Res>(_value.cornerInsideColor, (value) {
      return _then(_value.copyWith(cornerInsideColor: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QrColorConfigCopyWith<$Res> get frameColor {
    return $QrColorConfigCopyWith<$Res>(_value.frameColor, (value) {
      return _then(_value.copyWith(frameColor: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $QrColorConfigCopyWith<$Res> get frameTextColor {
    return $QrColorConfigCopyWith<$Res>(_value.frameTextColor, (value) {
      return _then(_value.copyWith(frameTextColor: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$QrConfigModelImplCopyWith<$Res>
    implements $QrConfigModelCopyWith<$Res> {
  factory _$$QrConfigModelImplCopyWith(
          _$QrConfigModelImpl value, $Res Function(_$QrConfigModelImpl) then) =
      __$$QrConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {QrPayloadType payloadType,
      String data,
      String wifiSsid,
      String wifiPassword,
      WifiSecurity wifiSecurity,
      String vcardFirstName,
      String vcardLastName,
      String vcardPhone,
      String vcardEmail,
      String vcardCompany,
      String vcardJobTitle,
      String mapLatitude,
      String mapLongitude,
      String emailAddress,
      String emailSubject,
      String emailBody,
      String whatsappPhone,
      String whatsappMessage,
      String? logoPath,
      double logoSize,
      QrOverallShape overallShape,
      QrColorConfig backgroundColor,
      QrDataModuleShape dotShape,
      QrColorConfig dotColor,
      QrEyeShape cornerOutsideShape,
      QrColorConfig cornerOutsideColor,
      QrInnerEyeShape cornerInsideShape,
      QrColorConfig cornerInsideColor,
      QrFrameStyle frameStyle,
      String frameText,
      QrColorConfig frameColor,
      QrColorConfig frameTextColor,
      bool hasBorder});

  @override
  $QrColorConfigCopyWith<$Res> get backgroundColor;
  @override
  $QrColorConfigCopyWith<$Res> get dotColor;
  @override
  $QrColorConfigCopyWith<$Res> get cornerOutsideColor;
  @override
  $QrColorConfigCopyWith<$Res> get cornerInsideColor;
  @override
  $QrColorConfigCopyWith<$Res> get frameColor;
  @override
  $QrColorConfigCopyWith<$Res> get frameTextColor;
}

/// @nodoc
class __$$QrConfigModelImplCopyWithImpl<$Res>
    extends _$QrConfigModelCopyWithImpl<$Res, _$QrConfigModelImpl>
    implements _$$QrConfigModelImplCopyWith<$Res> {
  __$$QrConfigModelImplCopyWithImpl(
      _$QrConfigModelImpl _value, $Res Function(_$QrConfigModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? payloadType = null,
    Object? data = null,
    Object? wifiSsid = null,
    Object? wifiPassword = null,
    Object? wifiSecurity = null,
    Object? vcardFirstName = null,
    Object? vcardLastName = null,
    Object? vcardPhone = null,
    Object? vcardEmail = null,
    Object? vcardCompany = null,
    Object? vcardJobTitle = null,
    Object? mapLatitude = null,
    Object? mapLongitude = null,
    Object? emailAddress = null,
    Object? emailSubject = null,
    Object? emailBody = null,
    Object? whatsappPhone = null,
    Object? whatsappMessage = null,
    Object? logoPath = freezed,
    Object? logoSize = null,
    Object? overallShape = null,
    Object? backgroundColor = null,
    Object? dotShape = null,
    Object? dotColor = null,
    Object? cornerOutsideShape = null,
    Object? cornerOutsideColor = null,
    Object? cornerInsideShape = null,
    Object? cornerInsideColor = null,
    Object? frameStyle = null,
    Object? frameText = null,
    Object? frameColor = null,
    Object? frameTextColor = null,
    Object? hasBorder = null,
  }) {
    return _then(_$QrConfigModelImpl(
      payloadType: null == payloadType
          ? _value.payloadType
          : payloadType // ignore: cast_nullable_to_non_nullable
              as QrPayloadType,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as String,
      wifiSsid: null == wifiSsid
          ? _value.wifiSsid
          : wifiSsid // ignore: cast_nullable_to_non_nullable
              as String,
      wifiPassword: null == wifiPassword
          ? _value.wifiPassword
          : wifiPassword // ignore: cast_nullable_to_non_nullable
              as String,
      wifiSecurity: null == wifiSecurity
          ? _value.wifiSecurity
          : wifiSecurity // ignore: cast_nullable_to_non_nullable
              as WifiSecurity,
      vcardFirstName: null == vcardFirstName
          ? _value.vcardFirstName
          : vcardFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      vcardLastName: null == vcardLastName
          ? _value.vcardLastName
          : vcardLastName // ignore: cast_nullable_to_non_nullable
              as String,
      vcardPhone: null == vcardPhone
          ? _value.vcardPhone
          : vcardPhone // ignore: cast_nullable_to_non_nullable
              as String,
      vcardEmail: null == vcardEmail
          ? _value.vcardEmail
          : vcardEmail // ignore: cast_nullable_to_non_nullable
              as String,
      vcardCompany: null == vcardCompany
          ? _value.vcardCompany
          : vcardCompany // ignore: cast_nullable_to_non_nullable
              as String,
      vcardJobTitle: null == vcardJobTitle
          ? _value.vcardJobTitle
          : vcardJobTitle // ignore: cast_nullable_to_non_nullable
              as String,
      mapLatitude: null == mapLatitude
          ? _value.mapLatitude
          : mapLatitude // ignore: cast_nullable_to_non_nullable
              as String,
      mapLongitude: null == mapLongitude
          ? _value.mapLongitude
          : mapLongitude // ignore: cast_nullable_to_non_nullable
              as String,
      emailAddress: null == emailAddress
          ? _value.emailAddress
          : emailAddress // ignore: cast_nullable_to_non_nullable
              as String,
      emailSubject: null == emailSubject
          ? _value.emailSubject
          : emailSubject // ignore: cast_nullable_to_non_nullable
              as String,
      emailBody: null == emailBody
          ? _value.emailBody
          : emailBody // ignore: cast_nullable_to_non_nullable
              as String,
      whatsappPhone: null == whatsappPhone
          ? _value.whatsappPhone
          : whatsappPhone // ignore: cast_nullable_to_non_nullable
              as String,
      whatsappMessage: null == whatsappMessage
          ? _value.whatsappMessage
          : whatsappMessage // ignore: cast_nullable_to_non_nullable
              as String,
      logoPath: freezed == logoPath
          ? _value.logoPath
          : logoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      logoSize: null == logoSize
          ? _value.logoSize
          : logoSize // ignore: cast_nullable_to_non_nullable
              as double,
      overallShape: null == overallShape
          ? _value.overallShape
          : overallShape // ignore: cast_nullable_to_non_nullable
              as QrOverallShape,
      backgroundColor: null == backgroundColor
          ? _value.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      dotShape: null == dotShape
          ? _value.dotShape
          : dotShape // ignore: cast_nullable_to_non_nullable
              as QrDataModuleShape,
      dotColor: null == dotColor
          ? _value.dotColor
          : dotColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      cornerOutsideShape: null == cornerOutsideShape
          ? _value.cornerOutsideShape
          : cornerOutsideShape // ignore: cast_nullable_to_non_nullable
              as QrEyeShape,
      cornerOutsideColor: null == cornerOutsideColor
          ? _value.cornerOutsideColor
          : cornerOutsideColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      cornerInsideShape: null == cornerInsideShape
          ? _value.cornerInsideShape
          : cornerInsideShape // ignore: cast_nullable_to_non_nullable
              as QrInnerEyeShape,
      cornerInsideColor: null == cornerInsideColor
          ? _value.cornerInsideColor
          : cornerInsideColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      frameStyle: null == frameStyle
          ? _value.frameStyle
          : frameStyle // ignore: cast_nullable_to_non_nullable
              as QrFrameStyle,
      frameText: null == frameText
          ? _value.frameText
          : frameText // ignore: cast_nullable_to_non_nullable
              as String,
      frameColor: null == frameColor
          ? _value.frameColor
          : frameColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      frameTextColor: null == frameTextColor
          ? _value.frameTextColor
          : frameTextColor // ignore: cast_nullable_to_non_nullable
              as QrColorConfig,
      hasBorder: null == hasBorder
          ? _value.hasBorder
          : hasBorder // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$QrConfigModelImpl implements _QrConfigModel {
  const _$QrConfigModelImpl(
      {this.payloadType = QrPayloadType.weblink,
      this.data = 'https://',
      this.wifiSsid = '',
      this.wifiPassword = '',
      this.wifiSecurity = WifiSecurity.wpa,
      this.vcardFirstName = '',
      this.vcardLastName = '',
      this.vcardPhone = '',
      this.vcardEmail = '',
      this.vcardCompany = '',
      this.vcardJobTitle = '',
      this.mapLatitude = '0.0',
      this.mapLongitude = '0.0',
      this.emailAddress = '',
      this.emailSubject = '',
      this.emailBody = '',
      this.whatsappPhone = '',
      this.whatsappMessage = '',
      this.logoPath,
      this.logoSize = 1.0,
      this.overallShape = QrOverallShape.square,
      this.backgroundColor = const QrColorConfig(color: Colors.white),
      this.dotShape = QrDataModuleShape.square,
      this.dotColor = const QrColorConfig(color: Colors.black),
      this.cornerOutsideShape = QrEyeShape.square,
      this.cornerOutsideColor = const QrColorConfig(color: Colors.black),
      this.cornerInsideShape = QrInnerEyeShape.square,
      this.cornerInsideColor = const QrColorConfig(color: Colors.black),
      this.frameStyle = QrFrameStyle.none,
      this.frameText = 'SCAN ME',
      this.frameColor = const QrColorConfig(color: Colors.black),
      this.frameTextColor = const QrColorConfig(color: Colors.white),
      this.hasBorder = false});

  @override
  @JsonKey()
  final QrPayloadType payloadType;
  @override
  @JsonKey()
  final String data;
// Used for weblink and text
// Wi-Fi specific
  @override
  @JsonKey()
  final String wifiSsid;
  @override
  @JsonKey()
  final String wifiPassword;
  @override
  @JsonKey()
  final WifiSecurity wifiSecurity;
// Contact / vCard specific
  @override
  @JsonKey()
  final String vcardFirstName;
  @override
  @JsonKey()
  final String vcardLastName;
  @override
  @JsonKey()
  final String vcardPhone;
  @override
  @JsonKey()
  final String vcardEmail;
  @override
  @JsonKey()
  final String vcardCompany;
  @override
  @JsonKey()
  final String vcardJobTitle;
// Maps specific
  @override
  @JsonKey()
  final String mapLatitude;
  @override
  @JsonKey()
  final String mapLongitude;
// Email specific
  @override
  @JsonKey()
  final String emailAddress;
  @override
  @JsonKey()
  final String emailSubject;
  @override
  @JsonKey()
  final String emailBody;
// WhatsApp specific
  @override
  @JsonKey()
  final String whatsappPhone;
  @override
  @JsonKey()
  final String whatsappMessage;
// Customizations
  @override
  final String? logoPath;
  @override
  @JsonKey()
  final double logoSize;
// Styling
  @override
  @JsonKey()
  final QrOverallShape overallShape;
  @override
  @JsonKey()
  final QrColorConfig backgroundColor;
  @override
  @JsonKey()
  final QrDataModuleShape dotShape;
  @override
  @JsonKey()
  final QrColorConfig dotColor;
  @override
  @JsonKey()
  final QrEyeShape cornerOutsideShape;
  @override
  @JsonKey()
  final QrColorConfig cornerOutsideColor;
  @override
  @JsonKey()
  final QrInnerEyeShape cornerInsideShape;
  @override
  @JsonKey()
  final QrColorConfig cornerInsideColor;
  @override
  @JsonKey()
  final QrFrameStyle frameStyle;
  @override
  @JsonKey()
  final String frameText;
  @override
  @JsonKey()
  final QrColorConfig frameColor;
  @override
  @JsonKey()
  final QrColorConfig frameTextColor;
  @override
  @JsonKey()
  final bool hasBorder;

  @override
  String toString() {
    return 'QrConfigModel(payloadType: $payloadType, data: $data, wifiSsid: $wifiSsid, wifiPassword: $wifiPassword, wifiSecurity: $wifiSecurity, vcardFirstName: $vcardFirstName, vcardLastName: $vcardLastName, vcardPhone: $vcardPhone, vcardEmail: $vcardEmail, vcardCompany: $vcardCompany, vcardJobTitle: $vcardJobTitle, mapLatitude: $mapLatitude, mapLongitude: $mapLongitude, emailAddress: $emailAddress, emailSubject: $emailSubject, emailBody: $emailBody, whatsappPhone: $whatsappPhone, whatsappMessage: $whatsappMessage, logoPath: $logoPath, logoSize: $logoSize, overallShape: $overallShape, backgroundColor: $backgroundColor, dotShape: $dotShape, dotColor: $dotColor, cornerOutsideShape: $cornerOutsideShape, cornerOutsideColor: $cornerOutsideColor, cornerInsideShape: $cornerInsideShape, cornerInsideColor: $cornerInsideColor, frameStyle: $frameStyle, frameText: $frameText, frameColor: $frameColor, frameTextColor: $frameTextColor, hasBorder: $hasBorder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrConfigModelImpl &&
            (identical(other.payloadType, payloadType) ||
                other.payloadType == payloadType) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.wifiSsid, wifiSsid) ||
                other.wifiSsid == wifiSsid) &&
            (identical(other.wifiPassword, wifiPassword) ||
                other.wifiPassword == wifiPassword) &&
            (identical(other.wifiSecurity, wifiSecurity) ||
                other.wifiSecurity == wifiSecurity) &&
            (identical(other.vcardFirstName, vcardFirstName) ||
                other.vcardFirstName == vcardFirstName) &&
            (identical(other.vcardLastName, vcardLastName) ||
                other.vcardLastName == vcardLastName) &&
            (identical(other.vcardPhone, vcardPhone) ||
                other.vcardPhone == vcardPhone) &&
            (identical(other.vcardEmail, vcardEmail) ||
                other.vcardEmail == vcardEmail) &&
            (identical(other.vcardCompany, vcardCompany) ||
                other.vcardCompany == vcardCompany) &&
            (identical(other.vcardJobTitle, vcardJobTitle) ||
                other.vcardJobTitle == vcardJobTitle) &&
            (identical(other.mapLatitude, mapLatitude) ||
                other.mapLatitude == mapLatitude) &&
            (identical(other.mapLongitude, mapLongitude) ||
                other.mapLongitude == mapLongitude) &&
            (identical(other.emailAddress, emailAddress) ||
                other.emailAddress == emailAddress) &&
            (identical(other.emailSubject, emailSubject) ||
                other.emailSubject == emailSubject) &&
            (identical(other.emailBody, emailBody) ||
                other.emailBody == emailBody) &&
            (identical(other.whatsappPhone, whatsappPhone) ||
                other.whatsappPhone == whatsappPhone) &&
            (identical(other.whatsappMessage, whatsappMessage) ||
                other.whatsappMessage == whatsappMessage) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.logoSize, logoSize) ||
                other.logoSize == logoSize) &&
            (identical(other.overallShape, overallShape) ||
                other.overallShape == overallShape) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.dotShape, dotShape) ||
                other.dotShape == dotShape) &&
            (identical(other.dotColor, dotColor) ||
                other.dotColor == dotColor) &&
            (identical(other.cornerOutsideShape, cornerOutsideShape) ||
                other.cornerOutsideShape == cornerOutsideShape) &&
            (identical(other.cornerOutsideColor, cornerOutsideColor) ||
                other.cornerOutsideColor == cornerOutsideColor) &&
            (identical(other.cornerInsideShape, cornerInsideShape) ||
                other.cornerInsideShape == cornerInsideShape) &&
            (identical(other.cornerInsideColor, cornerInsideColor) ||
                other.cornerInsideColor == cornerInsideColor) &&
            (identical(other.frameStyle, frameStyle) ||
                other.frameStyle == frameStyle) &&
            (identical(other.frameText, frameText) ||
                other.frameText == frameText) &&
            (identical(other.frameColor, frameColor) ||
                other.frameColor == frameColor) &&
            (identical(other.frameTextColor, frameTextColor) ||
                other.frameTextColor == frameTextColor) &&
            (identical(other.hasBorder, hasBorder) ||
                other.hasBorder == hasBorder));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        payloadType,
        data,
        wifiSsid,
        wifiPassword,
        wifiSecurity,
        vcardFirstName,
        vcardLastName,
        vcardPhone,
        vcardEmail,
        vcardCompany,
        vcardJobTitle,
        mapLatitude,
        mapLongitude,
        emailAddress,
        emailSubject,
        emailBody,
        whatsappPhone,
        whatsappMessage,
        logoPath,
        logoSize,
        overallShape,
        backgroundColor,
        dotShape,
        dotColor,
        cornerOutsideShape,
        cornerOutsideColor,
        cornerInsideShape,
        cornerInsideColor,
        frameStyle,
        frameText,
        frameColor,
        frameTextColor,
        hasBorder
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrConfigModelImplCopyWith<_$QrConfigModelImpl> get copyWith =>
      __$$QrConfigModelImplCopyWithImpl<_$QrConfigModelImpl>(this, _$identity);
}

abstract class _QrConfigModel implements QrConfigModel {
  const factory _QrConfigModel(
      {final QrPayloadType payloadType,
      final String data,
      final String wifiSsid,
      final String wifiPassword,
      final WifiSecurity wifiSecurity,
      final String vcardFirstName,
      final String vcardLastName,
      final String vcardPhone,
      final String vcardEmail,
      final String vcardCompany,
      final String vcardJobTitle,
      final String mapLatitude,
      final String mapLongitude,
      final String emailAddress,
      final String emailSubject,
      final String emailBody,
      final String whatsappPhone,
      final String whatsappMessage,
      final String? logoPath,
      final double logoSize,
      final QrOverallShape overallShape,
      final QrColorConfig backgroundColor,
      final QrDataModuleShape dotShape,
      final QrColorConfig dotColor,
      final QrEyeShape cornerOutsideShape,
      final QrColorConfig cornerOutsideColor,
      final QrInnerEyeShape cornerInsideShape,
      final QrColorConfig cornerInsideColor,
      final QrFrameStyle frameStyle,
      final String frameText,
      final QrColorConfig frameColor,
      final QrColorConfig frameTextColor,
      final bool hasBorder}) = _$QrConfigModelImpl;

  @override
  QrPayloadType get payloadType;
  @override
  String get data;
  @override // Used for weblink and text
// Wi-Fi specific
  String get wifiSsid;
  @override
  String get wifiPassword;
  @override
  WifiSecurity get wifiSecurity;
  @override // Contact / vCard specific
  String get vcardFirstName;
  @override
  String get vcardLastName;
  @override
  String get vcardPhone;
  @override
  String get vcardEmail;
  @override
  String get vcardCompany;
  @override
  String get vcardJobTitle;
  @override // Maps specific
  String get mapLatitude;
  @override
  String get mapLongitude;
  @override // Email specific
  String get emailAddress;
  @override
  String get emailSubject;
  @override
  String get emailBody;
  @override // WhatsApp specific
  String get whatsappPhone;
  @override
  String get whatsappMessage;
  @override // Customizations
  String? get logoPath;
  @override
  double get logoSize;
  @override // Styling
  QrOverallShape get overallShape;
  @override
  QrColorConfig get backgroundColor;
  @override
  QrDataModuleShape get dotShape;
  @override
  QrColorConfig get dotColor;
  @override
  QrEyeShape get cornerOutsideShape;
  @override
  QrColorConfig get cornerOutsideColor;
  @override
  QrInnerEyeShape get cornerInsideShape;
  @override
  QrColorConfig get cornerInsideColor;
  @override
  QrFrameStyle get frameStyle;
  @override
  String get frameText;
  @override
  QrColorConfig get frameColor;
  @override
  QrColorConfig get frameTextColor;
  @override
  bool get hasBorder;
  @override
  @JsonKey(ignore: true)
  _$$QrConfigModelImplCopyWith<_$QrConfigModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
