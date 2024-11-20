import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:velora/email_services.dart';

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
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, double> dataMap = {};
  bool isLoading = false;
  bool isAnalyzing = false;
  bool isPredictingMentalDisease = false;

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    textController = TextEditingController();
    loadEntryForDate(selectedDate);
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
            stopListening();
          }
        },
        onError: (error) => print('Error: $error'),
      );

      if (available) {
        setState(() {
          isListening = true;
          lastRecognizedWords = ''; // Clear previous recognized words
        });
        speech.listen(
          onResult: (result) {
            String newWords = result.recognizedWords;
            String wordsToAdd =
                newWords.replaceFirst(lastRecognizedWords, '').trim();
            lastRecognizedWords = newWords;

            if (wordsToAdd.isNotEmpty) {
              setState(() {
                textController.text +=
                    ' $wordsToAdd'; // Directly update the controller
                textController.text = textController.text.trim();
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
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

  Future<void> loadEntryForDate(DateTime date) async {
    setState(() {
      isLoading = true;
      textController.clear();
      text = '';
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journalEntries')
            .doc(DateFormat('yyyy-MM-dd').format(date))
            .get();

        if (doc.exists) {
          setState(() {
            textController.text = doc['entry'];
            text = doc['entry'];
          });
        } else {
          setState(() {
            textController.text = 'No record found.';
            text = '';
          });
        }
      }
    } catch (e) {
      print('Error loading journal entry: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Map<String, double> getTop5Data(Map<String, double> dataMap) {
    // Sort the map entries by value in descending order
    final sortedEntries = dataMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take the top 5 entries
    final top5Entries = sortedEntries.take(5);

    // Convert back to a map
    return Map<String, double>.fromEntries(top5Entries);
  }

  Future<void> analyzeText(String inputText) async {
    setState(() {
      isAnalyzing = true;
    });

    const url =
        'https://api-inference.huggingface.co/models/SamLowe/roberta-base-go_emotions';
    final headers = {
      'Authorization':
          'Bearer ${dotenv.env['HUGGING_API_KEY']}', // Replace with your token
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'inputs': inputText});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      final responseData = json.decode(response.body);
      final List<dynamic> emotions = responseData[0]; // Access the first list

      // Now parse the emotions data
      for (var emotion in emotions) {
        if (emotion['score'] != null && emotion['score'] > 0.05) {
          final label = emotion['label'];
          final score = emotion['score'];
          if (label is String && score is double) {
            dataMap[label] = score * 100; // Convert to percentage
          }
          print("heyyy");
          print(dataMap);
        }
      }
      dataMap = getTop5Data(dataMap);
    } catch (e) {
      print('Error analyzing text: $e');
    } finally {
      setState(() {
        isAnalyzing = false;
      });
    }
  }

  Widget buildDayCard(int day) {
    DateTime dayDate = DateTime(
      currentMonth.year,
      currentMonth.month,
      day,
    );

    bool isToday = dayDate.day == DateTime.now().day &&
        dayDate.month == DateTime.now().month &&
        dayDate.year == DateTime.now().year;

    return GestureDetector(
      onTap: () async {
        setState(() {
          selectedDate = dayDate;
        });
        await loadEntryForDate(dayDate);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFE74C3C) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE74C3C),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: isToday ? Colors.white : const Color(0xFFE74C3C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Widget> buildDayCards() {
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    List<Widget> dayCards = [];

    for (int day = 1; day <= daysInMonth; day++) {
      dayCards.add(buildDayCard(day));
    }

    return dayCards;
  }

  void navigateMonth(int direction) {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + direction,
      );
    });
  }

  final GlobalKey repaintBoundaryKey = GlobalKey();

  String predictMentalDisease() {
    double disappointment = dataMap['disappointment'] ?? 0;
    double sadness = dataMap['sadness'] ?? 0;
    double neutral = dataMap['neutral'] ?? 0;
    double annoyance = dataMap['annoyance'] ?? 0;
    double realization = dataMap['realization'] ?? 0;
    double nervousness = dataMap['nervousness'] ?? 0;
    double disapproval = dataMap['disapproval'] ?? 0;
    double joy = dataMap['joy'] ?? 0;
    double approval = dataMap['approval'] ?? 0;
    double embarrassment = dataMap['embarrassment'] ?? 0;
    double remorse = dataMap['remorse'] ?? 0;
    double relief = dataMap['relief'] ?? 0;
    double grief = dataMap['grief'] ?? 0;
    double optimism = dataMap['optimism'] ?? 0;
    double disgust = dataMap['disgust'] ?? 0;
    double excitement = dataMap['excitement'] ?? 0;
    double caring = dataMap['caring'] ?? 0;
    double anger = dataMap['anger'] ?? 0;
    double fear = dataMap['fear'] ?? 0;
    double admiration = dataMap['admiration'] ?? 0;
    double amusement = dataMap['amusement'] ?? 0;
    double confusion = dataMap['confusion'] ?? 0;
    double love = dataMap['love'] ?? 0;
    double desire = dataMap['desire'] ?? 0;
    double surprise = dataMap['surprise'] ?? 0;
    double curiosity = dataMap['curiosity'] ?? 0;
    double pride = dataMap['pride'] ?? 0;
    double gratitude = dataMap['gratitude'] ?? 0;

    // Expanded logic to include more emotions and their possible mental conditions
    if (sadness > 30 || disappointment > 30) {
      return "Depression";
    } else if (fear > 30 || nervousness > 30) {
      return "Anxiety Disorder";
    } else if (anger > 30 || annoyance > 30 || disapproval > 30) {
      return "Anger Management Issues";
    } else if (embarrassment > 30) {
      return "Social Anxiety Disorder";
    } else if (grief > 30) {
      return "Prolonged Grief Disorder";
    } else if (disgust > 30) {
      return "Obsessive-Compulsive Disorder (OCD)";
    } else if (confusion > 30) {
      return "Cognitive Impairment";
    } else if (realization > 30) {
      return "Self-Awareness";
    } else if (joy > 30 || excitement > 30) {
      return "Healthy Emotional State";
    } else if (optimism > 30 || pride > 30 || love > 30) {
      return "Positive Emotional Resilience";
    } else if (remorse > 30) {
      return "Guilt or Shame Issues";
    } else if (relief > 30 || gratitude > 30) {
      return "Stress Recovery or Relief";
    } else if (surprise > 30) {
      return "Heightened Sensory Awareness";
    } else if (curiosity > 30 || amusement > 30) {
      return "Creative and Exploratory Thinking";
    } else if (neutral > 30) {
      return "Emotionally Stable";
    } else if (admiration > 30 || caring > 30) {
      return "Compassionate Personality";
    } else if (desire > 30) {
      return "Goal-Oriented or Motivated State";
    } else {
      return "Uncertain, more data required";
    }
  }

  Future<Uint8List?> capturePieChart() async {
    try {
      RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing pie chart: $e");
      return null;
    }
  }

  pw.Page buildPdfPage({
    required String predictedDisease,
    required Map<String, double> dataMap,
    required Uint8List? chartBytes,
    required pw.Font ttf,
    required Uint8List companyLogoBytes, // Pass your company logo as bytes
  }) {
    final currentDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    return pw.Page(
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      // crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Image(
                          pw.MemoryImage(companyLogoBytes),
                          width: 60,
                          height: 60,
                        ),
                        pw.Text(
                          "Velora",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Daily Report',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        ),
                        pw.Text(
                          'Generated on: $currentDateTime',
                          style: pw.TextStyle(font: ttf),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Predicted Mental Condition: ',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf,
                    ),
                  ),
                  pw.Text(
                    predictedDisease,
                    style: pw.TextStyle(
                      fontSize: 16,
                      font: ttf,
                      color: PdfColors.blue,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Pie Chart on Left
                  if (chartBytes != null)
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Image(
                          pw.MemoryImage(chartBytes),
                          height: 200,
                        ),
                      ),
                    ),
                  // Emotional Data Breakdown on Right
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Emotional Data Breakdown:',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            font: ttf,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        ...dataMap.entries.map((entry) {
                          return pw.Text(
                            '${entry.key}: ${entry.value.toStringAsFixed(2)}%',
                            style: pw.TextStyle(font: ttf),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Column(children: [
                pw.Text(
                  'Mental Wellness Strategies',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange,
                    font: ttf,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    "Mental wellness is essential for overall health and well-being. Practicing mindfulness through meditation and breathing exercises can help reduce stress and promote emotional balance. Maintaining a regular sleep schedule and engaging in physical activities, such as walking or yoga, are proven to improve mental clarity and reduce anxiety. Building a support network by connecting with family, friends, or support groups fosters a sense of belonging and emotional resilience. Journaling your thoughts and feelings can provide clarity and help process emotions effectively. Limiting screen time and avoiding overexposure to negative news can minimize feelings of overwhelm. Incorporating a balanced diet rich in nutrients supports brain health, while hobbies and creative pursuits nurture positivity and self-expression. Finally, seeking professional help when overwhelmed ensures timely support for managing mental health challenges. These strategies empower individuals to achieve a healthier and more fulfilling life.",
                    style: pw.TextStyle(
                      fontSize: 14,
                      font: ttf,
                    ),
                    textAlign: pw.TextAlign.justify,
                  ),
                )
              ])
            ],
          ),
        );
      },
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final predictedDisease = predictMentalDisease();
    final chartBytes = await capturePieChart();
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final companyLogoBytes = await rootBundle
        .load('assets/images/velora_logo.png')
        .then((data) => data.buffer.asUint8List());

    final page = await buildPdfPage(
      predictedDisease: predictedDisease,
      dataMap: dataMap,
      chartBytes: chartBytes,
      ttf: ttf,
      companyLogoBytes: companyLogoBytes, // Load your logo bytes here
    );

    pdf.addPage(page);

    final output = await getTemporaryDirectory();
    final filePath = '${output.path}/mental_health_report.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      print('Error opening file: $e');
    }

    // Send email with the PDF attachment
    await sendEmail(filePath);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generated and emailed successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat('MMMM yyyy').format(currentMonth);
    String predictedDisease = predictMentalDisease();

    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE74C3C),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFFE74C3C)),
                          onPressed: currentMonth.isBefore(DateTime.now())
                              ? () => navigateMonth(-1)
                              : null,
                        ),
                        Text(
                          monthYear,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE74C3C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward,
                              color: Color(0xFFE74C3C)),
                          onPressed: currentMonth.month == DateTime.now().month
                              ? null
                              : () => navigateMonth(1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: buildDayCards(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: textController,
                      readOnly: !(selectedDate.day == DateTime.now().day &&
                          selectedDate.month == DateTime.now().month &&
                          selectedDate.year == DateTime.now().year),
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: selectedDate == DateTime.now()
                              ? 'Write your journal entry here...'
                              : textController.text.isEmpty
                                  ? 'No record found.'
                                  : ' '),
                      maxLines: 6,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              isListening ? stopListening : startListening,
                          icon: Icon(isListening ? Icons.stop : Icons.mic,
                              color: Colors.white),
                          label: Text(
                            isListening ? 'Stop Listening' : 'Start Listening',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isListening
                                ? Colors.red
                                : const Color(0xFFE74C3C),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (textController.text.trim().isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_auth.currentUser?.uid)
                                  .collection('journalEntries')
                                  .doc(DateFormat('yyyy-MM-dd')
                                      .format(selectedDate))
                                  .set({
                                'entry': textController.text,
                                'timestamp': Timestamp.now(),
                              });

                              await analyzeText(textController.text);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Journal entry saved and analyzed successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE74C3C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (isAnalyzing) const CircularProgressIndicator(),
                    if (dataMap.isNotEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RepaintBoundary(
                              key: repaintBoundaryKey,
                              child: PieChart(
                                dataMap: dataMap,
                                animationDuration:
                                    const Duration(milliseconds: 800),
                                chartRadius:
                                    MediaQuery.of(context).size.width / 2.2,
                                chartType: ChartType
                                    .ring, // You can use ChartType.disc for a different look
                                ringStrokeWidth: 32,
                                legendOptions: const LegendOptions(
                                  showLegends: true,
                                  legendPosition: LegendPosition.bottom,
                                ),
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValueBackground: true,
                                  showChartValues: true,
                                  showChartValuesInPercentage: true,
                                  showChartValuesOutside: false,
                                ),
                                colorList: const [
                                  Colors.blue,
                                  Colors.red,
                                  Colors.green,
                                  Colors.yellow,
                                  Colors.purple
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  isPredictingMentalDisease = true;
                                });
                              },
                              icon: const Icon(Icons.batch_prediction,
                                  color: Colors.white),
                              label: const Text(
                                'Give Predictions',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    if (isPredictingMentalDisease)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Predicted Mental Condition
                          Text(
                            'Predicted Mental Condition:',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFE74C3C),
                                ),
                          ),
                          Text(
                            predictedDisease,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE74C3C),
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Emotional Data Breakdown
                          Text(
                            'Based on the following emotional data:',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                          ),
                          const SizedBox(height: 20),
                          // ListView for DataMap (constrained with SizedBox)
                          SizedBox(
                            height: 400, // Constrain the height
                            child: ListView(
                              children: dataMap.entries.map((entry) {
                                return Card(
                                  elevation: 4,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    leading: const Icon(
                                        Icons.sentiment_satisfied_alt,
                                        color: Color(0xFFE74C3C)),
                                    title: Text(
                                      '${entry.key}: ${entry.value.toStringAsFixed(2)}%',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Button for Generate PDF
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await generatePdf(
                                    context); // Ensure it's called asynchronously
                              },
                              icon: const Icon(Icons.picture_as_pdf,
                                  color: Colors.white),
                              label: const Text(
                                'Generate Pdf',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
    );
  }
}
