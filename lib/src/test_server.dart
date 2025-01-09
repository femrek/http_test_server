import 'dart:io';

import 'package:http_test_server/src/server_event.dart';

/// A class that creates an HTTP server.
///
/// [createHttpServer] creates an HTTP server and returns it.
abstract final class TestServer {
  /// Creates an HTTP server on the address of given [host] and [port].
  ///
  /// If [port] is not provided, the server will be created on a random port.
  ///
  /// The server listens for incoming requests and matches them with the
  /// provided [events]. If a request matches multiple events, the server
  /// responds with a 500 status code. If no matches are found, the server
  /// responds with a 404 status code.
  static Future<HttpServer> createHttpServer({
    required List<ServerEvent> events,
    InternetAddress? host,
    int? port,
  }) async {
    // Bind the server
    final server = await HttpServer.bind(
      host ?? InternetAddress.anyIPv4,
      port ?? 0,
    );

    // Listen for incoming requests
    server.listen((request) {
      final matches = events.where(
        (event) => event.matcher(request),
      );

      // Check if there are multiple matches
      if (matches.length > 1) {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..write('Multiple matches found')
          ..close();
        return;
      }

      // Check if there are no matches
      final event = matches.firstOrNull;
      if (event == null) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('No matches found')
          ..close();
        return;
      }

      // Process the request
      if (event is StandardServerEvent) {
        request.response
          ..statusCode = event.responseStatusCode
          ..write(event.handler(request))
          ..close();
      } else if (event is RawServerEvent) {
        event.handler(request).close();
      } else {
        throw UnimplementedError('event type not implemented');
      }
    });

    return server;
  }
}
