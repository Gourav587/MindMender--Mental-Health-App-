import 'package:flutter/material.dart';

class MoodTracker extends StatelessWidget {
  const MoodTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 10,
              children: <Widget>[
                MoodButton(mood: 'Happy', icon: Icons.sentiment_very_satisfied),
                MoodButton(mood: 'Neutral', icon: Icons.sentiment_neutral),
                MoodButton(mood: 'Sad', icon: Icons.sentiment_very_dissatisfied),
                // Add more moods here...
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                // Handle submit
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MoodButton extends StatelessWidget {
  final String mood;
  final IconData icon;

  const MoodButton({super.key, required this.mood, required this.icon});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        // Handle mood selection
      },
    );
  }
}


