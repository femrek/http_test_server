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

## License

```
MIT License

Copyright (c) 2025 Faruk Emre

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
