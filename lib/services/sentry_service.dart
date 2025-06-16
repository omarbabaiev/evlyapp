import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService extends GetxService {
  static SentryService get to => Get.find();

  // Sentry DSN - real layihədə .env faylından oxunmalıdır
  static const String _sentryDsn = 'YOUR_SENTRY_DSN';

  // Sentry inicializasiyası
  static Future<void> initialize() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = _sentryDsn;
        options.tracesSampleRate = 1.0;
        options.enableAutoSessionTracking = true;
        options.attachStacktrace = true;
        options.debug = kDebugMode;
      },
    );
  }

  // Xətanı Sentry-ə göndər
  Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    Map<String, dynamic>? extra,
  }) async {
    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          // Əlavə məlumatlar
          if (extra != null) {
            scope.setContexts('extra', extra);
          }

          // User məlumatları (əgər varsa)
          final user = Get.find<dynamic>(); // User service-dən user
          if (user != null) {
            scope.setUser(SentryUser(
              id: user.id,
              email: user.email,
            ));
          }

          // Device məlumatları
          scope.setTag('platform', GetPlatform.isAndroid ? 'android' : 'ios');
          scope.setTag('debug', kDebugMode.toString());
        },
      );
    } catch (e) {
      debugPrint('Sentry xətası: $e');
    }
  }

  // Custom event göndər
  Future<void> captureEvent(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    try {
      await Sentry.captureEvent(
        SentryEvent(
          message: SentryMessage(message),
          level: level,
          extra: extra,
        ),
      );
    } catch (e) {
      debugPrint('Sentry event xətası: $e');
    }
  }

  // Performance tracking
  Future<void> captureTransaction(
    String name,
    String operation,
    Future<void> Function(ISentrySpan span) callback,
  ) async {
    try {
      final transaction = Sentry.startTransaction(
        name,
        operation,
        bindToScope: true,
      );

      try {
        await callback(transaction);
      } catch (exception) {
        transaction.throwable = exception;
        transaction.status = SpanStatus.internalError();
        rethrow;
      } finally {
        await transaction.finish();
      }
    } catch (e) {
      debugPrint('Sentry transaction xətası: $e');
    }
  }
}
