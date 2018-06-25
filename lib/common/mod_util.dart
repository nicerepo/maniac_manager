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
// mod_util.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:maniac_manager/common/system_util.dart';

class ModUtil {
  static Future<Map> loadMetadata(String applicationId) async {
    Directory dataDir = (await getApplicationDocumentsDirectory()).parent;
    Directory packageDir =
        new Directory('${dataDir.path}/private/mods/$applicationId/');

    bool exists = await packageDir.exists();
    if (!exists) return new Map();

    Map data = new Map();

    await for (var entity in packageDir.list(followLinks: false)) {
      File metadata = new File('${entity.path}/metadata.json');
      File readme = new File('${entity.path}/README.md');

      String modName = entity.path.split('/').last;

      data[modName] = new Map();

      await metadata.readAsString().then((String contents) {
        data[modName]['metadata'] = contents;
      });

      await readme.readAsString().then((String contents) {
        data[modName]['readme'] = contents;
      });
    }

    return data;
  }

  static void inject(String applicationId) async {
    Directory dataDir = (await getApplicationDocumentsDirectory()).parent;

    // FIXME
    ['armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'].forEach((arch) async {
      var path = '${dataDir.path}/private/utils/$arch/maniacrun';
      print(path);
      await SystemUtil.setExecutable(path);
      await SystemUtil.runCommand('$path $applicationId');
    });
  }
}
