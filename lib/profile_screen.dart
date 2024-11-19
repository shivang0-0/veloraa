import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data variables
  String? userName;
  String? userEmail;
  String? userAge;
  String? userMobile;
  String? userCaretakerEmail;
  bool isLoading = true;

  // Method to fetch user data
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'];
            userEmail = userDoc['email'];
            userAge = userDoc['age'].toString();
            userMobile = userDoc['mobile'];
            userCaretakerEmail = userDoc['caretakerEmail'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User data not found in the database.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE74C3C), // Sidebar's reddish-orange
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE74C3C), // Sidebar's reddish-orange
              ),
            )
          : Container(
              color: const Color(0xFFFDEDEC), // Sidebar's light reddish background
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Generic profile image at the top
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: const NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/3135/3135715.png', // Profile image CDN
                        ),
                      ),
                    ),
                    // Animated list of profile details
                    Expanded(
                      child: AnimationLimiter(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              horizontalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: [
                              if (userName != null)
                                _buildProfileCard('Name', userName!),
                              if (userEmail != null)
                                _buildProfileCard('Email', userEmail!),
                              if (userAge != null)
                                _buildProfileCard('Age', userAge!),
                              if (userMobile != null)
                                _buildProfileCard('Mobile', userMobile!),
                              if (userCaretakerEmail != null)
                                _buildProfileCard('Caretaker Email', userCaretakerEmail!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget to build each profile card
  Widget _buildProfileCard(String fieldName, String fieldValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE74C3C), // Sidebar's reddish-orange
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fieldValue,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
