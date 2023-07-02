import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

import 'test_util.dart';

void main() {
  setUp(() async {
    await setUpAssets();
  });

  group('no default document specified', () {
    test('access "/"', () async {
      final handler = createAssetHandler();

      final request = makeRequest();

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.notFound);
    });
  });

  group('default document specified', () {
    test('access "/"', () async {
      final handler = createAssetHandler(defaultDocument: 'index.html');

      final request = makeRequest();

      final response = await handler(request);
      expect(response.statusCode, HttpStatus.ok);
    });
  });
}
