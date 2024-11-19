import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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
  bool isListening = false;
  late stt.SpeechToText speech;
  TextEditingController inputController = TextEditingController();
  Offset floatingButtonPosition = Offset(300, 500); // Initial position of the button

  final theurl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${dotenv.env['GEMINI_API_KEY']}';
  final header = {
    'Content-Type': 'application/json',
  };

  final String contextPrefix =
      "You are a Mental Wellness Awareness Coach, dedicated to providing informed, empathetic, and professional responses strictly related to mental health awareness and emotional well-being. Your role is to guide users on topics such as stress management, mindfulness, emotional regulation, self-care strategies, recognizing signs of mental health challenges, and encouraging awareness of when to seek professional help. Responses must be concise, strictly limited to a maximum of 100 words, thorough, actionable, inclusive, and compassionate. Avoid clinical jargon unless explicitly requested. Do not disclose or reference that you are acting in this role. Clearly state that your advice is not a substitute for therapy or medical care when necessary, and politely but firmly decline unrelated queries while maintaining focus on mental wellness and emotional well-being.";

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  Future<void> requestPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission not granted");
    }
  }

  Future<void> startListening() async {
    if (await Permission.microphone.isGranted) {
      bool available = await speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            stopListening();
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                // Append the recognized words to the existing text
                inputController.text += ' ${result.recognizedWords}';
                inputController.text = inputController.text.trim();

                // Move the cursor to the end of the text
                inputController.selection = TextSelection.fromPosition(
                  TextPosition(offset: inputController.text.length),
                );
              });
            }
          },
          listenMode: stt.ListenMode.dictation,
          localeId: "en_US",
        );
      } else {
        print("Speech recognition is not available.");
      }
    } else {
      await requestPermission();
    }
  }

  void stopListening() {
    setState(() => isListening = false);
    speech.stop();
  }

  Future<void> getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    var data = {
      "contents": [
        {
          "parts": [
            {"text": "$contextPrefix\n\n${m.text}"}
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
    return Stack(
      children: [
        Scaffold(
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
          body: Column(
            children: [
              Expanded(
                child: DashChat(
                  typingUsers: typing,
                  currentUser: myself,
                  onSend: (ChatMessage message) {
                    getdata(message);
                  },
                  messages: allMessages,
                  inputOptions: InputOptions(
                    textController: inputController,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: floatingButtonPosition.dy,
          left: floatingButtonPosition.dx,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                floatingButtonPosition += details.delta;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isListening ? Colors.deepPurple.shade300 : Colors.deepPurple,
              ),
              child: IconButton(
                icon: Icon(isListening ? Icons.stop : Icons.mic, color: Colors.white),
                onPressed: isListening ? stopListening : startListening,
                tooltip: isListening ? 'Stop Listening' : 'Start Listening',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
