import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myproject/login.dart';
import 'package:myproject/home.dart'; // Import your home page widget

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Block the keyboard from appearing when the screen is tapped
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: const Scaffold(
        backgroundColor: Color(0xFF6BB3FF), // Change background color to contrast with animation
        body: SplashBody(),
      ),
    );
  }
}

class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  String _greetingText = ''; // Store the personalized greeting

  @override
  void initState() {
    super.initState();
    _initialize(); // Call the method to initialize the splash screen
  }

  Future<void> _initialize() async {
    await _getUserInfo(); // Await the user info retrieval

    // Check if the user is already logged in
    if (FirebaseAuth.instance.currentUser != null) {
      // User is already logged in, navigate to home page directly
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(_createHomeRoute());
      });
      // Custom transition to home page
    } else {
      // User is not logged in, continue with splash screen and navigate to login page after delay
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
            _createLoginRoute()); // Custom transition to login page
      });
    }
  }

  Future<void> _getUserInfo() async {
    // Retrieve the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, retrieve the display name
      String? displayName = user.displayName;

      if (displayName != null) {
        // Display name is available, set the greeting text
        setState(() {
          _greetingText =
          "Welcome back, $displayName!"; // Personalized greeting for returning user
        });
      } else {
        // Display name is not available, use a default greeting
        setState(() {
          _greetingText =
          "Welcome back!"; // Default greeting for returning user without a display name
        });
      }
    } else {
      // No user is signed in, use a default greeting
      setState(() {
        _greetingText = "Welcome!"; // Default greeting for new user
      });
    }
  }

  // Custom transition animation to login page
  Route _createLoginRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LogIn(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Custom transition animation to home page
  Route _createHomeRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Home(),
      // Replace HomePage() with your home page widget
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Animated background using Lottie animation
        Center(
          child: SizedBox(
            width: 360, // Adjust the width as needed
            height: 360, // Adjust the height as needed
            child: Image.asset(
              'assets/images/startingpage.png',
              // Path to your Lottie animation JSON file
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Animated text "MindMender" displayed below the animation
        Positioned(
          bottom: 70, // Adjust position as needed
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      _greetingText, // Display personalized greeting
                      textStyle: const TextStyle(
                        fontSize: 44, // Adjust font size as needed
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontFamily: 'Josefin Slabs', // Change this to your preferred font
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Adjust vertical spacing as needed
                // Add any other widgets you want to display below the greeting
              ],
            ),
          ),
        ),
      ],
    );
  }
}