import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String text = ''; // Store recognized text
  bool isListening = false; // Track listening state
  late stt.SpeechToText speech; // Initialize SpeechToText
  late TextEditingController textController; // Persistent TextEditingController
  String lastRecognizedWords = ''; // Track last recognized words to avoid duplication

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    textController = TextEditingController(); // Initialize the controller once
  }

  @override
  void dispose() {
    textController.dispose(); // Dispose of the controller when done
    super.dispose();
  }

  // Method to request microphone permission
  Future<void> requestPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print("Microphone permission not granted");
    }
  }

  Future<void> startListening() async {
    // Request microphone permission if not granted
    if (await Permission.microphone.isGranted) {
      bool available = await speech.initialize(
        onStatus: (status) {
          print('Status: $status');
          if (status == 'done' && isListening) {
            // If listening is active but status is "done," restart listening
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

            // Only append the truly new words by removing the already recognized part
            String wordsToAdd = newWords.replaceFirst(lastRecognizedWords, '').trim();
            lastRecognizedWords = newWords; // Update last recognized words
            
            if (wordsToAdd.isNotEmpty) {
              setState(() {
                text += ' $wordsToAdd';
                textController.text = text.trim(); // Update the controller text
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length), // Keep cursor at the end
                );
              });
            }

            print("Recognized words: $wordsToAdd"); // Log only the new words added
          },
          listenMode: stt.ListenMode.dictation, // Use dictation mode for continuous listening
          pauseFor: Duration(seconds: 3), // Adjust pause duration as needed
          partialResults: true, // Display partial results
          localeId: "en_US", // Ensure correct language is set
        );
      } else {
        print("Speech recognition is not available.");
      }
    } else {
      await requestPermission(); // Request permission if not granted
    }
  }

  void stopListening() {
    setState(() => isListening = false);
    speech.stop(); // Stop listening
    print("Final input in the text field: ${textController.text}"); // Log the final text
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Velora App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: textController, // Use persistent controller
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type something...',
              ),
              maxLines: 8,
              onChanged: (value) {
                setState(() {
                  text = value; // Sync text variable with text field
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isListening ? stopListening : startListening,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isListening ? Icons.stop : Icons.mic),
                  SizedBox(width: 10),
                  Text(isListening ? 'Stop Listening' : 'Press to Speak'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
