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
// themes.dart
//
//===------------------------------------------------------------------------------------------===//

import 'package:flutter/material.dart';

class ManiacManagerTheme {
  const ManiacManagerTheme._(this.name, this.data);

  final String name;
  final ThemeData data;
}

final ManiacManagerTheme kDarkManiacManagerTheme =
    new ManiacManagerTheme._('Dark', _buildDarkTheme());
final ManiacManagerTheme kLightManiacManagerTheme =
    new ManiacManagerTheme._('Light', _buildLightTheme());

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    title: base.title.copyWith(
      fontFamily: 'GoogleSans',
    ),
  );
}

TextTheme _buildDarkTextTheme(TextTheme base) {
  return _buildTextTheme(base);
}

TextTheme _buildLightTextTheme(TextTheme base) {
  return _buildTextTheme(base.copyWith(
    title: base.title.copyWith(
      color: Colors.black,
    ),
  ));
}

ThemeData _buildDarkTheme() {
  final ThemeData base = new ThemeData.dark();
  return base.copyWith(
    textTheme: _buildDarkTextTheme(base.textTheme),
    primaryTextTheme: _buildDarkTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildDarkTextTheme(base.accentTextTheme),
  );
}

ThemeData _buildLightTheme() {
  final ThemeData base = new ThemeData.light();
  return base.copyWith(
    primaryColor: Colors.black,
    accentColor: Colors.black,
    textTheme: _buildLightTextTheme(base.textTheme),
    primaryTextTheme: _buildLightTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildLightTextTheme(base.accentTextTheme),
  );
}
