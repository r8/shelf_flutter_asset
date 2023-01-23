# shelf_flutter_asset

[![build status](https://github.com/r8/shelf_flutter_asset/workflows/tests/badge.svg)](https://github.com/r8/shelf_flutter_asset/actions)
[![codecov](https://codecov.io/gh/r8/shelf_flutter_asset/branch/main/graph/badge.svg?token=DXWQ52MGBI)](https://codecov.io/gh/r8/shelf_flutter_asset)
[![pub package](https://img.shields.io/pub/v/shelf_flutter_asset.svg)](https://pub.dev/packages/shelf_flutter_asset)
[![package publisher](https://img.shields.io/pub/publisher/shelf_flutter_asset.svg)](https://pub.dev/packages/shelf_flutter_asset/publisher)

A simple shelf handler to serve files from Flutter assets.

## Usage

Bind as root handler:

```dart
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

void main() {
  var assetHandler = createAssetHandler();

  io.serve(assetHandler, 'localhost', 8080);
}
```

Bind with [`shelf_router`](https://pub.dev/packages/shelf_router):

```dart
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() {
  var app = Router();
  final assetHandler = createAssetHandler();

  app.get('/hello', (Request request) {
    return Response.ok('hello-world');
  });

  app.get('/assets/<ignored|.*>', (Request request) {
    return assetHandler(request.change(path: 'assets'));
  });

  io.serve(app, 'localhost', 8080);
}
```
