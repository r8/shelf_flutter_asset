import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

import 'test_util.dart';

void main() {
  setUpAll(() async {
    setUpAssets();
  });

  group('Cache Support', () {
    test('cache-control headers not present by default', () async {
      final handler = createAssetHandler();
      final request = makeRequest(path: '/index.html');
      final response = await handler(request);

      expect(response.statusCode, equals(200));
      expect(response.headers['cache-control'], isNull);
    });

    test('cache-control headers present when enabled', () async {
      final handler = createAssetHandler(enableCaching: true, maxAge: 3600);
      final request = makeRequest(path: '/index.html');
      final response = await handler(request);

      expect(response.statusCode, equals(200));
      expect(response.headers['cache-control'], equals('max-age=3600, public'));
    });

    test('cache-control headers use custom maxAge', () async {
      final handler = createAssetHandler(enableCaching: true, maxAge: 86400);
      final request = makeRequest(path: '/index.html');
      final response = await handler(request);

      expect(response.statusCode, equals(200));
      expect(
          response.headers['cache-control'], equals('max-age=86400, public'));
    });

    test('cache-control headers are not added for 404 responses', () async {
      final handler = createAssetHandler(enableCaching: true);
      final request = makeRequest(path: '/assets/not-found.html');
      final response = await handler(request);

      expect(response.statusCode, equals(404));
      expect(response.headers['cache-control'], isNull);
    });
  });
}
