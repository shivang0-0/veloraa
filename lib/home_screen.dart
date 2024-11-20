import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables to store user data
  String? userName;
  String? userProfileImage;
  bool isLoading = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch user data
  Future<void> _fetchUserData(User user) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? 'User';
          userProfileImage = userDoc['profileImage'] ??
              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'; // Default image if no profile image exists
          isLoading = false;
        });
      } else {
        // If user document doesn't exist
        setState(() {
          userName = 'User';
          userProfileImage =
              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'; // Default image
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is signed out, navigate to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // User is signed in, fetch user data
        _fetchUserData(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If still loading, show a loading indicator
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFE74C3C),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFFDEDEC), // Light reddish background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Section
              DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C), // Reddish-orange
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          userProfileImage!), // Profile image from CDN or user document
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName ?? 'User', // Display fetched username
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Sidebar Menu Items
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFFE74C3C)),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Color(0xFFE74C3C)),
                title: const Text('About'),
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
              ListTile(
                leading: const Icon(Icons.support, color: Color(0xFFE74C3C)),
                title: const Text('Support'),
                onTap: () {
                  Navigator.pushNamed(context, '/support');
                },
              ),
              const Spacer(),
              // Logout Button
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFE74C3C)),
                title: const Text('Logout'),
                onTap: () async {
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/images/home_screen/header/sandwich.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              semanticLabel: 'Menu Button',
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Image.asset(
          'assets/images/home_screen/header/be_mindful.png',
          width: 150,
          height: 45,
          fit: BoxFit.contain,
          semanticLabel: 'Be Mindful',
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/home_screen/header/bell.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
              semanticLabel: 'Notifications Button',
            ),
            onPressed: () {
              // Handle bell icon action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(7, (index) {
              double height;
              switch (index) {
                case 0:
                  height = 50.0;
                  break;
                case 1:
                  height = 175.0;
                  break;
                case 2:
                  height = 175.0;
                  break;
                case 3:
                  height = 50.0; // Same height as row 0
                  break;
                case 4:
                  height = 50.0;
                  break;
                case 5:
                  height = 30.0;
                  break;
                case 6:
                  height = 130.0;
                  break;
                default:
                  height = 60.0;
              }

              EdgeInsets rowMargin;
              if (index == 1 || index == 2) {
                rowMargin = const EdgeInsets.only(bottom: 12.0);
              } else {
                rowMargin = EdgeInsets.zero;
              }

              // Row 0 with healing image
              if (index == 0) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/home_screen/body/healing.png',
                        height: height,
                        width: 150,
                        fit: BoxFit.contain,
                        semanticLabel: 'Let\'s begin healing',
                      ),
                    ),
                  ),
                );
              }

              // Row 1 with two columns and overlay buttons
              if (index == 1) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/chat');
                            },
                            child: Image.asset(
                              'assets/images/home_screen/body/purple.png',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              semanticLabel:
                                  'Artifical Intelligence Chat Feature Button',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/journal');
                            },
                            child: Image.asset(
                              'assets/images/home_screen/body/cyan.png',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              semanticLabel: 'Journal Feature Button',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Row 2 with two columns and overlay buttons
              if (index == 2) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/doctor');
                            },
                            child: Image.asset(
                              'assets/images/home_screen/body/red.png',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              semanticLabel:
                                  'Doctor\'s Appointment Feature Button',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/selflearning');
                            },
                            child: Image.asset(
                              'assets/images/home_screen/body/grey.png',
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              semanticLabel: 'Self-Learning Feature Button',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Row 3 with feeling image
              if (index == 3) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/home_screen/body/feeling.png',
                        height: height,
                        width: 150,
                        fit: BoxFit.contain,
                        semanticLabel: 'How are you feeling?',
                      ),
                    ),
                  ),
                );
              }

              // Row 4 with emojis.png centered
              if (index == 4) {
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Response Recorded!')),
                    );
                  },
                  child: Container(
                    height: height,
                    margin: rowMargin,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/home_screen/body/emojis.png',
                          height: 40,
                          fit: BoxFit.contain,
                          semanticLabel: 'Emotions Feedback Buttons',
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Row 5 with daily.png left-aligned
              if (index == 5) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/home_screen/body/daily.png',
                        height: 20,
                        width: 100,
                        fit: BoxFit.contain,
                        semanticLabel: 'Daily Videos',
                      ),
                    ),
                  ),
                );
              }

              // Row 6 with video.png centered
              if (index == 6) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/video');
                    },
                    child: Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20), // Set your desired corner radius here
                        child: Image.asset(
                          'assets/images/home_screen/body/video.png',
                          fit: BoxFit.contain,
                          semanticLabel: 'Daily Videos Button',
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Container(); // Default case
            }),
          ),
        ),
      ),
    );
  }
}
