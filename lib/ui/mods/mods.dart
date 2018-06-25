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
// mods.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:archive/archive.dart';

import 'package:maniac_manager/ui/mods/mod_info.dart';
import 'package:maniac_manager/common/app_util.dart';
import 'package:maniac_manager/common/file_util.dart';
import 'package:maniac_manager/common/mod_util.dart';
import 'package:maniac_manager/common/package_util.dart';

class Mods extends StatelessWidget {
  const Mods({Key key}) : super(key: key);

  static const String routeName = '/mods';

  @override
  Widget build(BuildContext context) => new ModsMain();
}

final ThemeData _kTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.teal,
  accentColor: Colors.redAccent,
);

class ModsMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: const Text('Maniac Engine'),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white24),
        body: new ModsGridPage());
  }
}

class RalewayStyle extends TextStyle {
  const RalewayStyle({
    double fontSize: 12.0,
    FontWeight fontWeight,
    Color color: Colors.black87,
    double letterSpacing,
    double height,
  }) : super(
          inherit: false,
          color: color,
          fontFamily: 'Raleway',
          fontSize: fontSize,
          fontWeight: fontWeight,
          textBaseline: TextBaseline.alphabetic,
          letterSpacing: letterSpacing,
          height: height,
        );
}

class ModsGridPage extends StatefulWidget {
  const ModsGridPage({Key key}) : super(key: key);

  @override
  _ModsGridPageState createState() => new _ModsGridPageState();
}

class _ModsGridPageState extends State<ModsGridPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? _build(context, snapshot)
            : _buildPending(context);
      },
    );
  }

  Future<List<PackageInfo>> _getData() async {
    return AppUtil.getInstalled();
  }

  Widget _build(BuildContext context, AsyncSnapshot snapshot) {
    return new Theme(
      data: _kTheme.copyWith(platform: Theme.of(context).platform),
      child: new Scaffold(
        key: scaffoldKey,
        body: new CustomScrollView(
          slivers: <Widget>[
            _buildBody(context, snapshot),
          ],
        ),
      ),
    );
  }

  Widget _buildPending(BuildContext context) {
    return new Center(child: const CircularProgressIndicator());
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot snapshot) {
    List<PackageInfo> packages = snapshot.data;
    packages.removeWhere((e) => e.isSystem);
    packages.sort((a, b) => a.applicationName.compareTo(b.applicationName));

    return new SliverPadding(
      padding: new EdgeInsets.all(4.0),
      sliver: new SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500.0,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
          childAspectRatio: 6.0,
        ),
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final PackageInfo package = packages[index];
            return new ModCard(
              package: package,
              onTap: () => showModPage(context, package),
            );
          },
          childCount: packages.length,
        ),
      ),
    );
  }

  void showModPage(BuildContext context, PackageInfo package) {
    Navigator.push(
        context,
        new MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/mods/mod'),
          builder: (BuildContext context) {
            return new Theme(
              data: _kTheme.copyWith(platform: Theme.of(context).platform),
              child: new ModPage(package: package),
            );
          },
        ));
  }
}

class ModCard extends StatelessWidget {
  final TextStyle titleStyle =
      const RalewayStyle(fontSize: 18.0, fontWeight: FontWeight.w600);
  final TextStyle authorStyle =
      const RalewayStyle(fontWeight: FontWeight.w500, color: Colors.black54);

  const ModCard({Key key, this.package, this.onTap}) : super(key: key);

  final PackageInfo package;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: onTap,
      child: new Card(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[_buildEntry(context)],
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context) {
    return new Expanded(
      child: new Row(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(package.applicationName,
                    style: titleStyle,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis),
                new Text('${package.applicationId} (${package.versionName})',
                    style: authorStyle,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ],
      ),
    );
  }
}

class ModPage extends StatefulWidget {
  const ModPage({Key key, this.package}) : super(key: key);

  final PackageInfo package;

  @override
  _ModPageState createState() => new _ModPageState();
}

class _ModPageState extends State<ModPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextStyle titleStyle = const RalewayStyle(fontSize: 26.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: new Stack(children: <Widget>[
          new Material(
            child: new SafeArea(
              child: new Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: new Column(
                      children: <Widget>[]
                        ..add(_buildAppTitle(context))
                        ..add(_buildButtons(context))
                        ..add(new Divider())
                        ..add(_buildModInfoAsync(context)))),
            ),
          )
        ]));
  }

  Widget _buildPending(BuildContext context) {
    return new Center(child: const CircularProgressIndicator());
  }

  Widget _buildIcon(BuildContext context, AsyncSnapshot snapshot) {
    return new Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: new Image.memory(snapshot.data, width: 64.0));
  }

  Widget _buildAppTitle(BuildContext context) {
    return new Row(children: <Widget>[
      new FutureBuilder(
        future: AppUtil.getIcon(widget.package),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? _buildIcon(context, snapshot)
              : _buildPending(context);
        },
      ),
      new Flexible(
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            new Text(widget.package.applicationName,
                style: titleStyle,
                softWrap: false,
                overflow: TextOverflow.ellipsis),
            new Text(widget.package.applicationId,
                softWrap: false, overflow: TextOverflow.ellipsis)
          ])),
    ]);
  }

  Widget _buildInstallModButton(BuildContext context) {
    return new OutlineButton(
        highlightElevation: 0.0,
        child: const Text('Install Mod'),
        onPressed: () async =>
            await _onInstallModPressed(context, widget.package.applicationId));
  }

  Widget _buildLaunchButton(BuildContext context) {
    return new OutlineButton(
      highlightElevation: 0.0,
      child: const Text('Launch'),
      onPressed: () async {
        await AppUtil.run(widget.package);
        ModUtil.inject(widget.package.applicationId);
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return new Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
      _buildInstallModButton(context),
      new Padding(padding: new EdgeInsets.symmetric(horizontal: 4.0)),
      _buildLaunchButton(context),
    ]);
  }

  Widget _buildModInfo(BuildContext context, AsyncSnapshot snapshot) {
    final metadata = snapshot.data;

    List<Widget> widgets = [];

    metadata.forEach((k, v) => widgets.add(new Expanded(
        child: new ModInfo(
            applicationId: widget.package.applicationId,
            metadata: v['metadata'],
            readme: v['readme']))));

    return new Expanded(child: new Column(children: widgets));
  }

  Widget _buildModInfoAsync(BuildContext context) {
    return new FutureBuilder(
      future: ModUtil.loadMetadata(widget.package.applicationId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? _buildModInfo(context, snapshot)
            : _buildPending(context);
      },
    );
  }

  Future<void> _onInstallModPressed(
      BuildContext context, String applicationId) async {
    Uint8List packageFile;

    try {
      packageFile = await FileUtil.pick('application/zip');
    } on PlatformException {
      return;
    }

    Archive archive = new ZipDecoder().decodeBytes(packageFile.toList());

    try {
      await PackageUtil.installPackage(applicationId, archive);

      showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                content: new Text('Installation complete'),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));

      setState(() {});
    } on Exception catch (e) {
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                content: new Text('$e'),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    }
  }
}
