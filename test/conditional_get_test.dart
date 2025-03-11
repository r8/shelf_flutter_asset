import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

import 'test_util.dart';

void main() {
  setUpAll(() async {
    setUpAssets();
  });

  group('Conditional GET Requests', () {
    test('includes Last-Modified header in response', () async {
      final handler = createAssetHandler();
      final request = makeRequest(
        path: '/index.html',
      );
      final response = await handler(request);

      expect(response.statusCode, equals(200));
      expect(response.headers[HttpHeaders.lastModifiedHeader], isNotNull);
      expect(response.headers[HttpHeaders.lastModifiedHeader], isNotEmpty);
    });

    test('returns 304 Not Modified for valid If-Modified-Since header',
        () async {
      // Create a single handler instance for all requests in this test
      // to ensure we get the same Last-Modified timestamp
      final handler = createAssetHandler();

      // First get the Last-Modified value
      final initialRequest = makeRequest(path: '/index.html');
      final initialResponse = await handler(initialRequest);
      final lastModified =
          initialResponse.headers[HttpHeaders.lastModifiedHeader]!;

      // Then make a conditional request with that same timestamp
      final conditionalRequest = makeRequest(
        path: '/index.html',
        headers: {HttpHeaders.ifModifiedSinceHeader: lastModified},
      );

      final conditionalResponse = await handler(conditionalRequest);

      expect(conditionalResponse.statusCode, equals(304));
      expect(await conditionalResponse.read().toList(), isEmpty);
    });

    test('returns 200 OK for If-Modified-Since header with old date', () async {
      final handler = createAssetHandler();

      // Use a date from the past
      final oldDate = HttpDate.format(DateTime(2000, 1, 1));

      final request = makeRequest(
        path: '/index.html',
        headers: {HttpHeaders.ifModifiedSinceHeader: oldDate},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(200));
      expect(await response.read().toList(), isNotEmpty);
    });

    test('ignores invalid If-Modified-Since header', () async {
      final handler = createAssetHandler();

      final request = makeRequest(
        path: '/index.html',
        headers: {HttpHeaders.ifModifiedSinceHeader: 'invalid-date-format'},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(200));
      expect(await response.read().toList(), isNotEmpty);
    });
  });
}
