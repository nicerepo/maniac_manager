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
// home.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:maniac_manager/ui/home/meta.dart';
import 'package:maniac_manager/common/network_util.dart';
import 'package:maniac_manager/common/file_util.dart';

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) => new HomeMain();
}

class HomeMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: const Text('Maniac Engine'),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white24),
        body: new HomeWidgets());
  }
}

class HomeWidgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: new Column(children: <Widget>[
      new AboutCard(),
      new InstallerCard(),
    ]));
  }
}

class AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTitle(context),
              _buildCard(context),
            ]));
  }

  Widget _buildTitle(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: new Text('About',
          textAlign: TextAlign.left,
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCard(BuildContext context) {
    return new Card(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          new ListTile(
              dense: true,
              leading: const Icon(Icons.phone_iphone),
              title: const Text('App version'),
              subtitle: const Text(Meta.APP_VERSION),
              onTap: () {}),
          new ListTile(
              dense: true,
              leading: const Icon(Icons.memory),
              title: const Text('Engine version'),
              subtitle: const Text(Meta.ENGINE_VERSION),
              onTap: () {}),
          new Divider(height: 0.0),
          new ListTile(
              dense: true,
              leading: const Icon(Icons.track_changes),
              title: const Text('Changelog'),
              onTap: () {}),
          new ListTile(
              dense: true,
              leading: const Icon(Icons.explore),
              title: const Text('Homepage'),
              onTap: () async => await launch(Meta.HOMEPAGE_URL)),
          new ListTile(
              dense: true,
              leading: const Icon(Icons.code),
              title: const Text('Source code'),
              onTap: () async => await launch(Meta.SOURCECODE_URL)),
        ]));
  }
}

class InstallerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTitle(context),
              _buildCard(context),
            ]));
  }

  Widget _buildTitle(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: new Text('Installer',
          textAlign: TextAlign.left,
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCard(BuildContext context) {
    var paddedOutlineButton = (var text, var onPressed) {
      return new Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new OutlineButton(
              highlightElevation: 0.0, child: text, onPressed: onPressed));
    };

    return new Card(
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          new Padding(padding: const EdgeInsets.symmetric(vertical: 4.0)),
          paddedOutlineButton(const Text('Update Core Engine'),
              () => onInstallPressed(context)),
          new Padding(padding: const EdgeInsets.symmetric(vertical: 4.0)),
        ]));
  }

  Future<void> downloadAndInstall() async {
    await NetworkUtil
        .downloadFile('https://libre.io/maniac/maniacd.zip', 'maniacd.zip')
        .then((File file) => FileUtil.extractArchiveFromPath(
            file.path, '${file.parent.parent.path}/private/utils/'));

    await NetworkUtil
        .downloadFile('https://libre.io/maniac/maniacj.zip', 'maniacj.zip')
        .then((File file) => FileUtil.extractArchiveFromPath(
            file.path, '${file.parent.parent.path}/private/utils/'));

    await NetworkUtil
        .downloadFile('https://libre.io/maniac/maniacrun.zip', 'maniacrun.zip')
        .then((File file) => FileUtil.extractArchiveFromPath(
        file.path, '${file.parent.parent.path}/private/utils/'));
  }

  void onInstallPressed(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new AlertDialog(
            title: const Text('Installing...'),
            content:
                const LinearProgressIndicator(backgroundColor: Colors.white)));

    try {
      await downloadAndInstall();
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                title: const Text('Installation complete'),
                content: const Text('Installation complete'),
              ));
    } on SocketException catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                title: const Text('Network Error'),
                content: new Text('$e'),
              ));
    } on Exception catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
                title: const Text('Error'),
                content: new Text('$e'),
              ));
    }
  }
}
