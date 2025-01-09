# http_test_server

http_test_server provides a simple way to create a test server for testing HTTP requests.

## Features

- Create an HTTP server in milliseconds.
- Define routes with handlers that return an HTTP response.

## Getting started

Add the package to your `pubspec.yaml` file. Append under `dev_dependencies`, if you only want to use it for testing.

```yaml
dev_dependencies:
  http_test_server: <version> # Check for the latest version on pub.dev
```

## Usage

```dart
import 'package:http_test_server/http_test_server.dart';

void main() async {
  final server = await TestServer.createHttpServer(events: [
    StandardServerEvent(
      matcher: ServerEvent.standardMatcher(paths: ['/']),
      handler: (request) => eResponse,
    ),
  ]);
  
  // Get the port of the server.
  final port = server.port;
  final baseUrl = 'http://localhost:$port';

  /* Send requests to the server with your client that you want to test. */

  // Close the server when you're done.
  await server.close();
}
```
