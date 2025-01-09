import 'dart:io';

Future<String> sendRequest(String url) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));
  final responseStream = await request.close();
  return extractResponseBody(responseStream);
}

Future<String> extractResponseBody(HttpClientResponse response) async {
  final responseStream = await response.toList();
  final responseBytes = responseStream.expand<int>((e) => e).toList();
  final responseBody = String.fromCharCodes(responseBytes);
  return responseBody;
}
