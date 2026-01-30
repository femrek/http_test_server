import 'dart:io';

import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  group('basic tests', () {
    test('basic test with StandardServerEvent', () async {
      // define test values
      const eResponse = 'Hello, world!';

      final server = await TestServer.createHttpServer();

      server.events.add(StandardServerEvent(
        matcher: ServerEvent.standardMatcher(paths: ['/']),
        handler: (request) async => eResponse,
      ));

      // Send a request to the server
      final response = await sendRequest(server.url());

      // Expect the response
      expect(response, eResponse);

      // Close the server
      await server.close();
    });

    test('basic test with RawServerEvent', () async {
      // define test values
      const eResponse = 'Hello, world!';

      final server = await TestServer.createHttpServer();

      server.events.add(RawServerEvent(
        matcher: ServerEvent.standardMatcher(paths: ['/']),
        handler: (request) async {
          return request.response
            ..statusCode = HttpStatus.ok
            ..write(eResponse);
        },
      ));

      // Send a request to the server
      final response = await sendRequest(server.url());

      // Expect the response
      expect(response, eResponse);

      // Close the server
      await server.close();
    });
  });
}
