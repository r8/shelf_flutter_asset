import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';

/// Application start time used for Last-Modified headers
final _appStartTime = DateTime.now();

/// The default resolver for MIME types.
final _defaultMimeTypeResolver = MimeTypeResolver();

/// Default cache duration (1 hour)
const _defaultMaxAge = 3600;

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
///
/// Set [enableCaching] to true to add cache-control headers with [maxAge] seconds
/// (defaults to 1 hour).
///
Handler createAssetHandler(
    {String? defaultDocument,
    String rootPath = 'assets',
    MimeTypeResolver? contentTypeResolver,
    bool enableCaching = false,
    int maxAge = _defaultMaxAge}) {
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

    // Use a fixed last-modified timestamp for static assets
    // This is based on the application start time
    final lastModified = _appStartTime;
    final lastModifiedHeader = HttpDate.format(lastModified);

    final headers = {
      HttpHeaders.contentLengthHeader: '${body.length}',
      if (contentType != null) HttpHeaders.contentTypeHeader: contentType,
      HttpHeaders.lastModifiedHeader: lastModifiedHeader,
    };

    // Check if the resource has been modified since the client's version
    final ifModifiedSince = request.headers[HttpHeaders.ifModifiedSinceHeader];
    if (ifModifiedSince != null) {
      try {
        final clientDate = HttpDate.parse(ifModifiedSince);
        // Compare dates, treating them as equal if they are within 1 second
        // This helps with test reliability and HTTP date precision issues
        final difference = lastModified.difference(clientDate).inSeconds.abs();
        if (difference < 1) {
          return Response.notModified(headers: headers);
        }
      } catch (_) {
        // Invalid date format, ignore header
      }
    }

    // Add cache control headers if enabled
    if (enableCaching) {
      headers[HttpHeaders.cacheControlHeader] = 'max-age=$maxAge, public';
    }

    // Handle range requests
    if (request.headers.containsKey('range')) {
      return _handleRangeRequest(request, body, headers);
    }

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

/// Handles HTTP range requests by parsing the Range header and returning
/// the appropriate partial content response.
Response _handleRangeRequest(
    Request request, Uint8List body, Map<String, String> headers) {
  final rangeHeader = request.headers['range']!;
  final match = RegExp(r'bytes=(\d*)-(\d*)').firstMatch(rangeHeader);

  if (match == null) {
    return Response(416, headers: headers); // Range Not Satisfiable
  }

  final startStr = match.group(1);
  final endStr = match.group(2);

  int start = startStr!.isEmpty ? 0 : int.parse(startStr);
  int end = endStr!.isEmpty ? body.length - 1 : int.parse(endStr);

  // Validate the range
  if (start >= body.length || end >= body.length || start > end) {
    return Response(416, headers: {
      ...headers,
      'content-range': 'bytes */${body.length}',
    });
  }

  // Limit the length to the actual body size
  end = min(end, body.length - 1);

  final length = end - start + 1;
  final rangeBody = body.sublist(start, end + 1);

  final rangeHeaders = {
    ...headers,
    HttpHeaders.contentLengthHeader: '$length',
    'content-range': 'bytes $start-$end/${body.length}',
    'accept-ranges': 'bytes',
  };

  return Response(206, // Partial Content
      body: (request.method == 'HEAD') ? null : rangeBody,
      headers: rangeHeaders);
}
