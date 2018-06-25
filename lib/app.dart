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
// app.dart
//
//===------------------------------------------------------------------------------------------===//

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:maniac_manager/themes.dart';
import 'package:maniac_manager/ui/home/home.dart';
import 'package:maniac_manager/ui/mods/mods.dart';
import 'package:maniac_manager/ui/settings/settings.dart';

class ManiacApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: kLightManiacManagerTheme.data
          .copyWith(platform: defaultTargetPlatform),
      title: 'Maniac Engine',
      home: new MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  PageController _pageController;

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new PageView(
            physics: new NeverScrollableScrollPhysics(),
            children: [
              new Home(),
              new Mods(),
              new Settings(),
            ],
            controller: _pageController,
            onPageChanged: onPageChanged),
        bottomNavigationBar: new BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.home), title: new Text('Home')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.extension), title: new Text('Mods')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.settings), title: new Text('Settings'))
          ],
          onTap: navigationTapped,
          currentIndex: _page,
        ));
  }

  void navigationTapped(int page) {
    _pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}
