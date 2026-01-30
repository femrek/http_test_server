import 'dart:convert';
import 'dart:io';

import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

void main() {
  test('test', () async {
    // define test values
    const message = 'Hello, World!';

    final server = await TestServer.createHttpServer(events: [
      StandardServerEvent(
        matcher: ServerEvent.standardMatcher(paths: ['/']),
        handler: (request) async => '{"message": "$message"}',
      ),
    ]);
    final url = 'http://localhost:${server.port}';

    // Send a request to the server
    final response = await _request(url);
    final responseModel = ResponseModel.fromJson(response);

    // Expectations
    expect(responseModel.message, message);

    // Close the server
    await server.close(force: true);
  });
}

class ResponseModel {
  ResponseModel({required this.message});

  factory ResponseModel.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ResponseModel(message: map['message'] as String);
  }

  final String message;
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
