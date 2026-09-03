import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ErrorInterceptor extends Interceptor {
  final _logger = Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      'API Error [${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      error: err,
    );
    
    // Convert DioException into our custom exception if needed here
    
    super.onError(err, handler);
  }
}
