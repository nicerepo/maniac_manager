//===------------------------------------------------------------------------------------------===//
//
//                        The MANIAC Dynamic Binary Instrumentation Engine
//
//===------------------------------------------------------------------------------------------===//
//
// Copyright (C) 2018 Libre.io Developers
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
//===------------------------------------------------------------------------------------------===//
//
// network_util.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class NetworkUtil {
  static var _httpClient = new HttpClient();

  static Future<File> downloadFile(String url, String filename) async {
    var request = await _httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    var dir = await getApplicationDocumentsDirectory();

    File file = new File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);

    return file;
  }

  static Future<Uint8List> consolidateHttpClientResponseBytes(
      HttpClientResponse response) {
    assert(response.contentLength != null);

    final Completer<Uint8List> completer = new Completer<Uint8List>.sync();

    if (response.contentLength == -1) {
      final List<List<int>> chunks = <List<int>>[];
      int contentLength = 0;
      response.listen((List<int> chunk) {
        chunks.add(chunk);
        contentLength += chunk.length;
      }, onDone: () {
        final Uint8List bytes = new Uint8List(contentLength);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        completer.complete(bytes);
      }, onError: completer.completeError, cancelOnError: true);
    } else {
      final Uint8List bytes = new Uint8List(response.contentLength);
      int offset = 0;
      response.listen(
          (List<int> chunk) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          },
          onError: completer.completeError,
          onDone: () {
            completer.complete(bytes);
          },
          cancelOnError: true);
    }

    return completer.future;
  }
}
