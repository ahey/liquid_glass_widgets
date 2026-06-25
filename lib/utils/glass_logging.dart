import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:logging/logging.dart';

export 'package:logging/logging.dart' show Level, Logger;

/// Package logger namespace.
///
/// The library emits records here but does not install a console listener.
/// Host apps can opt in by listening to `Logger.root.onRecord` and filtering
/// names that start with [GlassLoggers.rootName].
abstract final class GlassLoggers {
  static const rootName = 'lgr';

  static final root = Logger(rootName);
  static final setup = Logger('$rootName.setup');
  static final shaders = Logger('$rootName.shaders');
  static final render = Logger('$rootName.render');
  static final adaptive = Logger('$rootName.adaptive');
  static final performance = Logger('$rootName.performance');

  /// Emits a debug-only log record.
  ///
  /// This keeps developer-only lifecycle diagnostics out of release builds and
  /// still lets host apps opt in through standard `package:logging` listeners.
  static void debugOnly(
    Logger logger,
    Level level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode || !logger.isLoggable(level)) return;
    logger.log(level, message, error, stackTrace);
  }
}
