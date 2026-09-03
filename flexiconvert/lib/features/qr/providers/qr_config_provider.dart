import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/models/qr_config_model.dart';
import 'package:flutter/material.dart';

part 'qr_config_provider.g.dart';

@riverpod
class QrConfig extends _$QrConfig {
  @override
  QrConfigModel build() {
    return const QrConfigModel();
  }

  void updatePayloadType(QrPayloadType type) {
    state = state.copyWith(
      payloadType: type,
      data: (type == QrPayloadType.weblink || 
             type == QrPayloadType.youtube || 
             type == QrPayloadType.facebook || 
             type == QrPayloadType.twitter || 
             type == QrPayloadType.instagram || 
             type == QrPayloadType.googleForms || 
             type == QrPayloadType.appMarkets) ? 'https://' : '',
    );
  }

  void updateData(String data) {
    state = state.copyWith(data: data);
  }

  void updateWifi({String? ssid, String? password, WifiSecurity? security}) {
    state = state.copyWith(
      wifiSsid: ssid ?? state.wifiSsid,
      wifiPassword: password ?? state.wifiPassword,
      wifiSecurity: security ?? state.wifiSecurity,
    );
  }
  
  void updateVcard({String? first, String? last, String? phone, String? email, String? company, String? job}) {
    state = state.copyWith(
      vcardFirstName: first ?? state.vcardFirstName,
      vcardLastName: last ?? state.vcardLastName,
      vcardPhone: phone ?? state.vcardPhone,
      vcardEmail: email ?? state.vcardEmail,
      vcardCompany: company ?? state.vcardCompany,
      vcardJobTitle: job ?? state.vcardJobTitle,
    );
  }

  void updateMap({String? lat, String? lng}) {
    state = state.copyWith(
      mapLatitude: lat ?? state.mapLatitude,
      mapLongitude: lng ?? state.mapLongitude,
    );
  }

  void updateEmail({String? address, String? subject, String? body}) {
    state = state.copyWith(
      emailAddress: address ?? state.emailAddress,
      emailSubject: subject ?? state.emailSubject,
      emailBody: body ?? state.emailBody,
    );
  }

  void updateWhatsapp({String? phone, String? message}) {
    state = state.copyWith(
      whatsappPhone: phone ?? state.whatsappPhone,
      whatsappMessage: message ?? state.whatsappMessage,
    );
  }

  void updateLogo(String? path) {
    state = state.copyWith(logoPath: path);
  }

  void updateLogoSize(double size) {
    state = state.copyWith(logoSize: size);
  }

  void updateBackgroundColor(QrColorConfig config) {
    state = state.copyWith(backgroundColor: config);
  }

  void updateDotStyle(QrDataModuleShape shape, QrColorConfig config) {
    state = state.copyWith(dotShape: shape, dotColor: config);
  }

  void updateCornerOutsideStyle(QrEyeShape shape, QrColorConfig config) {
    state = state.copyWith(cornerOutsideShape: shape, cornerOutsideColor: config);
  }

  void updateCornerInsideStyle(QrInnerEyeShape shape, QrColorConfig config) {
    state = state.copyWith(cornerInsideShape: shape, cornerInsideColor: config);
  }

  void updateOverallShape(QrOverallShape shape) {
    state = state.copyWith(overallShape: shape);
  }
  
  void updateFrameStyle({QrFrameStyle? style, String? text, QrColorConfig? color, QrColorConfig? textColor}) {
    state = state.copyWith(
      frameStyle: style ?? state.frameStyle,
      frameText: text ?? state.frameText,
      frameColor: color ?? state.frameColor,
      frameTextColor: textColor ?? state.frameTextColor,
    );
  }
}
