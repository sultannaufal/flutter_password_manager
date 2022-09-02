import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:localstore/localstore.dart';
import 'package:password_manager/models/password_model.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return PasswordList(constraints);
    });
  }
}

class PasswordList extends StatefulWidget {
  const PasswordList(BoxConstraints? constraints, {Key? key}) : super(key: key);

  @override
  State<PasswordList> createState() => _PasswordListState();
}

class _PasswordListState extends State<PasswordList> {
  final _db = Localstore.instance;
  final _items = <String, PasswordModel>{};
  StreamSubscription<Map<String, dynamic>>? _subscription;

  @override
  void initState() {
    _subscription = _db.collection('passwords').stream.listen((event) {
      setState(() {
        final item = PasswordModel.fromMap(event);
        _items.putIfAbsent(item.id, () => item);
      });
    });
    if (kIsWeb) _db.collection('passwords').stream.asBroadcastStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4263),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: const Text("Saved Password"),
      ),
      body: _items.isEmpty
          ? const Center(child: Text("No saved password"))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, left: 20.0),
                      child: Text("Label"),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, right: 20.0),
                      child: Text("Delete"),
                    )
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Divider(
                    color: Color(0xFFFF4C29),
                    indent: 20,
                    endIndent: 20,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: _items.keys.length,
                      itemBuilder: (context, index) {
                        final key = _items.keys.elementAt(index);
                        final item = _items[key];
                        final label = item!.label;
                        return SizedBox(
                          child: Card(
                            child: ListTile(
                              title: Text(label),
                              subtitle: Text(item.date),
                              visualDensity:
                                  const VisualDensity(horizontal: -3),
                              onTap: () {
                                final data = ClipboardData(text: item.password);
                                Clipboard.setData(data);

                                const snackbar =
                                    SnackBar(content: Text("Copied"));

                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(snackbar);
                              },
                              trailing: IconButton(
                                  onPressed: (() {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext builder) {
                                          return AlertDialog(
                                            title: const Text("Confirmation"),
                                            content: Text(
                                                "Are you sure want to delete $label"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    // Close the dialog
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No')),
                                              TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      item.delete();
                                                      _items.remove(item.id);
                                                    });
                                                    var snackbar = SnackBar(
                                                        content: Text(
                                                            "$label password deleted"));

                                                    ScaffoldMessenger.of(
                                                        context)
                                                      ..removeCurrentSnackBar()
                                                      ..showSnackBar(snackbar);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Yes"))
                                            ],
                                          );
                                        });
                                  }),
                                  icon: const Icon(Icons.delete)),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription?.cancel();
    super.dispose();
  }
}
