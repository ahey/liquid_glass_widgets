import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:liquid_glass_widgets/utils/glass_logging.dart';
import 'package:logging/logging.dart';

void main() {
  group('LiquidGlass logging', () {
    late Level originalRootLevel;

    setUp(() {
      originalRootLevel = Logger.root.level;
    });

    tearDown(() {
      Logger.root.level = originalRootLevel;
    });

    testWidgets('initialize is silent by default', (tester) async {
      final debugMessages = <String>[];
      final printMessages = <String>[];
      final originalDebugPrint = debugPrint;

      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) debugMessages.add(message);
      };

      try {
        await runZoned(
          () async {
            await tester.runAsync(() async {
              await LiquidGlassWidgets.initialize(
                enablePerformanceMonitor: false,
              );
            });
          },
          zoneSpecification: ZoneSpecification(
            print: (_, __, ___, message) => printMessages.add(message),
          ),
        );
      } finally {
        debugPrint = originalDebugPrint;
      }

      expect(debugMessages, isEmpty);
      expect(printMessages, isEmpty);
    });

    test('debugOnly emits standard log records when enabled', () async {
      final records = <LogRecord>[];
      Logger.root.level = Level.ALL;
      final subscription = Logger.root.onRecord.listen(records.add);

      try {
        GlassLoggers.debugOnly(
          GlassLoggers.setup,
          Level.FINE,
          'Initializing library',
        );
        GlassLoggers.debugOnly(
          GlassLoggers.setup,
          Level.FINER,
          'Created shader instance',
        );
        await Future<void>.delayed(Duration.zero);
      } finally {
        await subscription.cancel();
      }

      final packageRecords = records
          .where(
              (record) => record.loggerName.startsWith(GlassLoggers.rootName))
          .toList();

      expect(
        packageRecords.map((record) => record.level),
        containsAll([Level.FINE, Level.FINER]),
      );
      expect(
        packageRecords.map((record) => record.message),
        contains('Initializing library'),
      );
      expect(
        packageRecords.map((record) => record.message),
        contains('Created shader instance'),
      );
    });
  });
}
