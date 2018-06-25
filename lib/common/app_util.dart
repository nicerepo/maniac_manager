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
// app_util.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class PackageInfo {
  PackageInfo(this.applicationName, this.applicationId, this.versionName,
      this.versionCode, this.isSystem);

  final String applicationName;
  final String applicationId;
  final String versionName;
  final int versionCode;
  final bool isSystem;

  static PackageInfo fromJson(dynamic json) {
    return new PackageInfo(json['applicationName'], json['applicationId'],
        json['versionName'], json['versionCode'], json['isSystem']);
  }
}

class AppUtil {
  static const MethodChannel _channel =
      const MethodChannel('maniac.libre.io/native_apps');

  static Future<void> run(PackageInfo package) async {
    await _channel.invokeMethod('run', <String, dynamic>{
      'applicationId': package.applicationId,
    });
  }

  static Future<List<PackageInfo>> getInstalled() async {
    final List<dynamic> result = await _channel.invokeMethod('getAllInstalled');
    final List<PackageInfo> packages =
        result.map(PackageInfo.fromJson).toList();

    return packages;
  }

  static Future<Uint8List> getIcon(PackageInfo package) async {
    final Uint8List result = await _channel.invokeMethod(
        'getIcon', <String, dynamic>{'applicationId': package.applicationId});

    return result;
  }
}
