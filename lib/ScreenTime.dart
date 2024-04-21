import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ScreenTime extends StatefulWidget {
  const ScreenTime({super.key});

  @override
  _ScreenTimeDashboardState createState() => _ScreenTimeDashboardState();
}

class _ScreenTimeDashboardState extends State<ScreenTime> {
  late String _mood;
  late Color _moodColor;
  late IconData _moodIcon;

  List<ScreenTimeEntry> screenTimeData = [
    ScreenTimeEntry('Instagram', 150),
    ScreenTimeEntry('TikTok', 50),
    ScreenTimeEntry('Twitter', 0),
    ScreenTimeEntry('YouTube', 40),
  ];

  @override
  void initState() {
    super.initState();
    _predictMood();
  }

  void _predictMood() {
    int totalScreenTime = _calculateTotalScreenTime();

    if (totalScreenTime < 120) {
      _setMood('You seem happy 😊', Colors.green, Icons.sentiment_satisfied);
    } else if (totalScreenTime < 240) {
      _setMood('You seem neutral 😐', Colors.blue, Icons.sentiment_neutral);
    } else if (totalScreenTime < 360) {
      _setMood('You seem depressed 😔', Colors.grey, Icons.sentiment_very_dissatisfied);
    } else {
      _setMood('You seem stressed 😠', Colors.red, Icons.sentiment_dissatisfied);
    }
  }

  void _setMood(String moodText, Color moodColor, IconData moodIcon) {
    setState(() {
      _mood = moodText;
      _moodColor = moodColor;
      _moodIcon = moodIcon;
    });
  }

  int _calculateTotalScreenTime() {
    return screenTimeData.map((entry) => entry.usageTime).reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Mental health predictor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF251404),
              Color(0xFF261505),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalScreenTime(),
              const SizedBox(height: 20),
              _buildMoodEmoji(),
              const SizedBox(height: 20),
              _buildChart(),
              const SizedBox(height: 20),
              _buildTopApps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalScreenTime() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFF926247), // Color changed to #926247
      ),
      child: Card(
        elevation: 0, // Set elevation to 0 to remove shadow
        color: Colors.transparent, // Make the card transparent
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Total Screen Time',
                style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${(_calculateTotalScreenTime() / 60).toStringAsFixed(1)} hours',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodEmoji() {
    return Column(
      children: [
        const Text(
          'Your mood:',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _mood ??'',
              style: TextStyle(fontSize: 28, color: _moodColor),
            ),
            const SizedBox(width: 10),
            Icon(
              _moodIcon,
              color: _moodColor,
              size: 0, // Set the size to 24
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopApps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Apps',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 10),
        ...screenTimeData.take(3).map((entry) => _buildAppEntry(entry)),
      ],
    );
  }

  Widget _buildAppEntry(ScreenTimeEntry entry) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _getColor(entry.appName),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 10),
        Text(entry.appName, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Text('${entry.usageTime} min', style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildChart() {
    return Expanded( // Add Expanded widget to allow the PieChart to take available vertical space
      child: SizedBox(
        height: 100,
        child: PieChart(
          PieChartData(
            sections: _getSections(),
            borderData: FlBorderData(show: false),
            sectionsSpace: 4,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return screenTimeData.map((entry) {
      final value = entry.usageTime.toDouble();
      final color = _getColor(entry.appName);
      return PieChartSectionData(
        value: value,
        title: '${(value / 60).toStringAsFixed(1)} hr',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Color _getColor(String appName) {
    switch (appName) {
      case 'Instagram':
        return Colors.red;
      case 'TikTok':
        return Colors.blue;
      case 'Twitter':
        return Colors.lightBlueAccent;
      case 'YouTube':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

class ScreenTimeEntry {
  final String appName;
  final int usageTime;
  ScreenTimeEntry(this.appName, this.usageTime);
}
