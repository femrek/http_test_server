import 'dart:io';

import 'package:http_test_server/src/server_event.dart';

/// A class that creates an HTTP server.
///
/// [createHttpServer] creates an HTTP server and returns an instance of
/// [TestServer].
///
/// [server] provides access to the underlying [HttpServer] instance.
final class TestServer {
  TestServer._({
    required HttpServer server,
    required List<ServerEvent> events,
  })  : _server = server,
        _events = events;

  /// Creates an HTTP server on the address of given [host] and [port].
  ///
  /// If [port] is not provided, the server will be created on a random port.
  ///
  /// The server listens for incoming requests and matches them with the
  /// provided [events]. If a request matches multiple events, the server
  /// responds with a 500 status code. If no matches are found, the server
  /// responds with a 404 status code.
  static Future<TestServer> createHttpServer({
    List<ServerEvent>? events,
    InternetAddress? host,
    int? port,
  }) async {
    // Bind the server
    final server = await HttpServer.bind(
      host ?? InternetAddress.anyIPv4,
      port ?? 0,
    );

    events ??= [];

    // Create instance and Listen for incoming requests
    return TestServer._(
      server: server,
      events: events,
    ).._startToListen();
  }

  final HttpServer _server;
  final List<ServerEvent> _events;
  bool _isClosed = false;

  /// The underlying [HttpServer] instance.
  HttpServer get server => _server;

  /// The port on which the server is listening.
  int get port {
    if (_isClosed) {
      throw StateError('Server is closed');
    }
    return _server.port;
  }

  /// The address of the server in the format 'http://localhost:port'.
  String url({
    String protocol = 'http',
    String host = 'localhost',
  }) {
    if (_isClosed) {
      throw StateError('Server is closed');
    }
    return '$protocol://$host:$port';
  }

  /// The list of events that the server listens to.
  List<ServerEvent> get events => _events;

  /// Whether the server is closed.
  bool get isClosed => _isClosed;

  /// Closes the server.
  Future<void> close({bool force = true}) async {
    if (_isClosed) {
      throw StateError('Server is already closed');
    }
    await _server.close(force: force);
    _isClosed = true;
  }

  void _startToListen() {
    server.listen((request) {
      final matches = _events.where(
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
  }
}
