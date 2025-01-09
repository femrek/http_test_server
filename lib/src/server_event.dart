import 'dart:io';

/// The function type to match a request with an event.
///
/// The function should return a boolean value that indicates if the request
/// matches the event. The sent request is provided as the argument.
typedef RequestMatcher = bool Function(HttpRequest request);

/// The type of handler function of a [RawServerEvent].
///
/// The function should return an [HttpResponse] that will be responded to the
/// request.
typedef RequestHandler = HttpResponse Function(HttpRequest request);

/// The type of handler function of a [StandardServerEvent].
///
/// The function should return a [String] that will be written to the response
/// body.
typedef RequestHandlerRespondsString = String Function(HttpRequest request);

/// A base class to define a handler for a request comes to server.
///
/// Basically, a server event is a pair of a matcher and a handler. The matcher
/// is a function that takes the request and returns a boolean value. The
/// handler is a function that takes the request and returns a response.
sealed class ServerEvent {
  /// To match a request with the event. Returning true means the request
  /// matches this event.
  ///
  /// When the server gets a request, it will runs the [matcher] function of
  /// each event to find the event that matches the request.
  RequestMatcher get matcher;

  /// The function that is triggered when the request matches the [matcher].
  ///
  /// The function should return an [HttpResponse] or [String] depending on the
  /// type of the event.
  Function get handler;

  /// The default matcher for a standard event.
  ///
  /// This matcher checks only for if the request method is satisfied and the
  /// path is one of the provided paths.
  ///
  /// The [method] is 'GET' by default.
  static RequestMatcher standardMatcher({
    required List<String> paths,
    String? method,
  }) {
    return (request) {
      if (request.method != (method ?? 'GET')) {
        return false;
      }

      if (!paths.contains(request.uri.path)) {
        return false;
      }

      return true;
    };
  }
}

/// A server event that responds with a specified status code and a String body.
///
/// This event is useful when you need to respond with a status code and a
/// String body. If you need to respond with a more complex response, use
/// [RawServerEvent] instead.
class StandardServerEvent extends ServerEvent {
  /// Creates a new [StandardServerEvent] with the given [matcher], [handler],
  /// and [responseStatusCode].
  ///
  /// If [matcher] is not provided, a default matcher is created that matches
  /// requests with the method 'GET' and the path '/' or ''. See
  /// [ServerEvent.standardMatcher] for more information.
  ///
  /// If [responseStatusCode] is not provided, the default status code is 200.
  StandardServerEvent({
    required this.handler,
    this.responseStatusCode = HttpStatus.ok,
    RequestMatcher? matcher,
  }) : matcher = matcher ?? ServerEvent.standardMatcher(paths: ['/']);

  /// The status code to respond with.
  final int responseStatusCode;

  @override
  late final RequestMatcher matcher;

  @override
  final RequestHandlerRespondsString handler;
}

/// A server event that allows handling the request directly.
///
/// This event is useful when you need to define a response with specific
/// properties. [StandardServerEvent] is good when you need to respond with only
/// status code and a String body.
class RawServerEvent extends ServerEvent {
  /// Creates a new [RawServerEvent] with the given [matcher] and [handler].
  ///
  /// If [matcher] is not provided, a default matcher is created that matches
  /// requests with the method 'GET' and the path '/' or ''. See
  /// [ServerEvent.standardMatcher] for more information.
  RawServerEvent({
    required this.handler,
    RequestMatcher? matcher,
  }) : matcher = matcher ?? ServerEvent.standardMatcher(paths: ['/']);

  @override
  final RequestMatcher matcher;

  @override
  final RequestHandler handler;
}
