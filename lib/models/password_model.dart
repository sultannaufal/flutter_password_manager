import 'package:localstore/localstore.dart';

class PasswordModel {
  final String id;
  String label;
  String password;
  String date;

  PasswordModel(
      {required this.id,
      required this.label,
      required this.password,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'password': password,
      'date': date,
    };
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'],
      label: map['label'],
      password: map['password'],
      date: map['date'],
    );
  }
}

extension ExtPasswordModel on PasswordModel {
  Future save() async {
    final db = Localstore.instance;
    return db.collection('passwords').doc(id).set(toMap());
  }

  Future delete() async {
    final db = Localstore.instance;
    return db.collection('passwords').doc(id).delete();
  }
}
