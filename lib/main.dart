import 'package:flutter/material.dart';
import 'auth_screen.dart';

void main() {
  runApp(const AlertMateApp());
}

class AlertMateApp extends StatelessWidget {
  const AlertMateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlertMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Inter',
      ),
      home: const AuthScreen(),
    );
  }
}