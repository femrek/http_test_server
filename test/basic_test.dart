import 'dart:io';

import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  group('basic tests', () {
    test('basic test with StandardServerEvent', () async {
      // define test values
      const eResponse = 'Hello, world!';

      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/']),
          handler: (request) => eResponse,
        ),
      ]);

      // Send a request to the server
      final response = await sendRequest('http://localhost:${server.port}');

      // Expect the response
      expect(response, eResponse);

      // Close the server
      await server.close(force: true);
    });

    test('basic test with RawServerEvent', () async {
      // define test values
      const eResponse = 'Hello, world!';

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/']),
          handler: (request) {
            return request.response
              ..statusCode = HttpStatus.ok
              ..write(eResponse)
              ..close();
          },
        ),
      ]);

      // Send a request to the server
      final response = await sendRequest('http://localhost:${server.port}');

      // Expect the response
      expect(response, eResponse);

      // Close the server
      await server.close(force: true);
    });
  });
}
