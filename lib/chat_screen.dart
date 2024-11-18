import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  ChatUser myself = ChatUser(id: '1', firstName: 'Shivang');
  ChatUser bot = ChatUser(id: '2', firstName: 'Velora');

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  final theurl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=';
  final header = {
    'Content-Type': 'application/json',
  };

  // Function to get data from the Gemini API
  Future<void> getdata(ChatMessage m) async {
    // Add the user's message to the list
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(theurl),
        headers: header,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        // Parse the response and create a new message
        ChatMessage botMessage = ChatMessage(
          text: result['candidates'][0]['content']['parts'][0]['text'],
          user: bot,
          createdAt: DateTime.now(),
        );

        allMessages.insert(0, botMessage);
      } else {
        print("Error: Response status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }

    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/home_screen/header/be_mindful.png',
          height: 45,
          fit: BoxFit.contain,
        ),
      ),
      body: DashChat(
        typingUsers: typing,
        currentUser: myself,
        onSend: (ChatMessage message) {
          getdata(message);
        },
        messages: allMessages,
      ),
    );
  }
}
