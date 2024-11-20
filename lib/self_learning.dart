import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this package for attractive fonts

class SelfLearningScreen extends StatefulWidget {
  const SelfLearningScreen({super.key});

  @override
  State<SelfLearningScreen> createState() => _SelfLearningScreenState();
}

class _SelfLearningScreenState extends State<SelfLearningScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFDEDEC), // Light reddish background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // "Feature Coming Soon" text
              Text(
                "Feature Coming Soon...",
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: const Color(0xFFE74C3C), // Sidebar's reddish-orange
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              // Rounded image with self-learning theme
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: Image.asset(
                  'assets/images/self-care.jpg', // Use Image.asset for local assets
                  width: 300, // Landscape dimensions
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // Beautified text
              Text(
                "Embark on Your Self-Learning Journey!",
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  color: const Color(0xFFE74C3C), // Sidebar's reddish-orange
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Discover, Explore, and Grow with the power of self-paced education.",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
