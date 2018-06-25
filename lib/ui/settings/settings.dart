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
// settings.dart
//
//===------------------------------------------------------------------------------------------===//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatelessWidget {
  const Settings({Key key}) : super(key: key);

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) => new SettingsMain();
}

class SettingsMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: const Text('Maniac Engine'),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white24),
        body: new SettingsPrefPage());
  }
}

class SettingsPrefPage extends StatefulWidget {
  const SettingsPrefPage({Key key}) : super(key: key);

  @override
  _SettingsPrefPageState createState() => new _SettingsPrefPageState();
}

class _SettingsPrefPageState extends State<SettingsPrefPage> {
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

  Future<SharedPreferences> _getData() async {
    return SharedPreferences.getInstance();
  }

  Widget _build(BuildContext context, AsyncSnapshot snapshot) {
    return new SettingsCard(prefs: snapshot.data);
  }

  Widget _buildPending(BuildContext context) {
    return new Center(child: const CircularProgressIndicator());
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildCard(context),
            ]));
  }

  Widget _buildCard(BuildContext context) {
    return new Card(
        child: new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new ListTile(
            title: new Text('Use unattended mode'),
            trailing: new Switch(
                value: prefs.getBool('isUnattendedModeEnabled') ?? false,
                onChanged: (bool value) =>
                    prefs.setBool('isUnattendedModeEnabled', value)),
            onTap: () {}),
        new Divider(height: 0.0),
        new ListTile(
            leading: const Icon(Icons.fingerprint),
            title: new Text('Key management'),
            onTap: () => this.showKeysPage(context, prefs))
      ],
    ));
  }

  void showKeysPage(BuildContext context, SharedPreferences prefs) {
    Navigator.push(
        context,
        new MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/settings/keys'),
          builder: (BuildContext context) => new KeysPage(prefs: prefs),
        ));
  }
}

class KeysPage extends StatefulWidget {
  const KeysPage({Key key, this.prefs}) : super(key: key);

  final SharedPreferences prefs;

  @override
  _KeysPageState createState() => new _KeysPageState();
}

class _KeysPageState extends State<KeysPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  List<String> _keyring;
  String _keyEntryAuthor;
  String _keyEntryKey;

  @override
  Widget build(BuildContext context) {
    _keyring = widget.prefs.getStringList('keyring') ?? [];

    return new Scaffold(
      key: _scaffoldKey,
      floatingActionButton: new FloatingActionButton(
        onPressed: () async => _showNewKeyDialog(context),
        backgroundColor: Colors.redAccent,
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add',
        ),
      ),
      body: new SafeArea(child: _buildKeysList(context)),
    );
  }

  Widget _buildKeysListTrailingButton(BuildContext context, String key) {
    return new PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        onSelected: (String value) => this.setState(() {
              _keyring.remove(key);
              widget.prefs.setStringList('keyring', _keyring);
            }),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                  value: 'Remove',
                  child: const ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Remove')))
            ]);
  }

  Widget _buildKeysList(BuildContext context) {
    return new ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: _keyring
            .map((i) => new ListTile(
                onTap: () {},
                title: new Text(i.split(':').first),
                subtitle: new Text(i.split(':').last,
                    overflow: TextOverflow.ellipsis),
                trailing: _buildKeysListTrailingButton(context, i)))
            .toList(growable: false));
  }

  Widget _buildNewKeyDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Add new key'),
      content: new Form(
          key: _formKey,
          child: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Author',
                  ),
                  onSaved: (String value) {
                    this._keyEntryAuthor = value;
                  },
                ),
                new SizedBox(height: 16.0),
                new TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Key',
                  ),
                  onSaved: (String value) {
                    this._keyEntryKey = value;
                  },
                )
              ],
            ),
          )),
      actions: <Widget>[
        new FlatButton(
          child: new Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        new FlatButton(
            child: new Text('Add'),
            onPressed: () {
              _formKey.currentState.save();
              _keyring.add('${this._keyEntryAuthor}:${this._keyEntryKey}');
              widget.prefs.setStringList('keyring', _keyring);
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  void _showNewKeyDialog(BuildContext context) async {
    await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _buildNewKeyDialog(context));
  }
}
