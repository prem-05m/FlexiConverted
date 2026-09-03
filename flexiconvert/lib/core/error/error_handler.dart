import 'package:logger/logger.dart';
import 'app_exception.dart';
import '../services/snackbar_service.dart';

class ErrorHandler {
  static final _logger = Logger();

  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    _logger.e('An error occurred', error: error, stackTrace: stackTrace);

    String userFriendlyMessage = 'An unexpected error occurred. Please try again.';

    if (error is NetworkException) {
      userFriendlyMessage = 'Network error: ${error.message}';
    } else if (error is ConversionException) {
      userFriendlyMessage = 'Conversion failed: ${error.message}';
    } else if (error is PermissionException) {
      userFriendlyMessage = 'Permission denied: ${error.message}';
    } else if (error is AppException) {
      userFriendlyMessage = error.message;
    }

    SnackbarService.showError(userFriendlyMessage);
  }
}
