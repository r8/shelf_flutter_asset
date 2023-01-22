# shelf_flutter_asset

[![pub package](https://img.shields.io/pub/v/shelf_flutter_asset.svg)](https://pub.dev/packages/shelf_flutter_asset)
[![package publisher](https://img.shields.io/pub/publisher/shelf_flutter_asset.svg)](https://pub.dev/packages/shelf_flutter_asset/publisher)

A shelf handler to serve files from Flutter assets.

## Usage

```dart
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_flutter_asset/shelf_flutter_asset.dart';

void main() {
  var handler = createAssetHandler();

  io.serve(handler, 'localhost', 8080);
}
```
