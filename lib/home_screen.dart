import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/home_screen/header/sandwich.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
            Image.asset(
              'assets/images/home_screen/header/be_mindful.png',
              width: 150,
              height: 45,
              fit: BoxFit.contain,
            ),
            Image.asset(
              'assets/images/home_screen/header/bell.png',
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
          ],
        ),
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
              // Only rows 1 and 2 have bottom margin
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
                  child: Row(
                    children: [
                      // Left column with purple.png and overlay button
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  // Optional: Add any desired decoration here
                                ),
                                child: Image.asset(
                                  'assets/images/home_screen/body/purple.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // Define your button action here
                                    print("Purple button pressed");
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Make button transparent to see the white container
                                  ),
                                  child: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right column with cyan.png and overlay button
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  // Optional: Add any desired decoration here
                                ),
                                child: Image.asset(
                                  'assets/images/home_screen/body/cyan.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // Define your button action here
                                    print("Cyan button pressed");
                                    Navigator.pushNamed(context, '/journal');
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Make button transparent to see the white container
                                  ),
                                  child: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Row 2 with two columns and overlay buttons
              if (index == 2) {
                return Container(
                  height: height,
                  margin: rowMargin,
                  child: Row(
                    children: [
                      // Left column with red.png and overlay button
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  // Optional: Add any desired decoration here
                                ),
                                child: Image.asset(
                                  'assets/images/home_screen/body/red.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // Define your button action here
                                    print("Red button pressed");
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Make button transparent to see the white container
                                  ),
                                  child: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right column with grey.png and overlay button
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  // Optional: Add any desired decoration here
                                ),
                                child: Image.asset(
                                  'assets/images/home_screen/body/grey.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                margin: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    // Define your button action here
                                    print("Grey button pressed");
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Make button transparent to see the white container
                                  ),
                                  child: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      ),
                    ),
                  ),
                );
              }

              // Row 4 with emojis.png left-aligned with left and right margins
              if (index == 4) {
                return Container(
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
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/home_screen/body/video.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }

              // Default case (optional)
              return Container();
            }),
          ),
        ),
      ),
    );
  }
}
