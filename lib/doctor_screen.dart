import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for attractive fonts

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
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
              // Rounded image with doctor appointment theme
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded corners
                child: Image.asset(
                  'assets/images/doctor.png', // Use a relevant local asset image
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
                "Schedule Your Doctor Visit with Ease!",
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
                "Get quick access to trusted healthcare professionals at your convenience.",
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
