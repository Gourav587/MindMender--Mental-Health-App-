import 'package:flutter/material.dart';
import 'package:myproject/home.dart';
import 'package:myproject/quiz_data.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Start extends StatelessWidget {
  const Start({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Assignment',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF251404),
              Color(0xFF261505),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Text(
                      '“Embark on a journey with our Mental Health Quiz. It’s not about reaching a place, but achieving clarity, resilience, and self-awareness by exploring your emotions.”',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  );
                },
                child: const Text(
                  'Start',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


List<String> selectedAnswer = [];
String? _selectedOption;

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  var _index = 0;

  // Getter for index
  int get index => _index;

  void onNextQuestion() {
    setState(() {
      if (_index < questions.length - 1) {
        _index++;
        _selectedOption = null; // Reset selected option for the new question
      } else {
        // Handle quiz completion or end of questions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      }
    });
  }

  void onSelectAnswer(String clickedAnswer) {
    setState(() {
      if (_selectedOption == clickedAnswer) {
        _selectedOption = null;
        selectedAnswer.removeLast();
      } else {
        _selectedOption = clickedAnswer;
        selectedAnswer.add(clickedAnswer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[index];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF251404),
            Color(0xFF261505),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make the Scaffold background transparent
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Assessment',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: const <Widget>[
            SizedBox(width: 10),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentQuestion.question,
                    style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ...currentQuestion.options.map((item) {
                    return AnswerButton(
                      onTap: () => onSelectAnswer(item),
                      chosenAnswer: item,
                      backgroundColor: Colors.lightGreen,
                      isSelected: _selectedOption == item,
                    );
                  }).toList(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: onNextQuestion,
                  child: Text(
                    _index < questions.length - 1 ? 'Next' : 'Finish', // Change button text based on whether there are more questions
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 16), // Adjust button padding as needed
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    required this.onTap,
    required this.chosenAnswer,
    required this.backgroundColor,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  final void Function() onTap;
  final String chosenAnswer;
  final Color backgroundColor;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? backgroundColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5), // Adjust container padding as needed
            child: Row(
              children: [
                Radio<String>(
                  value: chosenAnswer,
                  groupValue: isSelected ? chosenAnswer : "",
                  onChanged: (value) {
                    // Not needed in AnswerButton, handled in QuizScreen
                  },
                  activeColor: backgroundColor,
                ),
                Expanded(
                  child: Text(
                    chosenAnswer,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white,
                      fontSize: 20, // Set the text size to 20
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  List<Map<String, Object>> getSummaryData() {
    List<Map<String, Object>> summary = [];
    for (int i = 0; i < questions.length; i++) {
      String? chosenAnswer;
      try {
        chosenAnswer = selectedAnswer.length > i ? selectedAnswer[i] : null;
      } catch (e) {
        print('Error accessing selectedAnswer: $e');
        // Handle the error here
      }
      Map<String, Object> data = {
        'questionIndex': i,
        'questionText': questions[i].question,
        'chosenAnswer': chosenAnswer ?? '',
      };
      for (int j = 0; j < 5; j++) {
        late String correctAnswer = ''; // Initialize with an empty string
        try {
          correctAnswer = questions[i].options.length > j ? questions[i].options[j] : '';
        } catch (e) {
          print('Error accessing correctAnswer: $e');
          // Handle the error here
        }
        data['correctAnswer${j + 1}'] = correctAnswer as Object;
      }
      summary.add(data);
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    var summaryData = getSummaryData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Assessment Result',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: const <Widget>[
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF251404),
              Color(0xFF261505), // Adjust opacity here
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Assessment Result',
                style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summaryData.map((data) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${(data['questionIndex'] as int) + 1}: ${data['questionText'] ?? ''}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Chosen Answer: ${data['chosenAnswer'] ?? ''}',
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 5),
                          for (var i = 0; i < 5; i++)
                            Text(
                              'Correct Answer ${i + 1}: ${data['correctAnswer${i + 1}'] ?? ''}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SolutionScreen()),
                  );
                  selectedAnswer = [];
                },
                child: const Text("Finish Test", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SolutionScreen extends StatelessWidget {
  const SolutionScreen({Key? key}) : super(key: key);

  String getSolution() {
    int score = 0;
    for (String answer in selectedAnswer) {
      switch (answer) {
        case 'Never':
          score += 0;
          break;
        case 'Almost never':
          score += 1;
          break;
        case 'Sometimes':
          score += 2;
          break;
        case 'Fairly often':
          score += 3;
          break;
        case 'Very often':
          score += 4;
          break;
      }
    }
    if (score <= 10) {
      return 'Your stress level is low. Regular exercise and a healthy diet can help maintain your stress level. Try to incorporate some light activities such as walking or cycling into your daily routine.';
    } else if (score <= 20) {
      return 'Your stress level is moderate. Consider incorporating relaxation exercises into your routine, such as yoga or meditation. You might also find it helpful to try deep breathing exercises or progressive muscle relaxation.';
    } else {
      return 'Your stress level is high. It might be helpful to speak with a mental health professional. They can provide strategies to manage stress, such as cognitive-behavioral therapy. In the meantime, try to engage in regular physical activity, get plenty of sleep, and maintain a balanced diet.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Solution', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Result:',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  getSolution(),
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Recommended Exercises:',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  '1. Deep Breathing: Deep breathing can help activate your body\'s relaxation response which may reduce stress and promote feelings of calmness.\n'
                      '2. Progressive Muscle Relaxation: This technique involves tensing and then releasing different muscle groups in your body to promote physical relaxation.\n'
                      '3. Mindfulness Meditation: Mindfulness involves focusing on the present moment without judgment.\n'
                      '4. Yoga: Yoga combines physical postures, breathing exercises, meditation, and a distinct philosophy in a comprehensive fitness practice.\n'
                      '5. Regular Exercise: Regular physical activity can help reduce stress and improve mood.\n'
                      '6. Healthy Eating: Eating a balanced diet can help you feel better in general. It may also help you handle stress better.',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  },
                  child: const Text("Continue", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
