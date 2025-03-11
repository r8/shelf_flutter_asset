import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

import 'test_util.dart';

void main() {
  setUpAll(() async {
    setUpAssets();
  });

  group('Range Requests', () {
    test('range request returns valid range', () async {
      final handler = createAssetHandler();
      final request = makeRequest(
        path: '/index.html',
        headers: {'range': 'bytes=0-10'},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(206));
      expect(response.headers['accept-ranges'], equals('bytes'));
      expect(response.headers['content-range'], isNotNull);
      expect(response.headers['content-length'], equals('11'));

      // Verify content is correct
      final body = await response.readAsString();
      expect(body.length, equals(11));
    });

    test('invalid range format returns 416', () async {
      final handler = createAssetHandler();
      final request = makeRequest(
        path: '/index.html',
        headers: {'range': 'invalid-range-format'},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(416));
    });

    test('range outside file bounds returns 416', () async {
      final handler = createAssetHandler();
      final request = makeRequest(
        path: '/index.html',
        headers: {'range': 'bytes=100000-200000'},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(416));
      expect(response.headers['content-range'], contains('*'));
    });

    test('open-ended range request works', () async {
      final handler = createAssetHandler();
      final request = makeRequest(
        path: '/index.html',
        headers: {'range': 'bytes=10-'},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(206));
      expect(response.headers['accept-ranges'], equals('bytes'));
      expect(response.headers['content-range'], isNotNull);
    });

    test('head request with range returns no body', () async {
      final handler = createAssetHandler();
      final request = makeRequest(
        method: 'HEAD',
        path: '/index.html',
        headers: {'range': 'bytes=0-10'},
      );
      final response = await handler(request);

      expect(response.statusCode, equals(206));
      expect(response.headers['accept-ranges'], equals('bytes'));
      expect(response.headers['content-range'], isNotNull);
      expect(response.headers['content-length'], equals('11'));

      // Verify body is empty for HEAD request
      final body = await response.read().toList();
      expect(body, isEmpty);
    });
  });
}
