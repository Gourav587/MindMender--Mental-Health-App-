import 'package:flutter/material.dart';

// Define Therapist class
class Therapist {
  final String name;
  final String specialization;
  final String imageUrl;

  Therapist({
    required this.name,
    required this.specialization,
    required this.imageUrl,
  });
}

// Define TherapistCard widget to display therapist information
class TherapistCard extends StatelessWidget {
  final Therapist therapist;

  const TherapistCard({super.key, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(therapist.imageUrl),
        ),
        title: Text(therapist.name),
        subtitle: Text(therapist.specialization),
        onTap: () {
          // Handle therapist selection
          // Navigate to scheduling screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScheduleScreen(therapist: therapist)),
          );
        },
      ),
    );
  }
}

// Define ScheduleScreen for scheduling meetings with the therapist
class ScheduleScreen extends StatelessWidget {
  final Therapist therapist;

  const ScheduleScreen({super.key, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Meeting'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Schedule your meeting with ${therapist.name}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle scheduling logic
                // Navigate to payment screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentScreen(therapist: therapist)),
                );
              },
              child: const Text('Schedule Now'),
            ),
          ],
        ),
      ),
    );
  }
}

// Define PaymentScreen for making payments for meeting sessions
class PaymentScreen extends StatelessWidget {
  final Therapist therapist;

  const PaymentScreen({super.key, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Make payment for your session with ${therapist.name}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle payment gateway integration
                // You can integrate payment gateway SDKs here
                // For example, you can launch a webview to handle payments
                // or use available payment plugins/packages
                // After successful payment, navigate back to previous screen
                Navigator.pop(context);
              },
              child: const Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

class TherapistScreen extends StatelessWidget {
  final List<Therapist> therapists = [
    Therapist(
      name: 'Dr. John Doe',
      specialization: 'Psychologist',
      imageUrl: 'assets/therapist1.jpg',
    ),
    Therapist(
      name: 'Dr. Jane Smith',
      specialization: 'Counselor',
      imageUrl: 'assets/therapist2.jpg',
    ),
    // Add more therapists as needed
  ];

 TherapistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Therapist'),
      ),
      body: ListView.builder(
        itemCount: therapists.length,
        itemBuilder: (context, index) {
          return TherapistCard(therapist: therapists[index]);
        },
      ),
    );
  }
}
