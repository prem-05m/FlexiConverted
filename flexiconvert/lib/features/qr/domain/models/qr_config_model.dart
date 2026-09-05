import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'qr_config_model.freezed.dart';

enum QrPayloadType {
  weblink, wifi, text, barcode,
  whatsapp, email, vcard, maps, youtube, facebook, twitter, instagram, googleForms, appMarkets,
  image, audio, pdf, excel
}
enum QrGradientType { linear, radial, none }
enum QrDataModuleShape { square, circle, rounded, diamond, star }
enum QrEyeShape { square, circle, rounded, leaf }
enum QrInnerEyeShape { square, circle, plus, diamond }
enum QrOverallShape { square, circle }
enum WifiSecurity { wpa, wep, none }

enum QrFrameStyle {
  none,
  tooltipTop, tooltipBottom, tooltipLeft, tooltipRight,
  borderThick, borderThin, borderDashed, borderDotted,
  badgeCircle, badgeShield, badgeStarburst,
  layoutHeader, layoutFooter, layoutSplit,
  modernNeon, modernShadow, modernGlass,
  specialtyTicket, specialtyReceipt, specialtyPhone,
  minimalistBrackets, minimalistSidebar,
}

@freezed
class QrColorConfig with _$QrColorConfig {
  const factory QrColorConfig({
    @Default(Colors.black) Color color,
    @Default(false) bool useGradient,
    @Default(QrGradientType.linear) QrGradientType gradientType,
    @Default(Colors.red) Color gradientColor, // 2nd color for gradient
  }) = _QrColorConfig;
}

@freezed
class QrConfigModel with _$QrConfigModel {
  const factory QrConfigModel({
    @Default(QrPayloadType.weblink) QrPayloadType payloadType,
    @Default('https://') String data, // Used for weblink and text
    
    // Wi-Fi specific
    @Default('') String wifiSsid,
    @Default('') String wifiPassword,
    @Default(WifiSecurity.wpa) WifiSecurity wifiSecurity,

    // Contact / vCard specific
    @Default('') String vcardFirstName,
    @Default('') String vcardLastName,
    @Default('') String vcardPhone,
    @Default('') String vcardEmail,
    @Default('') String vcardCompany,
    @Default('') String vcardJobTitle,

    // Maps specific
    @Default('0.0') String mapLatitude,
    @Default('0.0') String mapLongitude,

    // Email specific
    @Default('') String emailAddress,
    @Default('') String emailSubject,
    @Default('') String emailBody,

    // WhatsApp specific
    @Default('') String whatsappPhone,
    @Default('') String whatsappMessage,

    // Customizations
    String? logoPath,
    @Default(1.0) double logoSize,

    // Styling
    @Default(QrOverallShape.square) QrOverallShape overallShape,
    @Default(QrColorConfig(color: Colors.white)) QrColorConfig backgroundColor,
    
    @Default(QrDataModuleShape.square) QrDataModuleShape dotShape,
    @Default(QrColorConfig(color: Colors.black)) QrColorConfig dotColor,
    
    @Default(QrEyeShape.square) QrEyeShape cornerOutsideShape,
    @Default(QrColorConfig(color: Colors.black)) QrColorConfig cornerOutsideColor,
    
    @Default(QrInnerEyeShape.square) QrInnerEyeShape cornerInsideShape,
    @Default(QrColorConfig(color: Colors.black)) QrColorConfig cornerInsideColor,
    
    @Default(QrFrameStyle.none) QrFrameStyle frameStyle,
    @Default('SCAN ME') String frameText,
    @Default(QrColorConfig(color: Colors.black)) QrColorConfig frameColor,
    @Default(QrColorConfig(color: Colors.white)) QrColorConfig frameTextColor,
    
    @Default(false) bool hasBorder,
  }) = _QrConfigModel;
}

extension QrConfigModelX on QrConfigModel {
  String get payloadData {
    switch (payloadType) {
      case QrPayloadType.weblink:
      case QrPayloadType.youtube:
      case QrPayloadType.facebook:
      case QrPayloadType.twitter:
      case QrPayloadType.instagram:
      case QrPayloadType.googleForms:
      case QrPayloadType.appMarkets:
      case QrPayloadType.image:
      case QrPayloadType.audio:
      case QrPayloadType.pdf:
      case QrPayloadType.excel:
        return data.isEmpty ? 'https://' : data; 
      case QrPayloadType.text:
      case QrPayloadType.barcode:
        return data;
      case QrPayloadType.wifi:
        String escape(String str) => str.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll(',', '\\,').replaceAll(':', '\\:');
        final type = wifiSecurity == WifiSecurity.wpa ? 'WPA' : (wifiSecurity == WifiSecurity.wep ? 'WEP' : 'nopass');
        return 'WIFI:S:${escape(wifiSsid)};T:$type;P:${escape(wifiPassword)};;';
      case QrPayloadType.whatsapp:
        final escapedText = Uri.encodeComponent(whatsappMessage);
        return 'https://wa.me/$whatsappPhone?text=$escapedText';
      case QrPayloadType.email:
        final escapedSubject = Uri.encodeComponent(emailSubject);
        final escapedBody = Uri.encodeComponent(emailBody);
        return 'mailto:$emailAddress?subject=$escapedSubject&body=$escapedBody';
      case QrPayloadType.maps:
        return 'geo:$mapLatitude,$mapLongitude';
      case QrPayloadType.vcard:
        return 'BEGIN:VCARD\\nVERSION:3.0\\nN:$vcardLastName;$vcardFirstName\\nFN:$vcardFirstName $vcardLastName\\nORG:$vcardCompany\\nTITLE:$vcardJobTitle\\nTEL:$vcardPhone\\nEMAIL:$vcardEmail\\nEND:VCARD';
    }
  }
}
