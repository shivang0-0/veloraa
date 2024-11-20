import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:velora/doctor_screen.dart';
import 'package:velora/self_learning.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'journal_screen.dart';
import 'chat_screen.dart';
import 'signup_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'video_screen.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
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
      // initialRoute: '/',
      routes: {
        // '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/journal': (context) => JournalScreen(),
        '/chat': (context) => Chatbot(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/profile': (context) => ProfileScreen(),
        '/video': (context) => VideoScreen(),
        '/doctor': (context) => DoctorScreen(),
        '/selflearning': (context) => SelfLearningScreen()
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return SplashScreen();
            } else {
              return const HomeScreen();
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return const Text("No Error");
          }
        },
      ),
    );
  }
}
