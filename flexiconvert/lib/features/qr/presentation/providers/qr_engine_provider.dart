import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_qr_engine.dart';
import '../../domain/engines/qr_engine.dart';

final qrEngineProvider = Provider<QrEngine>((ref) {
  return LocalQrEngine();
});
