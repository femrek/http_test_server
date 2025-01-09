import 'dart:io';

import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

void main() {
  test('test', () async {
    // define test values
    const eResponse = 'Hello, world!';

    final server = await TestServer.createHttpServer(events: [
      StandardServerEvent(
        matcher: ServerEvent.standardMatcher(paths: ['/']),
        handler: (request) => eResponse,
      ),
    ]);

    // Send a request to the server
    final response = await _request('http://localhost:${server.port}');

    // Expect the response
    expect(response, eResponse);

    // Close the server
    await server.close(force: true);
  });
}

Future<String> _request(String url) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));
  final responseStream = await request.close();
  final responseRaw = await responseStream.toList();
  final responseBytes = responseRaw.expand<int>((e) => e).toList();
  final response = String.fromCharCodes(responseBytes);
  return response;
}
