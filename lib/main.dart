import 'package:flutter/material.dart';
import 'package:password_manager/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(brightness: Brightness.dark),
      home: const GeneratePassword(),
    );
  }
}
