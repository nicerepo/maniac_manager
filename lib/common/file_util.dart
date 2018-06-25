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
// file_util.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:archive/archive.dart';

class FileUtil {
  static const MethodChannel _channel =
      const MethodChannel('maniac.libre.io/native_files');

  static Future<Uint8List> pick(String mimeType) async {
    Uint8List result = await _channel
        .invokeMethod('pickFile', <String, dynamic>{'mimeType': mimeType});

    return result;
  }

  static Future<bool> extractArchiveFromPath(String src, String dst) async {
    List<int> bytes = await (new File(src).readAsBytes());
    Archive archive = new ZipDecoder().decodeBytes(bytes);

    return extractArchive(archive, dst);
  }

  static Future<bool> extractArchive(Archive archive, String dst) async {
    for (ArchiveFile file in archive) {
      String filename = file.name;

      if (filename.contains('../')) {
        continue;
      }

      if (file.isFile) {
        List<int> data = file.content;
        new File('$dst/$filename')
          ..createSync(recursive: true)
          ..writeAsBytes(data);
      } else {
        new Directory('$dst/$filename')..create(recursive: true);
      }
    }

    return true;
  }
}
