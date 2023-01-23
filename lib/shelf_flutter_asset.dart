import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

/// The default resolver for MIME types.
final _defaultMimeTypeResolver = MimeTypeResolver();

/// Creates a Shelf [Handler] that serves files from Flutter assets.
///
/// Specify a custom [contentTypeResolver] to customize automatic content type
/// detection.
Handler createAssetHandler({MimeTypeResolver? contentTypeResolver}) {
  final mimeResolver = contentTypeResolver ?? _defaultMimeTypeResolver;

  return (Request request) async {
    final segments = ['assets', ...request.url.pathSegments];

    final key = p.joinAll(segments);

    try {
      final body = await _loadResource(key);

      final contentType = mimeResolver.lookup(key);

      final headers = {
        HttpHeaders.contentLengthHeader: '${body.length}',
        if (contentType != null) HttpHeaders.contentTypeHeader: contentType,
      };

      return Response.ok(body, headers: headers);
    } catch (_) {
      return Response.notFound('Not Found');
    }
  };
}

Future<Uint8List> _loadResource(String key) async {
  final byteData = await rootBundle.load(key);

  return byteData.buffer.asUint8List();
}
