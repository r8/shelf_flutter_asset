import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

/// The default resolver for MIME types.
final _defaultMimeTypeResolver = MimeTypeResolver();

Handler createAssetHandler({MimeTypeResolver? contentTypeResolver}) {
  final mimeResolver = contentTypeResolver ?? _defaultMimeTypeResolver;

  return (Request request) async {
    final segments = ['assets', ...request.url.pathSegments];

    final key = p.joinAll(segments);
    final body = (await rootBundle.load(key)).buffer.asUint8List();

    final contentType = mimeResolver.lookup(key);

    final headers = {
      HttpHeaders.contentLengthHeader: '${body.length}',
      if (contentType != null) HttpHeaders.contentTypeHeader: contentType,
    };

    return Response.ok(body, headers: headers);
  };
}