import 'package:flutter/material.dart';
import 'package:myproject/home.dart';

class RateUs extends StatefulWidget {
  const RateUs({super.key});

  @override
  _RateUsState createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Rate Us', style: TextStyle(color: Colors.white, fontSize: 26)),
        backgroundColor: Colors.black,
        // Set app bar color to black
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back arrow button color to white
      ),
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'How would you rate our app?',
                style: TextStyle(fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      // If this star represents a rating that is less than or equal to the selected rating, color it yellow
                      color: index < _rating ? Colors.yellow : Colors.white,
                    ),
                    onPressed: () {
                      // When this star is clicked, update the selected rating and redraw the widget
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                      0xFF926247), // Set button background color to #926247
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Thank you!'),
                        content: const Text('Thanks for your review.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              // Pop the dialog
                              Navigator.of(context).pop();

                              // Navigate to the home screen
                              Navigator.pushAndRemoveUntil(
                                context,
                                  MaterialPageRoute(builder: (context) => const Home()),
                                    (Route<
                                    dynamic> route) => false, // Remove all previous routes
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Submit', style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}