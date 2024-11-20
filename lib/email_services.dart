import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmail(String filePath) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print("User is not logged in.");
    return;
  }

  String userEmail = user.email ?? '';
  String caretakerEmail = '';

  try {
    // Fetch caretaker email from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      caretakerEmail = userDoc['caretakerEmail'] ?? '';
    }

    if (userEmail.isEmpty || caretakerEmail.isEmpty) {
      print("Email addresses are missing.");
      return;
    }

    // SendGrid SMTP server settings
    String username = 'apikey'; // 'apikey' is the username for SendGrid
    String password = '${dotenv.env['EMAIL_API_KEY']}'; // Replace with your SendGrid API Key

    final smtpServer = SmtpServer('smtp.sendgrid.net',
        username: username,
        password: password,
        port: 587,
        ssl: false,
        ignoreBadCertificate: true);

    final message = Message()
      ..from = const Address('shivang.sharma2062@gmail.com', 'Velora')
      ..recipients.addAll([userEmail, caretakerEmail])
      ..subject = 'Mental Health Report'
      ..text = 'Please find the attached mental health report.'
      ..attachments = [
        FileAttachment(File(filePath))
      ];

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: $sendReport');
    } on MailerException catch (e) {
      print('Email not sent: $e');
    }

  } catch (error) {
    print("Error sending email: $error");
  }
}
