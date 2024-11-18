import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'chat_screen.dart';

void main() {
  runApp(VeloraApp());
}

class VeloraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velora App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/journal': (context) => JournalScreen(),
        '/chat': (context) => Chatbot(),
      },
    );
  }
}
