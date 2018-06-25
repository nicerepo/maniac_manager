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
// mod_info.dart
//
//===------------------------------------------------------------------------------------------===//

// Adapted from flutter_gallery/lib/demo/material/expansion_panels_demo.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maniac_manager/common/package_util.dart';

typedef Widget ModInfoItemBodyBuilder<T>(ModInfoItem<T> item);

class DualHeaderWithHint extends StatelessWidget {
  const DualHeaderWithHint({this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return new Row(children: <Widget>[
      new Expanded(
        child: new Container(
          margin: const EdgeInsets.only(left: 24.0),
          child: new FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: new Text(
              name,
              style: textTheme.body1.copyWith(fontSize: 15.0),
            ),
          ),
        ),
      ),
    ]);
  }
}

class CollapsibleBody extends StatelessWidget {
  const CollapsibleBody(
      {this.editable = true,
      this.margin = EdgeInsets.zero,
      this.child,
      this.onSave,
      this.onCancel});

  final bool editable;
  final EdgeInsets margin;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return this.editable ? _editable(context) : _noneditable(context);
  }

  Widget _editable(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return new Column(children: <Widget>[
      new Container(
          margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0) -
              margin,
          child: new Center(
              child: new DefaultTextStyle(
                  style: textTheme.caption.copyWith(fontSize: 15.0),
                  child: child))),
      const Divider(height: 1.0),
      new Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: new FlatButton(
                        onPressed: onCancel,
                        child: const Text('CANCEL',
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500)))),
                new Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: new FlatButton(
                        onPressed: onSave,
                        textTheme: ButtonTextTheme.accent,
                        child: const Text('SAVE')))
              ]))
    ]);
  }

  Widget _noneditable(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;

    return new Column(children: <Widget>[
      new Container(
          margin: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0) -
              margin,
          child: new Center(
              child: new DefaultTextStyle(
                  style: textTheme.caption.copyWith(fontSize: 15.0),
                  child: child))),
      const Divider(height: 1.0),
      new Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: new FlatButton(
                        onPressed: onCancel,
                        child: const Text('CLOSE',
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500))))
              ]))
    ]);
  }
}

class ModInfoItem<T> {
  ModInfoItem({this.name, this.builder});

  final String name;
  final ModInfoItemBodyBuilder<T> builder;
  bool isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return new DualHeaderWithHint(name: name);
    };
  }

  Widget build() => builder(this);
}

class ModInfo extends StatefulWidget {
  const ModInfo({Key key, this.applicationId, this.metadata, this.readme})
      : super(key: key);

  final String applicationId;
  final String metadata;
  final String readme;

  static const String routeName = '/material/expansion_panels';

  @override
  _ModInfoState createState() => new _ModInfoState();
}

class _ModInfoState extends State<ModInfo> {
  List<ModInfoItem<dynamic>> _modInfoItems;

  Map metadata;
  bool draw;

  @override
  void initState() {
    super.initState();

    this.metadata = json.decode(widget.metadata);
    this.draw = true;

    _modInfoItems = <ModInfoItem<dynamic>>[
      new ModInfoItem<String>(
        name: 'Information',
        builder: (ModInfoItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }

          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                return new CollapsibleBody(
                  editable: false,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  onSave: () {
                    Form.of(context).save();
                    close();
                  },
                  onCancel: () {
                    Form.of(context).reset();
                    close();
                  },
                  child: new Column(children: <Widget>[
                    new MarkdownBody(data: widget.readme),
                  ]),
                );
              },
            ),
          );
        },
      ),
      // new ModInfoItem<String>(
      //   name: 'Settings',
      //   builder: (ModInfoItem<String> item) {
      //     void close() {
      //       setState(() {
      //         item.isExpanded = false;
      //       });
      //     }

      //     return new Form(
      //       child: new Builder(
      //         builder: (BuildContext context) {
      //           return new CollapsibleBody(
      //             editable: false,
      //             margin: const EdgeInsets.symmetric(horizontal: 8.0),
      //             onSave: () {
      //               Form.of(context).save();
      //               close();
      //             },
      //             onCancel: () {
      //               Form.of(context).reset();
      //               close();
      //             },
      //             child: new Column(children: <Widget>[
      //               new Row(children: <Widget>[
      //                 new Text('Enabled'),
      //                 new Switch(value: false, onChanged: (bool value) {})
      //               ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
      //             ]),
      //           );
      //         },
      //       ),
      //     );
      //   },
      // ),
      ModInfoItem<String>(
        name: 'Removal',
        builder: (ModInfoItem<String> item) {
          void close() {
            setState(() {
              item.isExpanded = false;
            });
          }

          void uninstall() async {
            await PackageUtil.uninstallPackage(
                widget.applicationId, this.metadata['id']);

            showDialog<String>(
                context: context,
                builder: (BuildContext context) => new AlertDialog(
                      content: new Text('Uninstallation complete'),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('Close'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ));

            // Ayla Mao
            setState(() {
              this.draw = false;
            });
          }

          var paddedOutlineButton = (var text, var onPressed) {
            return new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: new OutlineButton(
                    highlightElevation: 0.0,
                    child: text,
                    onPressed: onPressed));
          };

          return new Form(
            child: new Builder(
              builder: (BuildContext context) {
                return new CollapsibleBody(
                  editable: false,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  onSave: () {
                    Form.of(context).save();
                    close();
                  },
                  onCancel: () {
                    Form.of(context).reset();
                    close();
                  },
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        paddedOutlineButton(
                          const Text('Uninstall Package'),
                          () => uninstall(),
                        )
                      ]),
                );
              },
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return !this.draw
        ? new Padding(padding: EdgeInsets.all(0.0))
        : new SingleChildScrollView(
            child: new SafeArea(
              top: false,
              bottom: false,
              child: new Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: new Column(children: <Widget>[
                  new Text(
                    '${metadata['id']} (${metadata['author']})',
                    style: new TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  new ExpansionPanelList(
                      expansionCallback: (int index, bool isExpanded) {
                        setState(() {
                          _modInfoItems[index].isExpanded = !isExpanded;
                        });
                      },
                      children: _modInfoItems.map((ModInfoItem<dynamic> item) {
                        return new ExpansionPanel(
                            isExpanded: item.isExpanded,
                            headerBuilder: item.headerBuilder,
                            body: item.build());
                      }).toList()),
                ]),
              ),
            ),
          );
  }
}
