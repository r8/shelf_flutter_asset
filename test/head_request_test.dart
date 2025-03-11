import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

import 'test_util.dart';

void main() {
  setUp(() async {
    await setUpAssets();
  });

  test('access "/" with GET method', () async {
    final handler = createAssetHandler(defaultDocument: 'index.html');

    final request = makeRequest();

    final response = await handler(request);
    expect(response.statusCode, equals(HttpStatus.ok));
    // GET response should have body
    expect(response.isEmpty, equals(false));
  });

  test('access "/" with HEAD method', () async {
    final handler = createAssetHandler(defaultDocument: 'index.html');

    final request = makeRequest(method: 'HEAD');

    final response = await handler(request);
    expect(response.statusCode, equals(HttpStatus.ok));
    // HEAD response should not have body
    expect(response.isEmpty, equals(true));
  });
}
