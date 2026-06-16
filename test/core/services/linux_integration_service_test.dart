import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/core/services/linux_integration_service.dart';
import 'package:sqa_multitools/core/services/logging_service.dart';
import 'package:mockito/annotations.dart';

// Setup mock
@GenerateMocks([LoggingService])
import 'linux_integration_service_test.mocks.dart';

void main() {
  group('LinuxIntegrationService Tests', () {
    late MockLoggingService mockLogger;
    late LinuxIntegrationService service;

    setUp(() {
      mockLogger = MockLoggingService();
      service = LinuxIntegrationService(mockLogger);
    });

    test('Service initializes correctly', () {
      expect(service, isNotNull);
    });

    test('Integrate returns early if not Linux', () async {
      // Since tests usually run on the host OS, we can only verify it doesn't crash.
      // If the host is not Linux, it should return immediately.
      await expectLater(service.integrate(), completes);
    });

    test('selfHeal completes without throwing', () async {
      await expectLater(service.selfHeal(), completes);
    });

    test('removeIntegration completes without throwing', () async {
      await expectLater(service.removeIntegration(), completes);
    });
  });
}
