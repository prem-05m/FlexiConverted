import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/image_repository_impl.dart';
import '../../domain/repositories/image_repository.dart';
import 'image_engine_provider.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final engine = ref.watch(imageEngineProvider);
  return ImageRepositoryImpl(engine);
});
