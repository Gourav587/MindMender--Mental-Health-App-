// Add this import statement

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:myproject/Assignment.dart';
import 'package:myproject/ScreenTime.dart';
import 'package:myproject/chatbot.dart';
import 'package:myproject/therapist.dart';
import 'package:myproject/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myproject/sideMenu.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LogIn()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MindMender',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: CustomDrawer(),
      body: WillPopScope(
        onWillPop: () async {
          // Close the app when the back button is pressed
          SystemNavigator.pop();
          return false;
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF251404), // Changed to #251404
                Color(0xFF261505), // Changed to #261505
              ],
            ),
          ),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const Start(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 200, // Increase the height
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Container(
                    height: 200, // Increase the height
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.3, // Ensure a square aspect ratio
                      child: Stack(
                        children: [
                          Center(
                            child: Transform.scale(
                              scale: 1.4, // Adjust the scale factor as needed
                              alignment: Alignment.centerLeft, // Center the animation
                              child: Lottie.asset(
                                'assets/images/Assignment.json', // Replace 'assets/your_animation.json' with the path to your animated JSON file
                                fit: BoxFit.contain, // Fit the animation inside the square container
                                alignment: Alignment.center,
                                // You can control the animation using a LottieController
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              // Make the container a little transparent
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: const Text(
                              'Assignment',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ScreenTime(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 200, // Set the desired height
                  decoration: BoxDecoration(
                    color: const Color(0xff7ba6da),
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Transform.scale(
                        scale: 0.9, // Adjust the scale factor as needed
                        alignment: Alignment.bottomCenter,
                        child: AspectRatio(
                          aspectRatio: 1.5, // Adjust aspect ratio as needed to maintain animation proportions
                          child: Lottie.asset(
                            'assets/images/ScreenTime.json', // Replace 'assets/your_animation.json' with the path to your animated JSON file
                            fit: BoxFit.cover, // Ensure the animation covers the entire container while maintaining its aspect ratio
                            alignment: Alignment.center,
                            // You can control the animation using a LottieController
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          // Make the container a little transparent
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Text(
                          'Mental health predictor',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => TherapistScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 200, // Set the desired height
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Transform.scale(
                        scale: 0.8, // Adjust the scale factor as needed to make the animation smaller
                        alignment: Alignment.bottomRight, // Adjust the alignment to the left side
                        child: AspectRatio(
                          aspectRatio: 1.0, // Maintain the aspect ratio
                          child: Lottie.asset(
                            'assets/images/Therapist.json', // Replace 'assets/your_animation.json' with the path to your animated JSON file
                            fit: BoxFit.cover, // Ensure the animation covers the entire container
                            alignment: Alignment.center, // Align the animation to the left
                            // You can control the animation using a LottieController
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: const Text(
                          'Therapist',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ChatbotScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 200, // Increase the height
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        alignment: Alignment.centerLeft, // Center the animation
                        child: AspectRatio(
                          aspectRatio: 1.7, // Ensure a square aspect ratio
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Lottie.asset(
                              'assets/images/chatbot.json', // Replace 'assets/your_animation.json' with the path to your animated JSON file
                              fit: BoxFit.cover, // Ensure the animation covers the entire container while maintaining its aspect ratio
                              alignment: Alignment.centerLeft,
                              // You can control the animation using a LottieController
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          // Make the container a little transparent
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: const Text(
                          'ChatBot',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
