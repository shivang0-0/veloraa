import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class JournalScreen extends StatefulWidget {
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String text = '';
  bool isListening = false;
  late stt.SpeechToText speech;
  late TextEditingController textController;
  String lastRecognizedWords = '';

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
          if (status == 'done' && isListening) {
            startListening();
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (result) {
            String newWords = result.recognizedWords;
            String wordsToAdd = newWords.replaceFirst(lastRecognizedWords, '').trim();
            lastRecognizedWords = newWords;

            if (wordsToAdd.isNotEmpty) {
              setState(() {
                text += ' $wordsToAdd';
                textController.text = text.trim();
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
                );
              });
            }
          },
          listenMode: stt.ListenMode.dictation,
          pauseFor: Duration(seconds: 3),
          partialResults: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type something...',
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isListening ? stopListening : startListening,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isListening ? Icons.stop : Icons.mic),
                  SizedBox(width: 10),
                  Text(isListening ? 'Stop Listening' : 'Start Listening'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
