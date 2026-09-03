import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/qr_repository_impl.dart';
import '../../domain/repositories/qr_repository.dart';
import 'qr_engine_provider.dart';

final qrRepositoryProvider = Provider<QrRepository>((ref) {
  final engine = ref.watch(qrEngineProvider);
  return QrRepositoryImpl(engine);
});
