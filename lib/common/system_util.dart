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
// system_util.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class SystemUtil {
  static const MethodChannel _channel =
      const MethodChannel('maniac.libre.io/native_shell');

  static Future<void> runCommand(String command) async {
    await _channel.invokeMethod('runCommand', <String, dynamic>{
      'command': command,
    });
  }

  static Future<void> setExecutable(String path) async {
    await _channel.invokeMethod('setExecutable', <String, dynamic>{
      'path': path,
    });
  }
}
