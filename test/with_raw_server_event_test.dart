import 'dart:io';

import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'utils/test_utils.dart';

void main() {
  group('test with RawServerEvent', () {
    <_ParameterizedTestEntry>[
      _ParameterizedTestEntry(
        '/basic',
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic']),
          handler: (request) {
            return request.response
              ..statusCode = HttpStatus.ok
              ..write('Hello, world!');
          },
        ),
        (response) async {
          expect(response.statusCode, HttpStatus.ok);
          expect(response.headers.contentType?.mimeType, 'text/plain');
          expect(response.headers.contentType?.charset, 'utf-8');

          final responseBody = await extractResponseBody(response);
          expect(responseBody, 'Hello, world!');
        },
      ),

      _ParameterizedTestEntry(
        '/custom_not_found',
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/custom_not_found']),
          handler: (req) {
            return req.response
              ..statusCode = HttpStatus.notFound
              ..write('Not Found');
          },
        ),
        (response) async {
          expect(response.statusCode, HttpStatus.notFound);
          expect(response.headers.contentType?.mimeType, 'text/plain');
          expect(response.headers.contentType?.charset, 'utf-8');

          final responseBody = await extractResponseBody(response);
          expect(responseBody, 'Not Found');
        },
      ),

      _ParameterizedTestEntry(
        '/redirect',
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/redirect', '/']),
          handler: (req) {
            if (req.uri.path == '/redirect') {
              return req.response
                ..statusCode = HttpStatus.movedTemporarily
                ..headers.set(
                    'location', 'http://localhost:${req.requestedUri.port}');
            } else if (req.uri.path == '/') {
              return req.response
                ..statusCode = HttpStatus.ok
                ..write('HOME');
            } else {
              return req.response
                ..statusCode = HttpStatus.notFound
                ..write('Not Found');
            }
          },
        ),
        (response) async {
          expect(response.statusCode, HttpStatus.ok);
          expect(response.headers.contentType?.mimeType, 'text/plain');
          expect(response.headers.contentType?.charset, 'utf-8');

          final responseBody = await extractResponseBody(response);
          expect(responseBody, 'HOME');
        },
      ),

      // ignore: avoid_function_literals_in_foreach_calls parameterized test
    ].forEach((e) {
      test(e.path, () async {
        final server = await TestServer.createHttpServer(events: [e.event]);

        // Send a request to the server
        // final response = await sendRequest('http://localhost:${server.port}');
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(
          'http://localhost:${server.port}${e.path}',
        ));
        final httpResponse = await request.close();

        // Expect the response
        await e.expects(httpResponse);

        // Close the server
        await server.close(force: true);
      });
    });
  });
}

class _ParameterizedTestEntry {
  _ParameterizedTestEntry(this.path, this.event, this.expects);

  String path;
  RawServerEvent event;
  Future<void> Function(HttpClientResponse response) expects;
}
