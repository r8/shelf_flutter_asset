import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

import 'test_util.dart';

void main() {
  setUp(() async {
    await setUpAssets();
  });

  test('access invalid path', () async {
    final handler = createAssetHandler();

    final request = makeRequest(path: '/nested.html');

    final response = await handler(request);
    expect(response.statusCode, equals(HttpStatus.notFound));
  });

  test('access valid path', () async {
    final handler = createAssetHandler(rootPath: 'assets/nested');

    final request = makeRequest(path: '/nested.html');

    final response = await handler(request);
    expect(response.statusCode, equals(HttpStatus.ok));
  });
}
