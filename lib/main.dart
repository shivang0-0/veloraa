import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'main_screen.dart';

void main() {
  runApp(VeloraApp());
}

class VeloraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Velora App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}
