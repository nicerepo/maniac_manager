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
// package_util.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:convert/convert.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maniac_manager/common/file_util.dart';

class PackageUtilException implements Exception {
  final String message;
  const PackageUtilException([this.message = ""]);
  String toString() => "PackageUtilException: $message";
}

class PackageUtil {
  static Future<void> installPackage(
      String applicationId, Archive package) async {
    Directory dataDir = (await getApplicationDocumentsDirectory()).parent;
    Directory appDir =
        new Directory('${dataDir.path}/private/mods/$applicationId/');

    var mdBytes = package.findFile('metadata.json').content;
    var sigBytes =
        hex.decode(utf8.decode(package.findFile('metadata.sig').content));

    if (mdBytes.isEmpty || sigBytes.isEmpty) {
      throw new PackageUtilException('Corrupt or malformed archive');
    }

    Map metadata = json.decode(utf8.decode(mdBytes));

    await _verifySignature(
        sigBytes, mdBytes, await _getPublicKey(metadata['author']));
    await _verifyChecksums(package, metadata['checksums']);
    await _installFiles(package, appDir.path + metadata['id']);
  }

  static Future<void> uninstallPackage(
      String applicationId, String modId) async {
    Directory dataDir = (await getApplicationDocumentsDirectory()).parent;
    var path = '${dataDir.path}/private/mods/$applicationId/$modId/';
    await new Directory(path).delete(recursive: true);
  }

  static Future<Uint8List> _getPublicKey(String author) async {
    List<String> keyring =
        (await SharedPreferences.getInstance()).getStringList('keyring');

    if (keyring == null || keyring.isEmpty) {
      throw new PackageUtilException('No matching key found for $author');
    }

    Uint8List publicKey;
    for (var key in keyring) {
      // The Chad Assertion
      assert(key.split(':').length == 2);

      if (key.split(':').first == author) {
        publicKey = hex.decode(key.split(':').last);
        break;
      }
    }

    if (publicKey == null || publicKey.isEmpty) {
      throw new PackageUtilException('No matching key found for $author');
    }

    return publicKey;
  }

  static Future<void> _verifySignature(
      var sigBytes, var mdBytes, var key) async {
    if (await Sodium.cryptoSignVerifyDetached(sigBytes, mdBytes, key) ==
        false) {
      throw new PackageUtilException('Signature verification failed');
    }
  }

  static Future<void> _verifyChecksums(Archive package, Map checksums) async {
    checksums.forEach((key, value) async {
      final file = package.findFile(key).content ?? [];
      final hasher = Sodium.cryptoGenerichash;
      final len = crypto_generichash_BYTES_MAX;
      final hash = hex.encode(await hasher(len, file, null));

      if (value != hash) {
        throw new PackageUtilException('Checksum verification failed');
      }
    });
  }

  static Future<void> _installFiles(Archive package, String packageDir) async {
    await FileUtil.extractArchive(package, packageDir);
  }
}
