import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';

/// The default resolver for MIME types.
final _defaultMimeTypeResolver = MimeTypeResolver();

/// Creates a Shelf [Handler] that serves files from Flutter assets.
///
/// If requested resource does not exist and [defaultDocument] is specified,
/// request path is checked for a resource with that name.
/// If it exists, it is served.
///
/// Specify a custom [contentTypeResolver] to customize automatic content type
/// detection.
///
/// If your assets are not in the standard `assets` directory,
/// or you want to share only subtree of the assets path structure,
/// you may use [rootPath] argument to set the root directory for your handler.
Handler createAssetHandler(
    {String? defaultDocument,
    String rootPath = 'assets',
    MimeTypeResolver? contentTypeResolver}) {
  final mimeResolver = contentTypeResolver ?? _defaultMimeTypeResolver;

  return (Request request) async {
    final segments = [rootPath, ...request.url.pathSegments];

    String key = p.joinAll(segments);

    Uint8List? body;

    body = await _loadResource(key);

    if (body == null && defaultDocument != null) {
      key = p.join(key, defaultDocument);

      body = await _loadResource(key);
    }

    if (body == null) {
      return Response.notFound('Not Found');
    }

    final contentType = mimeResolver.lookup(key);

    final headers = {
      HttpHeaders.contentLengthHeader: '${body.length}',
      if (contentType != null) HttpHeaders.contentTypeHeader: contentType,
    };

    return Response.ok((request.method == 'HEAD') ? null : body,
        headers: headers);
  };
}

Future<Uint8List?> _loadResource(String key) async {
  try {
    final byteData = await rootBundle.load(key);

    return byteData.buffer.asUint8List();
  } catch (_) {}

  return null;
}
