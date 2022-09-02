import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:localstore/localstore.dart';
import 'package:password_manager/generate_password.dart';
import 'package:password_manager/list_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GeneratePassword();
  }
}

class GeneratePassword extends StatefulWidget {
  const GeneratePassword({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GeneratePasswordState createState() => _GeneratePasswordState();
}

class _GeneratePasswordState extends State<GeneratePassword> {
  final db = Localstore.instance;
  final _controller = TextEditingController();
  bool isNumber = true;
  bool isUpper = true;
  bool isSpecial = true;
  late bool _isDisabled;
  var length = 16;
  String label = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _isDisabled = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF2D4263),
          title: const Text('Password Manager'),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ListScreen()));
                },
                icon: const Icon(Icons.list))
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: const [
                    Flexible(
                      child: Text(
                        "Generate Strong Random Password",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  controller: _controller,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFECDBBA),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide:
                            const BorderSide(color: Colors.white, width: 5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: const BorderSide(
                            color: Color.fromARGB(156, 255, 255, 255),
                            width: 0),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            final data = ClipboardData(text: _controller.text);
                            Clipboard.setData(data);

                            const snackbar = SnackBar(content: Text("Copied"));

                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(snackbar);
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                          ))),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                LayoutBuilder(builder: ((context, constraints) {
                  if (constraints.maxWidth >= 730) {
                    return Row(
                      children: _optionListExpanded(),
                    );
                  } else {
                    return SizedBox(
                      child: Column(
                        children: _optionList(),
                      ),
                    );
                  }
                })),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Flex(
                    direction: MediaQuery.of(context).size.width >= 270
                        ? Axis.horizontal
                        : Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildGenerateButtonWidget(),
                      const SizedBox(
                        width: 8.0,
                      ),
                      _buildSaveButtonWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildGenerateButtonWidget() {
    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(), primary: const Color(0xFFFF4C29)),
          onPressed: () {
            setState(() {
              _isDisabled = false;
            });
            final password = generatePassword(
                isNumber: isNumber,
                isSpecial: isSpecial,
                isUpper: isUpper,
                length: length);
            _controller.text = password;
          },
          child: const Text(
            "Generate",
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  Widget _buildSaveButtonWidget() {
    final formKey = GlobalKey<FormState>();
    String? label = "";

    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: const Color(0xFF334756), shape: const StadiumBorder()),
          onPressed: _isDisabled
              ? null
              : () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Add Label'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Form(
                                  key: formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0, bottom: 8.0),
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFECDBBA)),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFFF4C29)),
                                            ),
                                          ),
                                          onSaved: (value) => label = value,
                                          autofocus: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Cannot be blank";
                                            }
                                            return null;
                                          },
                                          onFieldSubmitted: (value) {
                                            if (formKey.currentState!
                                                .validate()) {
                                              formKey.currentState!.save();
                                              final id = db
                                                  .collection('passwords')
                                                  .doc()
                                                  .id;
                                              db
                                                  .collection("passwords")
                                                  .doc(id)
                                                  .set({
                                                "id": id,
                                                "label": value,
                                                "password": _controller.text,
                                                "date": DateFormat(
                                                        "MM-dd-yyyy HH:mm")
                                                    .format(DateTime.now())
                                              });

                                              Navigator.pop(context);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text("Password Saved"),
                                              ));
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              shape: const StadiumBorder(),
                                              primary: const Color(0xFFFF4C29)),
                                          child: const Text("Save"),
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              formKey.currentState!.save();
                                              final id = db
                                                  .collection('passwords')
                                                  .doc()
                                                  .id;
                                              db
                                                  .collection("passwords")
                                                  .doc(id)
                                                  .set({
                                                "id": id,
                                                "label": label,
                                                "password": _controller.text,
                                                "date": DateFormat(
                                                        "MM-dd-yyyy HH:mm")
                                                    .format(DateTime.now())
                                              });

                                              Navigator.pop(context);

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text("Password Saved"),
                                              ));
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                },
          child: const Text(
            "Save",
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  List<Widget> _optionListExpanded() {
    return [
      Expanded(
        child: ListTile(
          leading: Checkbox(
            activeColor: const Color(0xFFFF4C29),
            value: isSpecial,
            onChanged: (bool? value) {
              setState(() {
                isSpecial = value!;
              });
            },
          ),
          title: const Text("Use Special Character"),
        ),
      ),
      Expanded(
        child: ListTile(
          leading: Checkbox(
            activeColor: const Color(0xFFFF4C29),
            value: isNumber,
            onChanged: (bool? value) {
              setState(() {
                isNumber = value!;
              });
            },
          ),
          title: const Text("Use Numbers [0-9]"),
        ),
      ),
      Expanded(
        child: ListTile(
          leading: Checkbox(
            activeColor: const Color(0xFFFF4C29),
            value: isUpper,
            onChanged: (bool? value) {
              setState(() {
                isUpper = value!;
              });
            },
          ),
          title: const Text("Use Upper Case"),
        ),
      ),
      Row(
        children: [
          const Text("Length"),
          const SizedBox(
            width: 16,
          ),
          DropdownButton<int>(
            items: const <DropdownMenuItem<int>>[
              DropdownMenuItem<int>(
                value: 6,
                child: Text('6'),
              ),
              DropdownMenuItem<int>(
                value: 8,
                child: Text('8'),
              ),
              DropdownMenuItem<int>(
                value: 12,
                child: Text('12'),
              ),
              DropdownMenuItem<int>(
                value: 16,
                child: Text('16'),
              ),
              DropdownMenuItem<int>(
                value: 20,
                child: Text('20'),
              ),
            ],
            value: length,
            hint: const Text('Length'),
            underline: Container(
              height: 2,
              color: const Color(0xFFFF4C29),
            ),
            onChanged: (int? value) {
              setState(() {
                length = value!;
              });
            },
          ),
        ],
      )
    ];
  }

  List<Widget> _optionList() {
    return [
      ListTile(
        leading: Checkbox(
          activeColor: const Color(0xFFFF4C29),
          value: isSpecial,
          onChanged: (bool? value) {
            setState(() {
              isSpecial = value!;
            });
          },
        ),
        title: const Text("Use Special Character"),
      ),
      ListTile(
        leading: Checkbox(
          activeColor: const Color(0xFFFF4C29),
          value: isNumber,
          onChanged: (bool? value) {
            setState(() {
              isNumber = value!;
            });
          },
        ),
        title: const Text("Use Numbers [0-9]"),
      ),
      ListTile(
        leading: Checkbox(
          activeColor: const Color(0xFFFF4C29),
          value: isUpper,
          onChanged: (bool? value) {
            setState(() {
              isUpper = value!;
            });
          },
        ),
        title: const Text("Use Upper Case"),
      ),
      ListTile(
        title: Row(
          children: [
            const Text("Length"),
            const SizedBox(
              width: 8.0,
            ),
            DropdownButton<int>(
              items: const <DropdownMenuItem<int>>[
                DropdownMenuItem<int>(
                  value: 6,
                  child: Text('6'),
                ),
                DropdownMenuItem<int>(
                  value: 8,
                  child: Text('8'),
                ),
                DropdownMenuItem<int>(
                  value: 12,
                  child: Text('12'),
                ),
                DropdownMenuItem<int>(
                  value: 16,
                  child: Text('16'),
                ),
                DropdownMenuItem<int>(
                  value: 20,
                  child: Text('20'),
                ),
              ],
              value: length,
              hint: const Text('Length'),
              onChanged: (int? value) {
                setState(() {
                  length = value!;
                });
              },
            ),
          ],
        ),
      )
    ];
  }
}
