import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';

setUpAssets() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) {
    // The key is the asset key.
    String key = utf8.decode(message!.buffer.asUint8List());

    // Manually load the file.
    var file = File(p.join(p.current, 'test', key));
    final Uint8List encoded = utf8.encoder.convert(file.readAsStringSync());
    return Future.value(encoded.buffer.asByteData());
  });
}

Request makeRequest({String method = 'GET', String path = '/'}) {
  return Request(method, Uri(scheme: 'http', host: 'localhost', path: path));
}
